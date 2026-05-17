//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation

enum LTBCrashRedactor {
    private static let emailPattern = try? NSRegularExpression(
        pattern: #"[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}"#,
        options: [.caseInsensitive]
    )
    private static let phonePattern = try? NSRegularExpression(
        pattern: #"(?<!\d)(?:\+?\d[\d -]{6,}\d)(?!\d)"#
    )

    static func redact(_ value: String, key: String? = nil, policy: LTBCrashRedactionPolicy) -> String {
        if let key {
            let normalizedKey = key.lowercased()
            switch policy.keyMode {
            case .blacklist:
                if policy.sensitiveKeys.contains(normalizedKey) {
                    return policy.replacement
                }
            case .whitelist:
                if policy.allowedKeys.contains(normalizedKey) == false {
                    return policy.replacement
                }
            }
        }

        var redacted = value
        if policy.redactEmails {
            redacted = replaceMatches(in: redacted, regex: emailPattern, with: policy.replacement)
        }
        if policy.redactPhoneNumbers {
            redacted = replaceMatches(in: redacted, regex: phonePattern, with: policy.replacement)
        }
        return redacted
    }

    static func redact(metadata: [String: String], policy: LTBCrashRedactionPolicy) -> [String: String] {
        metadata.reduce(into: [:]) { partialResult, pair in
            partialResult[pair.key] = redact(pair.value, key: pair.key, policy: policy)
        }
    }

    private static func replaceMatches(
        in input: String,
        regex: NSRegularExpression?,
        with replacement: String
    ) -> String {
        guard let regex else { return input }
        let range = NSRange(input.startIndex ..< input.endIndex, in: input)
        return regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: replacement)
    }
}
