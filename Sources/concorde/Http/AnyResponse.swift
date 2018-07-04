//
//  AnyResponse.swift
//  concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIOHTTP1

public struct AnyResponse {
    let contentType: MimeType
    var status: HTTPResponseStatus = .ok
    let data: Data

    public static var error: AnyResponse {
        return .init(contentType: .plain,
                     status: .badRequest,
                     data: "Bad request".data(using: .utf8) ?? Data())
    }

    public static var notFound: AnyResponse {
        return .init(item: "Not Found",
                     status: .notFound)
    }
}

public extension AnyResponse {

    public init<T: Encodable>(_ item: T) {
        self.data = (try? JSONEncoder().encode(item)) ?? Data()
        self.contentType = .json
    }

    public init(_ item: String) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = .plain
    }

    public init(item: String, status: HTTPResponseStatus) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = .plain
        self.status = status
    }

}
