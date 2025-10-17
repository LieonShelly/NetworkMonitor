//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import UIKit

final class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    var keyboardShown: Bool {
        return keyboardHeight > 0
    }
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        Publishers.Merge(willShow, willHide)
            .receive(on: DispatchQueue.main)
            .assign(to: &$keyboardHeight)

    }
}
