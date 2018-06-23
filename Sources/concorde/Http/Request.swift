//
//  Request.swift
//  concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation
import NIOHTTP1

public struct Request {
    public let head: HTTPRequestHead
    public let body: Data?

    public init(head: HTTPRequestHead, body: Data?) {
        self.head = head
        self.body = body
    }

    public var method: HTTPMethod {
        return head.method
    }
}
