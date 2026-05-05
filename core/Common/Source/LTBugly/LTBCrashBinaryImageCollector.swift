//
//  LTBCrashBinaryImageCollector.swift
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

import Darwin
import Foundation
import MachO

enum LTBCrashBinaryImageCollector {
    static func collect() -> [LTBCrashReport.BinaryImage] {
        let count = _dyld_image_count()
        guard count > 0 else { return [] }

        return (0 ..< count).compactMap { index in
            guard let namePointer = _dyld_get_image_name(index),
                  let header = _dyld_get_image_header(index)
            else {
                return nil
            }

            let path = String(cString: namePointer)
            let name = URL(fileURLWithPath: path).lastPathComponent
            let slide = UInt64(bitPattern: Int64(_dyld_get_image_vmaddr_slide(index)))

            return .init(
                name: name,
                uuid: uuid(for: header),
                baseAddress: String(format: "0x%016llx", slide),
                size: imageSize(for: header),
                path: path
            )
        }
    }

    static func collectLegacyImageDetails() -> [(name: String, uuid: String?, baseAddress: String, size: UInt64?, path: String)] {
        collect().map {
            (
                name: $0.name,
                uuid: $0.uuid,
                baseAddress: $0.baseAddress,
                size: $0.size,
                path: $0.path
            )
        }
    }

    private static func uuid(for header: UnsafePointer<mach_header>) -> String? {
        var cursor = UnsafeRawPointer(header).advanced(by: MemoryLayout<mach_header_64>.size)

        for _ in 0 ..< header.pointee.ncmds {
            let loadCommand = cursor.assumingMemoryBound(to: load_command.self).pointee
            if loadCommand.cmd == LC_UUID {
                let uuidCommand = cursor.assumingMemoryBound(to: uuid_command.self).pointee
                let bytes = uuidCommand.uuid
                let parts = [
                    bytes.0, bytes.1, bytes.2, bytes.3,
                    bytes.4, bytes.5,
                    bytes.6, bytes.7,
                    bytes.8, bytes.9,
                    bytes.10, bytes.11, bytes.12, bytes.13, bytes.14, bytes.15
                ]
                return String(
                    format: "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
                    parts[0], parts[1], parts[2], parts[3],
                    parts[4], parts[5],
                    parts[6], parts[7],
                    parts[8], parts[9],
                    parts[10], parts[11], parts[12], parts[13], parts[14], parts[15]
                )
            }
            cursor = cursor.advanced(by: Int(loadCommand.cmdsize))
        }

        return nil
    }

    private static func imageSize(for header: UnsafePointer<mach_header>) -> UInt64? {
        var cursor = UnsafeRawPointer(header).advanced(by: MemoryLayout<mach_header_64>.size)
        var size: UInt64 = 0

        for _ in 0 ..< header.pointee.ncmds {
            let loadCommand = cursor.assumingMemoryBound(to: load_command.self).pointee
            if loadCommand.cmd == LC_SEGMENT_64 {
                let segment = cursor.assumingMemoryBound(to: segment_command_64.self).pointee
                size += segment.vmsize
            }
            cursor = cursor.advanced(by: Int(loadCommand.cmdsize))
        }

        return size == 0 ? nil : size
    }
}
