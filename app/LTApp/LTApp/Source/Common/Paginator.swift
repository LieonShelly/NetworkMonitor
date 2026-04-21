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
