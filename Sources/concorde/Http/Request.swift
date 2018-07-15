//
//  Request.swift
//  concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation
import NIO
import NIOHTTP1

public final class Request {
    public let head: HTTPRequestHead
    public let body: Data?
    public let eventLoop: EventLoop

    public let stream = BodyStream()

    public init(_ eventLoop: EventLoop, head: HTTPRequestHead, body: Data?) {
        self.head = head
        self.body = body
        self.eventLoop = eventLoop
    }

    public var method: HTTPMethod {
        return head.method
    }

    public func future<T>(_ t: T) -> Future<T> {
        return eventLoop.newSucceededFuture(result: t)
    }
}

public func decode<T: Decodable>(_ type: T.Type) -> (Data) -> T? {
    return { data in
        return try? JSONDecoder().decode(type, from: data)
    }
}
