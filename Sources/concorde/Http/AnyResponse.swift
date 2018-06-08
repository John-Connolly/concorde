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
}

public extension AnyResponse {

    public init<T: Encodable>(item: T) {
        self.data = (try? JSONEncoder().encode(item)) ?? Data()
        self.contentType = .json
    }

    public init(item: String) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = .plain
    }

    public init(item: String, status: HTTPResponseStatus) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = .plain
        self.status = status
    }

}
