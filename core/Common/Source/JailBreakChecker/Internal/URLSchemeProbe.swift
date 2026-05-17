//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import UIKit


@inline(__always)
func evaluateURLSchemeRisk() -> Int {
    guard Thread.isMainThread else { return 0 }

    var score = 0
    for encryptedScheme in ObfuscatedURLScheme.all {
        var schemeStr = xorDecrypt(encryptedScheme, key: kXORKey)
        defer { eraseString(&schemeStr) }
        guard let url = URL(string: schemeStr) else { continue }
        if UIApplication.shared.canOpenURL(url) {
            score += 10
        }
    }
    return score
}
