# 需求文档

## 简介

扩展 ColorOverlayRenderer 的能力，新增实时渲染预览模式。当前的 `applyOverlay` 方法每次颜色变化都会重新执行完整的 CPU 泛洪填充 + GPU 双 Pass 渲染流程，导致实时调色场景下性能极差。

新功能将渲染流程拆分为两个阶段：
1. **预处理阶段**（仅执行一次）：提取像素、CPU 泛洪生成基础 Mask、膨胀 Mask
2. **实时渲染阶段**（每帧执行）：仅重新执行 `apply_color_overlay` 着色器，改变颜色参数即可

通过 Metal 框架的 MTKView 提供 SwiftUI 可嵌入的实时预览视图，用户在调色完成后点击保存时，才将 GPU 纹理编码为 PNG 图片。原有的 `applyOverlay` 一次性处理方法保持不变，确保向后兼容。

## 术语表

- **ColorOverlayRenderer**: 颜色蒙版渲染器，负责根据图像内容生成对应的颜色蒙版背景，使用 Metal GPU 计算管线实现
- **MTKView**: Metal 框架提供的高性能渲染视图，支持按需或持续刷新的 GPU 绘制
- **MTKViewRepresentable**: 将 MTKView 包装为 SwiftUI 兼容视图的 UIViewRepresentable 适配器
- **generate_solid_mask**: CPU 端的 BFS 泛洪填充算法，从图像边缘向内扫描，识别闭合区域并生成单通道 Mask 数据
- **dilate_mask**: Metal 计算着色器（Pass 1），将基础 Mask 按指定半径进行圆形膨胀
- **apply_color_overlay**: Metal 计算着色器（Pass 2），根据膨胀后的 Mask 和指定颜色生成最终的蒙版叠加图像
- **inTexture**: 存储原始图像 RGBA 像素数据的 Metal 纹理
- **dilatedMaskTexture**: 存储膨胀后 Mask 数据的 Metal 纹理（Pass 1 的输出）
- **outTexture**: 存储最终渲染结果的 Metal 纹理（Pass 2 的输出）
- **RenderPassDrawable**: MTKView 每帧提供的可绘制目标，用于将 GPU 渲染结果呈现到屏幕

## 需求

### 需求 1：预处理阶段（一次性执行）

**用户故事：** 作为开发者，我希望在加载图像时只执行一次昂贵的 CPU 泛洪填充和 Mask 膨胀计算，以便后续实时调色时无需重复这些耗时操作。

#### 验收标准

1. THE ColorOverlayRenderer SHALL 提供 `prepareForRealtimeRendering` 方法，接收 UIImage 和 expandRadius 参数，执行预处理流程
2. WHEN `prepareForRealtimeRendering` 被调用时，THE ColorOverlayRenderer SHALL 创建带 padding 的画布，调用 `generate_solid_mask` 生成基础 Mask，并通过 `dilate_mask` 着色器生成膨胀后的 Mask 纹理
3. WHEN 预处理完成后，THE ColorOverlayRenderer SHALL 将 inTexture 和 dilatedMaskTexture 缓存为实例属性，供后续实时渲染复用
4. WHEN `prepareForRealtimeRendering` 被再次调用时（切换图像），THE ColorOverlayRenderer SHALL 释放之前缓存的纹理资源并重新执行预处理流程
5. IF 预处理过程中 Metal 设备不可用或纹理创建失败，THEN THE ColorOverlayRenderer SHALL 通过返回值或状态属性通知调用方预处理失败

### 需求 2：实时渲染预览

**用户故事：** 作为用户，我希望在调整蒙版颜色时能实时看到预览效果，而不需要等待每次完整的图像处理流程。

#### 验收标准

1. THE ColorOverlayRenderer SHALL 提供 `overlayColor` 属性，外部修改该属性时触发实时渲染刷新
2. WHEN `overlayColor` 属性发生变化时，THE ColorOverlayRenderer SHALL 仅重新执行 `apply_color_overlay` 着色器（Pass 2），使用缓存的 inTexture 和 dilatedMaskTexture 作为输入
3. WHILE 预处理尚未完成时，THE ColorOverlayRenderer SHALL 忽略颜色变化请求，不执行渲染
4. THE ColorOverlayRenderer SHALL 将 `apply_color_overlay` 的渲染结果绘制到 MTKView 的当前 drawable 上进行屏幕呈现
5. WHEN 连续快速修改 `overlayColor` 时，THE ColorOverlayRenderer SHALL 确保每次渲染使用最新的颜色值，丢弃中间过时的渲染请求

### 需求 3：SwiftUI 实时预览视图

**用户故事：** 作为开发者，我希望有一个 SwiftUI 兼容的 Metal 预览视图组件，以便在 SwiftUI 界面中直接嵌入实时蒙版预览。

#### 验收标准

1. THE MTKViewRepresentable SHALL 作为 UIViewRepresentable 实现，将 MTKView 包装为 SwiftUI 视图
2. THE MTKViewRepresentable SHALL 将 MTKView 配置为按需绘制模式（isPaused = true, enableSetNeedsDisplay = true），避免不必要的持续刷新
3. WHEN ColorOverlayRenderer 完成一帧渲染后，THE MTKViewRepresentable SHALL 调用 MTKView 的 setNeedsDisplay 方法触发屏幕刷新
4. THE MTKViewRepresentable SHALL 将 MTKView 的 framebufferOnly 设置为 false，以支持后续从 drawable 纹理读取像素数据
5. THE MTKViewRepresentable SHALL 正确处理 SwiftUI 视图生命周期，在视图销毁时释放 Metal 资源引用

### 需求 4：导出保存功能

**用户故事：** 作为用户，我希望在调色满意后点击保存，将当前预览效果导出为 PNG 图片，而不是在每次颜色变化时都生成图片。

#### 验收标准

1. THE ColorOverlayRenderer SHALL 提供 `exportCurrentResult` 方法，将当前 outTexture 的内容编码为 UIImage 并返回
2. WHEN `exportCurrentResult` 被调用时，THE ColorOverlayRenderer SHALL 从 outTexture 读取像素数据，创建 CGImage，并生成与原始图像相同 scale 和 orientation 的 UIImage
3. IF 预处理尚未执行或 outTexture 不存在，THEN THE `exportCurrentResult` 方法 SHALL 返回 nil
4. THE `exportCurrentResult` 方法 SHALL 在调用时同步执行 GPU 渲染并等待完成，确保导出的图像反映最新的颜色设置

### 需求 5：向后兼容

**用户故事：** 作为开发者，我希望新增的实时渲染功能不影响现有的 `applyOverlay` 一次性处理流程，确保已有调用方无需修改代码。

#### 验收标准

1. THE ColorOverlayRenderer SHALL 保留现有的 `applyOverlay(to:color:expandRadius:)` 方法，其签名和行为保持不变
2. THE `applyOverlay` 方法 SHALL 继续独立执行完整的渲染流程（CPU 泛洪 + GPU 双 Pass），不依赖实时渲染的缓存状态
3. THE ColorOverlayRenderer SHALL 保持 `@Observable` 和 `@unchecked Sendable` 标记，确保与现有的 SwiftUI 数据流和并发模型兼容

### 需求 6：线程安全

**用户故事：** 作为开发者，我希望 ColorOverlayRenderer 在多线程环境下安全运行，避免实时渲染和一次性渲染之间的资源竞争。

#### 验收标准

1. THE ColorOverlayRenderer SHALL 确保实时渲染的缓存纹理（inTexture、dilatedMaskTexture、outTexture）的读写操作不与 `applyOverlay` 方法产生数据竞争
2. WHEN `prepareForRealtimeRendering` 和实时渲染同时被调用时，THE ColorOverlayRenderer SHALL 通过同步机制确保预处理完成后才开始渲染
3. THE ColorOverlayRenderer SHALL 确保 `overlayColor` 属性的修改和读取在并发场景下是安全的
