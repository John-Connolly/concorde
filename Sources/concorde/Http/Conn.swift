//
//  Conn
//  concorde
//
//  Created by John Connolly on 2018-11-11.
//

import Foundation
import NIO

public typealias Middleware = (Conn) -> Future<Conn>

public final class Conn {

    let cache: ThreadCache
    let eventLoop: EventLoop
    public let request: Request
    public internal(set) var response: Response

    init(cache: ThreadCache,
         eventLoop: EventLoop,
         request: Request,
         response: Response) {
        self.cache = cache
        self.eventLoop = eventLoop
        self.request = request
        self.response = response
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
        return cache.items.first(where: { $0 as? EventLoopFuture<T> != nil } ) as! EventLoopFuture<T>
    }

    public func future<T>(_ f: @escaping () -> T) -> Future<T> {
        return eventLoop.newSucceededFuture(result: f())
    }

}

import NIOHTTP1

public func write(status: HTTPResponseStatus) -> Middleware {
    return { conn in
        conn.response.status = status
        return conn.future(conn)
    }
}

public func write(body: String) -> Middleware {
    return { conn in
        conn.response.data = body.data(using: .utf8) ?? Data()
        return conn.future(conn)
    }
}
