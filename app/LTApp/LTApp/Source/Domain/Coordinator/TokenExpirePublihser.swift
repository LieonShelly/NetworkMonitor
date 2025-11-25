//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import Foundation

protocol TokenExpirePublihser {
    var expired: AnyPublisher<Void, Never> { get }
}

protocol RootViewProviding {
    var root: CurrentValueSubject<AppRootType, Never> { get }
}


class RootViewProvider: RootViewProviding {
    private let tokenProvider: any TokenProvider
    private let tokenExpired: any TokenExpirePublihser
    private var cancellables: Set<AnyCancellable> = .init()
    
    let root: CurrentValueSubject<AppRootType, Never>
    
    init(tokenProvider: any TokenProvider, tokenExpired: any TokenExpirePublihser) {
        self.tokenProvider = tokenProvider
        self.tokenExpired = tokenExpired
        if tokenProvider.refreshToken != nil {
            root = .init(.home(.init(overLayData: nil)))
        } else {
            root = .init(.preHome)
        }
        
        tokenExpired.expired
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.root.value = .preHome
            }
            .store(in: &cancellables)
    }
}
