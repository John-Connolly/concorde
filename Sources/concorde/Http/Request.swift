//
//  Request.swift
//  concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation
import NIO
import NIOHTTP1

public struct Request {
    public let head: HTTPRequestHead
    public let eventLoop: EventLoop
    let cache: ThreadCache

    public let stream = BodyStream()

    public init(_ eventLoop: EventLoop, head: HTTPRequestHead, cache: ThreadCache) {
        self.head = head
        self.eventLoop = eventLoop
        self.cache = cache
    }

    public var method: HTTPMethod {
        return head.method
    }

    public func future<T>(_ t: T) -> Future<T> {
        return eventLoop.newSucceededFuture(result: t)
    }

    public func promise<T>() -> Promise<T> {
        return eventLoop.newPromise()
    }

    public func wrap(f: () -> ResponseRepresentable) -> Future<Response> {
        return future(f().resp)
    }

    public func cached<T>(_ type: T.Type) -> EventLoopFuture<T> {
        return cache.items.compactMap { $0 as? EventLoopFuture<T> }.first!
    }

    /// Reads the entire body into memory then returns it.
    public var body: Future<Data> {
        let promise: Promise<Data> = self.promise()
        stream.connect(to: BodySink { data in
            promise.succeed(result: data)
        })
        return promise.futureResult
    }

    public func future<T>(_ f: @escaping () -> T) -> Future<T> {
        return eventLoop.newSucceededFuture(result: f())
    }

}

public func decode<T: Decodable>(_ type: T.Type) -> (Data) -> Result<T> {
    return { data in
        return Result {
            try JSONDecoder().decode(type, from: data)
        }
    }
}
