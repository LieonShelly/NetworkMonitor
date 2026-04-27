//
//  RiveFileType.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/27.
//

import Foundation
import RiveRuntime
import LTCommon

public enum RiveFileType: String, CaseIterable, @unchecked Sendable {
    case lockAnimated = "lock-animated"
    case lockTapped = "lock-tapped"
}

@MainActor
public protocol RiveResourceType {
    /// 预加载所有已注册的 Rive 文件资源
    func preloadResources()

    /// 获取指定类型的 Rive File（已缓存则直接返回）
    /// 每个调用方应使用返回的 File 自行创建独立的 Rive 实例
    func file(type: RiveFileType, bundle: Bundle) async throws -> File
}

extension RiveResourceType {
    func file(type: RiveFileType) async throws -> File {
        try await file(type: type, bundle: .main)
    }
}
