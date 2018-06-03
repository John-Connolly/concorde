//
//  AnyResponse.swift
//  concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation

public struct AnyResponse {
    let contentType: MimeType
    let data: Data
}

public extension AnyResponse {

    public init<T: Encodable>(item: T) {
        let data = try! JSONEncoder().encode(item)
        self.data = data
        self.contentType = .json
    }

    public init(item: String) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = .plain
    }

}
