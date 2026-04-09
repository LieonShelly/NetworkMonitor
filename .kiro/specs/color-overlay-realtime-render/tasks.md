# 实现计划：颜色蒙版实时渲染预览

## 概述

将 ColorOverlayRenderer 的渲染流程拆分为预处理和实时渲染两个阶段，新增 MTKViewRepresentable 提供 SwiftUI 实时预览能力。实现语言为 Swift，使用 Metal 框架进行 GPU 渲染。

## 任务

- [x] 1. 扩展 ColorOverlayRenderer 缓存属性与线程安全基础
  - [x] 1.1 在 ColorOverlayRenderer 中新增实时渲染缓存属性
    - 新增 `realtimeLock: NSLock`、`cachedInTexture`、`cachedDilatedMaskTexture`、`cachedOutTexture`、`cachedImageScale`、`cachedImageOrientation`、`isPrepared`、`overlayColor`、`weak mtkView` 属性
    - `overlayColor` 的 `didSet` 中检查 `isPrepared`，若为 true 则调用 `renderToView()`
    - 确保新增属性不影响现有 `applyOverlay` 方法的任何代码路径
    - _需求: 1.3, 2.1, 2.3, 5.1, 5.2, 6.1_

  - [x] 1.2 实现 `cleanupRealtimeCache` 方法
    - 在 `realtimeLock` 保护下将所有缓存纹理置 nil，`isPrepared` 设为 false
    - _需求: 1.4, 6.1_

- [x] 2. 实现预处理阶段（prepareForRealtimeRendering）
  - [x] 2.1 实现 `prepareForRealtimeRendering(image:expandRadius:)` 方法
    - 在 `realtimeLock` 保护下执行：释放旧缓存 → 创建 padded 画布 → CPU 泛洪生成 Mask → 创建 Metal 纹理 → GPU Pass 1 膨胀 → 缓存结果
    - 复用 `applyOverlay` 中已有的画布创建、泛洪填充、Pass 1 膨胀逻辑（提取像素、`generate_solid_mask`、`dilate_mask` 着色器调度）
    - 缓存 `inTexture`、`dilatedMaskTexture`、`outTexture`，记录 `image.scale` 和 `image.imageOrientation`
    - 成功时设置 `isPrepared = true` 并返回 `true`；Metal 设备不可用或纹理创建失败时返回 `false`
    - _需求: 1.1, 1.2, 1.3, 1.4, 1.5, 6.2_

  - [ ]* 2.2 编写属性测试：预处理缓存始终反映最后一次输入
    - **Property 1: 预处理缓存始终反映最后一次输入**
    - **验证: 需求 1.3, 1.4**

  - [ ]* 2.3 编写属性测试：未预处理状态下的操作防护
    - **Property 2: 未预处理状态下的操作防护**
    - **验证: 需求 2.3, 4.3**

- [x] 3. 实现实时渲染（renderToView）
  - [x] 3.1 实现 `renderToView()` 私有方法
    - 在 `realtimeLock` 保护下读取缓存纹理引用，解锁后执行 GPU 渲染
    - 从 `overlayColor` 提取 RGBA 分量，构造 `OverlayColor` 参数
    - 创建 command buffer + compute encoder，执行 `apply_color_overlay` 着色器：inTexture + dilatedMaskTexture → drawable.texture
    - 调用 `present(drawable)` + `commit()`，不调用 `waitUntilCompleted`（异步执行）
    - Guard 检查：`isPrepared`、缓存纹理非 nil、`mtkView`、`currentDrawable` 均有效
    - _需求: 2.1, 2.2, 2.4, 2.5, 6.1, 6.3_

- [x] 4. 检查点 - 确保预处理和实时渲染核心逻辑正确
  - 确保所有测试通过，如有疑问请向用户确认。

- [x] 5. 实现导出功能（exportCurrentResult）
  - [x] 5.1 实现 `exportCurrentResult()` 方法
    - 在 `realtimeLock` 保护下检查 `isPrepared` 和缓存纹理，未准备好时返回 nil
    - 创建独立的 command buffer，执行 `apply_color_overlay`：inTexture + dilatedMaskTexture → cachedOutTexture
    - 调用 `waitUntilCompleted` 确保 GPU 完成
    - 从 `outTexture` 读取像素数据（`getBytes`），创建 CGContext → CGImage → UIImage
    - 使用缓存的 `cachedImageScale` 和 `cachedImageOrientation` 构造最终 UIImage
    - _需求: 4.1, 4.2, 4.3, 4.4_

  - [ ]* 5.2 编写属性测试：导出图像保留原始元数据
    - **Property 3: 导出图像保留原始元数据**
    - **验证: 需求 4.2**

- [x] 6. 创建 MTKViewRepresentable
  - [x] 6.1 新建 `Source/Domain/Calendar/MTKViewRepresentable.swift`
    - 实现 `UIViewRepresentable`，在 `makeUIView` 中配置 MTKView：`isPaused = true`、`enableSetNeedsDisplay = true`、`framebufferOnly = false`、`isOpaque = false`
    - 设置 `renderer.mtkView = mtkView`
    - 实现 `Coordinator` 作为 `MTKViewDelegate`，`draw(in:)` 回调由 renderer 内部处理
    - 在 `dismantleUIView` 中将 delegate 设为 nil，释放 Metal 资源引用
    - _需求: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 7. 向后兼容验证
  - [x] 7.1 确认 `applyOverlay` 方法未被修改
    - 检查 `applyOverlay(to:color:expandRadius:)` 方法签名和实现保持不变
    - 确保 `applyOverlay` 使用独立的局部纹理，不访问任何缓存属性
    - 确保 `@Observable` 和 `@unchecked Sendable` 标记保持不变
    - _需求: 5.1, 5.2, 5.3_

  - [ ]* 7.2 编写属性测试：applyOverlay 与实时渲染缓存完全独立
    - **Property 4: applyOverlay 与实时渲染缓存完全独立**
    - **验证: 需求 5.2**

  - [ ]* 7.3 编写单元测试验证向后兼容
    - 测试 MTKView 配置（isPaused、enableSetNeedsDisplay、framebufferOnly）
    - 测试 dismantleUIView 清理逻辑
    - 测试 Metal 设备不可用时 prepareForRealtimeRendering 返回 false
    - _需求: 3.2, 3.4, 3.5, 1.5_

- [x] 8. 最终检查点 - 确保所有测试通过
  - 确保所有测试通过，如有疑问请向用户确认。

## 备注

- 标记 `*` 的任务为可选任务，可跳过以加速 MVP 交付
- 每个任务引用了具体的需求编号，确保可追溯性
- 检查点用于增量验证，确保每个阶段的正确性
- 属性测试验证通用正确性属性，单元测试验证具体示例和边界情况
- 修改文件：`app/LTApp/LTApp/Source/Domain/Calendar/ColorOverlayRenderer.swift`
- 新增文件：`app/LTApp/LTApp/Source/Domain/Calendar/MTKViewRepresentable.swift`
