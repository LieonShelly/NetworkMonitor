# ColorOverlayRenderer

基于 Metal 的 iOS 图像颜色蒙版渲染器，支持一次性渲染和实时预览两种模式。核心能力是为任意 PNG/手绘图像自动生成闭合区域的彩色背景蒙版。

## 功能概览

| 功能 | 方法 | 说明 |
|------|------|------|
| 一次性渲染 | `applyOverlay(to:color:expandRadius:)` | 输入 UIImage + 颜色，输出带蒙版的 UIImage |
| 预处理 | `prepareForRealtimeRendering(image:expandRadius:)` | 缓存 CPU 泛洪 + GPU 膨胀结果，为实时预览做准备 |
| 实时预览 | `renderToView()` | 仅执行颜色叠加 Pass，渲染到 MTKView |
| 导出 | `exportCurrentResult()` | 将当前预览结果编码为 UIImage |
| 清理 | `cleanupRealtimeCache()` | 释放缓存纹理 |

## 架构

```
┌─────────────────────────────────────────────────────────┐
│                   ColorOverlayRenderer                   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │          一次性模式 (applyOverlay)                 │   │
│  │  UIImage → CPU泛洪 → Pass1 → Pass2 → UIImage     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │          实时预览模式                              │   │
│  │  prepareForRealtimeRendering:                     │   │
│  │    UIImage → CPU泛洪 → Pass1 → 缓存纹理           │   │
│  │                                                    │   │
│  │  renderToView (每次颜色变化):                      │   │
│  │    缓存纹理 → Pass2 → Render Pass → MTKView       │   │
│  │                                                    │   │
│  │  exportCurrentResult:                              │   │
│  │    缓存纹理 → Pass2 → 像素回读 → UIImage           │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Metal Pipeline 总览

渲染器初始化时编译 3 条 Pipeline：

| Pipeline | 类型 | Shader 函数 | 用途 |
|----------|------|-------------|------|
| `dilatePipelineState` | Compute | `dilate_mask` | Pass 1: 将基础 Mask 按半径做圆形膨胀 |
| `applyOverlayPipelineState` | Compute | `apply_color_overlay` | Pass 2: 根据膨胀 Mask 和颜色生成最终蒙版图像 |
| `renderPipelineState` | Render | `quad_vertex_main` + `quad_fragment_main` | 将 Compute 输出纹理 Aspect-Fit 绘制到 MTKView |

---

## 功能一：一次性渲染 (`applyOverlay`)

完整的同步渲染流程，输入 UIImage + 颜色，输出带蒙版的 UIImage。适用于不需要实时预览的场景。

### 流程

```
UIImage
  │
  ▼
┌─────────────────────────────┐
│ 1. 创建 Padded 画布          │  原图四周各加 expandRadius 像素的透明边距
│    (width + 2*radius) ×      │  确保膨胀后的 Mask 不会被画布边界截断
│    (height + 2*radius)       │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ 2. CPU 泛洪生成基础 Mask     │  GraphicAlgorithm.generateSolidMask()
│    (详见下方 "背景蒙版生成")  │  输出: 单通道 [UInt8] (0=外部, 255=内部)
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ 3. 创建 Metal 纹理           │  inTexture (rgba8Unorm): 原始图像像素
│                              │  cpuMaskTexture (r8Unorm): CPU 生成的基础 Mask
│                              │  dilatedMaskTexture (r8Unorm): 膨胀后的 Mask
│                              │  outTexture (rgba8Unorm): 最终输出
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ 4. GPU Pass 1: dilate_mask  │  Compute Shader
│                              │  输入: cpuMaskTexture + expandRadius
│                              │  输出: dilatedMaskTexture
│                              │  原理: 对每个像素搜索半径内是否存在 Mask 有效像素
│                              │        使用圆形内核 (i²+j² ≤ r²) 确保边缘圆滑
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ 5. GPU Pass 2:              │  Compute Shader
│    apply_color_overlay       │  输入: inTexture + dilatedMaskTexture + 颜色参数
│                              │  输出: outTexture
│                              │  逻辑:
│                              │    mask > 0.5 且 原始alpha > 0 → 保留原始像素(前景)
│                              │    mask > 0.5 且 原始alpha = 0 → 填充指定颜色(背景)
│                              │    mask ≤ 0.5 → 全透明(外部区域)
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ 6. 像素回读                  │  outTexture.getBytes() → CGContext → CGImage → UIImage
│                              │  保留原始 image.scale 和 image.imageOrientation
└─────────────────────────────┘
```

---

## 功能二：实时预览模式

将渲染流程拆分为"预处理"和"实时渲染"两个阶段。预处理只执行一次（CPU 泛洪 + Pass 1），后续颜色变化时仅重新执行 Pass 2，实现毫秒级响应。

### 阶段 1: 预处理 (`prepareForRealtimeRendering`)

```
UIImage
  │
  ▼
┌──────────────────────────────────┐
│ CPU 泛洪 + GPU Pass 1 (同上)      │
│                                   │
│ 缓存结果:                         │
│   cachedInTexture ← inTexture     │
│   cachedDilatedMaskTexture ← dilatedMaskTexture
│   cachedOutTexture ← outTexture   │
│   cachedImageScale ← image.scale  │
│   cachedImageOrientation          │
│   isPrepared = true               │
└──────────────────────────────────┘
```

### 阶段 2: 实时渲染 (`renderToView`)

每次 `overlayColor` 变化时触发：

```
overlayColor didSet
  │
  ▼
mtkView.setNeedsDisplay()
  │
  ▼
MTKViewDelegate.draw(in:)
  │
  ▼
renderToView()
  │
  ├─── Compute Pass ──────────────────────────────────┐
  │    apply_color_overlay:                            │
  │    cachedInTexture + cachedDilatedMaskTexture      │
  │    → cachedOutTexture                              │
  │    (仅执行 Pass 2，跳过 CPU 泛洪和 Pass 1)         │
  └────────────────────────────────────────────────────┘
  │
  ├─── Render Pass ───────────────────────────────────┐
  │    quad_vertex_main + quad_fragment_main:           │
  │    将 cachedOutTexture 以 Aspect-Fit 方式           │
  │    居中绘制到 drawable.texture                      │
  │                                                     │
  │    NDC 坐标计算:                                    │
  │    scaleFit = min(viewW/imgW, viewH/imgH, 1.0)     │
  │    ndcScaleX = (imgW * scaleFit) / viewW            │
  │    ndcScaleY = (imgH * scaleFit) / viewH            │
  │    顶点范围: [-ndcScaleX, -ndcScaleY]               │
  │           到 [+ndcScaleX, +ndcScaleY]               │
  └─────────────────────────────────────────────────────┘
  │
  ▼
commandBuffer.present(drawable) + commit()
```

### 阶段 3: 导出 (`exportCurrentResult`)

用户确认保存时调用，同步执行 Pass 2 并回读像素：

```
exportCurrentResult()
  │
  ▼
Compute Pass: apply_color_overlay → cachedOutTexture
  │
  ▼
waitUntilCompleted()  ← 同步等待 GPU 完成
  │
  ▼
outTexture.getBytes() → CGContext → CGImage → UIImage(scale, orientation)
```

---

## 背景蒙版 CPU 端生成原理

`GraphicAlgorithm.generateSolidMask()` 负责从图像像素数据中识别"闭合区域"，生成单通道 Mask。

### 核心思路

将图像视为一个二维网格，非透明像素构成"墙壁"，透明像素构成"通道"。从图像边缘开始向内泛洪，所有能从边缘到达的透明像素都是"外部背景"，无法到达的透明像素则被"墙壁"包围，属于"内部区域"。

### 算法流程

```
┌─────────────────────────────────────────────────────┐
│ 阶段 1: 统计笔触面积                                 │
│                                                      │
│ 遍历所有像素，统计 alpha > 0 的像素数量 (strokeArea)   │
│ 每隔 5 个像素采样坐标，用于后续凸包兜底                │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ 阶段 2: BFS 泛洪填充                                 │
│                                                      │
│ 1. 初始化: memset(maskData, 255, totalPixels)        │
│    假设所有像素都是"内部有效区域"                      │
│                                                      │
│ 2. 种子注入: 扫描图像四周边缘                         │
│    如果边缘像素是透明的 (alpha == 0):                 │
│      maskData[index] = 0  (标记为外部)                │
│      加入 BFS 队列                                    │
│                                                      │
│ 3. BFS 扩散: 从种子开始，4 方向遍历                   │
│    对每个邻居: 如果 maskData == 255 且 alpha == 0     │
│      → 标记为外部 (maskData = 0)，加入队列            │
│    非透明像素 (alpha > 0) 会阻断泛洪传播              │
│                                                      │
│ 结果: 被非透明像素包围的透明区域保持 255 (内部)        │
│       与边缘连通的透明区域变为 0 (外部)                │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ 阶段 3: 校验 + 凸包兜底                              │
│                                                      │
│ 计算 fillRatio = maskArea / strokeArea               │
│                                                      │
│ 如果 fillRatio < 1.05 (填充面积几乎没有增加):         │
│   说明泛洪失败 (图形未形成闭合区域)                    │
│   触发凸包兜底策略:                                   │
│     1. 对采样点计算 Monotone Chain 凸包               │
│     2. 用 CoreGraphics 将凸包多边形光栅化到 maskData  │
│     3. 凸包内部 = 255, 外部 = 0                      │
└─────────────────────────────────────────────────────┘
```

### BFS 泛洪示意

```
原始图像 (. = 透明, # = 非透明):     Mask 结果 (0 = 外部, 1 = 内部):

. . . . . . . .                      0 0 0 0 0 0 0 0
. . # # # # . .                      0 0 1 1 1 1 0 0
. # . . . . # .                      0 1 1 1 1 1 1 0
. # . . . . # .          →           0 1 1 1 1 1 1 0
. # . . . . # .                      0 1 1 1 1 1 1 0
. . # # # # . .                      0 0 1 1 1 1 0 0
. . . . . . . .                      0 0 0 0 0 0 0 0

边缘透明像素从四周向内泛洪，被 # 围住的内部透明像素无法被到达，保持为 1。
```

### 性能优化

- 使用 `UnsafeMutablePointer<FloodPoint>` 分配连续内存作为 BFS 队列，避免 Swift Array 的动态扩容开销
- `FloodPoint` 使用 `Int16` 存储坐标，节省内存（支持最大 32767×32767 图像）
- `memset` 初始化 Mask，比逐元素赋值快一个数量级
- `@inline(__always)` 标记入队辅助函数，消除函数调用开销

---

## GPU Shader 详解

### Pass 1: `dilate_mask` (Compute)

将基础 Mask 按指定半径做圆形形态学膨胀。

```
输入:
  texture(0): cpuMaskTexture (r8Unorm) - CPU 生成的基础 Mask
  buffer(0):  radius (int) - 膨胀半径

输出:
  texture(1): dilatedMaskTexture (r8Unorm) - 膨胀后的 Mask

算法:
  对每个像素，在半径 r 的圆形区域内搜索:
    如果找到任何 mask > 0.5 的邻居 → 输出 1.0
    否则 → 输出 0.0

  圆形判定: i² + j² ≤ r²
  提前退出: 找到有效邻居后立即 break，避免无效搜索
```

### Pass 2: `apply_color_overlay` (Compute)

根据膨胀后的 Mask 和指定颜色生成最终蒙版图像。

```
输入:
  texture(0): inTexture (rgba8Unorm) - 原始图像
  texture(1): maskTexture (r8Unorm) - 膨胀后的 Mask
  buffer(0):  OverlayColor { float4 color } - 叠加颜色 RGBA

输出:
  texture(2): outTexture (rgba8Unorm) - 最终结果

逻辑:
  if mask > 0.5:
    if 原始 alpha > 0:  → 保留原始像素 (前景笔画)
    else:               → 填充指定颜色 (背景蒙版)
  else:
    → 全透明 (0,0,0,0) (外部区域)
```

### Render Pass: `quad_vertex_main` + `quad_fragment_main`

将 Compute Shader 的输出纹理以 Aspect-Fit 方式绘制到 MTKView 的 drawable 上。

```
Vertex Shader:
  输入: 4 个顶点坐标 (NDC) + 4 个纹理坐标
  输出: 裁剪空间坐标 + 插值纹理坐标
  绘制方式: Triangle Strip (4 顶点 = 1 个矩形)

Fragment Shader:
  输入: 插值后的纹理坐标
  采样: bilinear filtering (mag_filter::linear, min_filter::linear)
  输出: 采样颜色值

Aspect-Fit 计算 (Swift 端):
  scaleFit = min(viewW/imgW, viewH/imgH, 1.0)  // 不放大，只缩小
  NDC 范围 = [-scaleFit*imgW/viewW, +scaleFit*imgW/viewW]
  效果: 图像居中显示，保持原始宽高比，周围透明
```

---

## 线程安全

- `NSLock (realtimeLock)` 保护缓存纹理的读写
- `prepareForRealtimeRendering` 在锁内完成全部预处理
- `renderToView` 在锁内读取缓存引用，解锁后执行 GPU 渲染
- `applyOverlay` 使用独立的局部纹理，不访问缓存，与实时渲染完全隔离

## SwiftUI 集成

`MTKViewRepresentable` 将 MTKView 包装为 SwiftUI 视图：

```swift
MTKViewRepresentable(renderer: ColorOverlayRenderer.shared)
```

配置:
- `isPaused = true` + `enableSetNeedsDisplay = true`: 按需绘制模式
- `colorPixelFormat = .rgba8Unorm`: 匹配缓存纹理格式
- `framebufferOnly = false`: 支持像素回读
- `isOpaque = false`: 支持透明背景

## 文件结构

```
├── ColorOverlayRenderer.swift    # 核心渲染器 (Swift)
├── GraphicAlgorithm.swift        # CPU 端泛洪填充 + 凸包兜底 (Swift)
├── Shaders.metal                 # GPU 着色器 (Metal Shading Language)
└── MTKViewRepresentable.swift    # SwiftUI 视图适配器 (Swift)
```
