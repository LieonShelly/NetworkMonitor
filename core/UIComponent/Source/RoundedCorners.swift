//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.modifier(RoundedCorners(radius: radius, corners: corners))
    }
}

public struct RoundedCorners: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    public func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangleWithCorners(radius: radius, corners: corners))
    }
}

public struct RoundedRectangleWithCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }
    
    public  func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
