//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Foundation
import CryptoKit
import LTNetwork

struct SSLPinningValidator: SSLPinningValidating {
    let isDisabled: Bool
    let pinnedPublicKeyHashes: [String]

    init(environment: AppEnvironment) {
        self.isDisabled = true //environment != .release
        self.pinnedPublicKeyHashes = environment.pinnedPublicKeyHashes
    }

    func validate(
        challenge: URLAuthenticationChallenge,
        environment: AppEnvironment
    ) -> SSLPinningResult {
        guard !isDisabled else { return .performDefaultHandling }

        guard challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust
        else {
            return .failure
        }
        let credential = URLCredential(trust: serverTrust)
        
        guard let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let serverCertificate = certificateChain.first,
              let publicKey = SecCertificateCopyKey(serverCertificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as? Data
        else {
            return .failure
        }

        let hash = SHA256.hash(data: publicKeyData)
        let hashBase64 = Data(hash).base64EncodedString()

        if pinnedPublicKeyHashes.contains(hashBase64) {
         
            return .success(credential)
        }
        return .failure
    }
}


extension AppEnvironment {
    
    var pinnedPublicKeyHashes: [String] {
        switch self {
        case .dev:
            return []
        case .stagging:
            return []
        case .release:
            return []
        }
    }

}
