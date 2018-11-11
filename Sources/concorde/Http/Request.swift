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

    public let stream = BodyStream()

    public init(_ eventLoop: EventLoop, head: HTTPRequestHead) {
        self.head = head
        self.eventLoop = eventLoop
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

public func decode<T: Decodable>(_ type: T.Type) -> (Data) -> T? {
    return { data in
        return try? JSONDecoder().decode(type, from: data)
    }
}
