//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

class AppleIDSignInViewModel: ObservableObject, @unchecked Sendable {
    private let service: any AppDataServiceful
    
    init(service: any AppDataServiceful) {
        self.service = service
    }
    
    func login(appleId: String, authToken: String) async {
        do {
           let user = try await service.authUseCasse.execute(appleId: appleId, authToken: authToken)
            print(user)
        } catch {
            print("error:\(error)")
        }
    }
}
