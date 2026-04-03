//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

/// 分页加载状态
enum PaginationState: Equatable {
    case idle
    case loading
    case error(String)
}

/// 加载更多 Footer 的显示状态
enum LoadMoreState: Equatable {
    case idle
    case loading
    case noMore
    case error(String)
}

@MainActor
final class Paginator<T: Sendable>: ObservableObject {
    typealias FetchPage = (_ cursor: String?) async throws -> ([T], PaginationInfo)

    @Published private(set) var items: [T] = []
    @Published private(set) var state: PaginationState = .idle
    @Published private(set) var hasMore: Bool = true

    private var nextCursor: String?
    private let fetchPage: FetchPage

    init(fetchPage: @escaping FetchPage) {
        self.fetchPage = fetchPage
    }

    func loadFirst() async {
        state = .loading
        items = []
        nextCursor = nil
        
        do {
            let (newItems, pagination) = try await fetchPage(nil)
            items = newItems
            hasMore = pagination.hasMore
            nextCursor = pagination.nextCursor
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func loadMore() async {
        guard hasMore, state != .loading else { return }

        state = .loading

        do {
            let (newItems, pagination) = try await fetchPage(nextCursor)
            items.append(contentsOf: newItems)
            hasMore = pagination.hasMore
            nextCursor = pagination.nextCursor
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    var loadMoreState: LoadMoreState {
        switch state {
        case .loading:
            return items.isEmpty ? .idle : .loading
        case .error(let message):
            return .error(message)
        case .idle:
            return hasMore ? .idle : .noMore
        }
    }
}

import SwiftUI
import UIComponent

public struct FixedHeader<Trailing: View>: View {
    let title: String
    let size: HeaderSize
    var backAction: (() -> Void)? = nil
    @ViewBuilder let trailing: (() -> Trailing)
    
    public init(title: String,
                size: HeaderSize = .plain,
                backAction: (() -> Void)? = nil,
                @ViewBuilder trailing:  @escaping (() -> Trailing) = { EmptyView() } ) {
        self.title = title
        self.backAction = backAction
        self.trailing = trailing
        self.size = size
    }
    
    public enum HeaderSize {
        case plain
        case large
        
        var height: CGFloat {
            switch self {
            case .plain:
                return 72
            case .large:
                return 100
            }
        }
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            HStack {
                if let backAction {
                    backBtn.onTapGesture {
                        backAction()
                    }
                }
            }
            .frame(width: 32, height: 32)
            
            titleView
            
            HStack {
                trailing()
            }
            .frame(width: 32, height: 32)
           
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(AppColor.oat)
    }
    
    var backBtn: some View {
        Image(.back)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
    
    var titleView: some View {
        Text(title)
            .textStyle(font: .heading)
            .lineSpacing(0)
            .frame(maxWidth: .infinity)
            .background(Color.random)
    }
}

struct FixedHeaderPage: View {
    var body: some View {
        VStack {
            FixedHeader(title: "header")
            FixedHeader(title: "header") {}
            
            FixedHeader(title: "header", backAction: { }, trailing: {
                Image(.library)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            })
            
            FixedHeader(title: "What is one little thing that make you happy today?", size: .large)
            
            FixedHeader(title: "What is one little thing that make you happy today?", size: .large) {
                
            }
            FixedHeader(title: "What is one little thing that make you happy today?",
                        size: .large,
                        backAction: {},
                        trailing: {
                Image(.library)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            })
            
            FixedHeader(title: "What is one little thing?", size: .large)
            
            FixedHeader(title: "What is one little thing?", size: .large) {
                
            }
            FixedHeader(title: "What is one little thing?",
                        size: .large,
                        backAction: {},
                        trailing: {
                Image(.library)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            })

        }
        .background(Color.random)
        
    }
}
