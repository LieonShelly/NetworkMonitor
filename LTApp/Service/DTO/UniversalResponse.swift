//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct UniversalResponse<T: Decodable>: Decodable, UniversalResponseType {
    public let success: Bool
    public let message: String?
    public let data: T
    
    public init(success: Bool, message: String, data: T) {
        self.success = success
        self.message = message
        self.data = data
    }
}

public struct UniversalEmptyResponse: Decodable {
    public let success: Bool
    public let message: String?
    
    public init(message: String?, success: Bool) {
        self.success = success
        self.message = message
    }
}

public struct UniversalListResponse<T: Decodable>: Decodable, UniversalResponseType {
    let success: Bool
    let message: String?
    let data: [T]?
    
    let pageNum: Int?
    let pageSize: Int?
    let pages: Int?
    let count: Int?
    let total: Int?
    
    var multipageModel: MultipageModel {
        .init(pageNum: pageNum ?? 0,
              pageSize: pageSize ?? 0,
              pages: pages ?? 0,
              count: count ?? 0,
              total: total ?? 0)
    }
}

public struct MultipageModel: Decodable {
    public let pageNum: Int
    public let pageSize: Int
    public let pages: Int
    public let count: Int
    public let total: Int
  
    public var hasMore: Bool { pageNum < pages }
    public var nextPage: ListRequest {
        .init(pageNum: pageNum + 1, pageSize: pageSize)
    }
    
    public init(pageNum: Int, pageSize: Int, pages: Int, count: Int, total: Int) {
        self.pageNum = pageNum
        self.pageSize = pageSize
        self.pages = pages
        self.count = count
        self.total = total
    }
}

protocol UniversalResponseType: Decodable {
    associatedtype T: Decodable 
    var success: Bool { get }
    var message: String? { get }
    var data: T { get }
}

public struct ListRequest: Encodable, Sendable {
    let pageNum: Int
    let pageSize: Int
}
