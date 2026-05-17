//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import RiveRuntime
import Common

struct SendableFile: @unchecked Sendable {
    let file: File
}

@MainActor
class RiveResource: RiveResourceType, @unchecked Sendable {
    private var cache: [String: File] = [:]
    private var inFlightTasks: [String: Task<SendableFile, Error>] = [:]

    func preloadResources() {
        let resources = RiveFileType.allCases
        Task {
            for resource in resources {
                _ = try? await self.file(type: resource, bundle: .main)
            }
        }
    }

    func file(type: RiveFileType, bundle: Bundle) async throws -> File {
        let name = type.rawValue
        if let cached = cache[name] {
            return cached
        }

        if let existing = inFlightTasks[name] {
            return try await existing.value.file
        }

        let task = Task<SendableFile, Error> {
            let worker = try await Worker()
            let file = try await File(source: .local(name, bundle), worker: worker)
            return SendableFile(file: file)
        }

        inFlightTasks[name] = task

        do {
            let result = try await task.value
            cache[name] = result.file
            inFlightTasks.removeValue(forKey: name)
            return result.file
        } catch {
            inFlightTasks.removeValue(forKey: name)
            throw error
        }
    }
}
