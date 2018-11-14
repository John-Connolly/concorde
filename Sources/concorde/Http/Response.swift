//
//  Response.swift
//  concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIOHTTP1

public struct Response {
    public let contentType: MimeType
    public var status: HTTPResponseStatus = .ok
    public internal(set) var data: Data

    public static var error: Response {
        return .init(contentType: .plain,
                     status: .badRequest,
                     data: "Bad request".data(using: .utf8) ?? Data())
    }

    public static var notFound: Response {
        return .init(item: "Not Found",
                     status: .notFound)
    }

    public static func error(_ error: Error) -> Response {
        return  .init(contentType: .plain,
                      status: .badRequest,
                      data: error.localizedDescription.data(using: .utf8) ?? Data())
    }
}

public extension Response {

    public init<T: Encodable>(_ item: T) {
        guard let data = try? JSONEncoder().encode(item) else {
            self = .error
            return
        }
        self.data = data
        self.contentType = .json
    }

    public init(_ item: String) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = .plain
    }

    public init(item: String, type: MimeType) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = type
    }

    public init(item: String, status: HTTPResponseStatus) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = .plain
        self.status = status
    }

}

public protocol ResponseRepresentable {
    var resp: Response { get }
}

extension ResponseRepresentable where Self: Codable {

    public var resp: Response {
        return Response(self)
    }
    
}

extension String: ResponseRepresentable {

    public var resp: Response {
        return Response(self)
    }
}
