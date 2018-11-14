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

    public func cached<T>(_ type: T.Type) -> Future<T> {
        return cache.items.first(where: { $0 as? Future<T> != nil } ) as! Future<T>
    }

    public func future<T>(_ f: @escaping () -> T) -> Future<T> {
        return eventLoop.newSucceededFuture(result: f())
    }

    public func failed<T>(with error: Error) -> Future<T> {
        return eventLoop.newFailedFuture(error: error)
    }

    public func failed<T>(with error: ResponseError) -> Future<T> {
        return eventLoop.newFailedFuture(error: error)
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

public func write<T: Codable>(body: T) -> Middleware {
    return { conn in
        switch encode(body) {
        case .success(let value):
            conn.response.data = value
            conn.response.contentType = .json
            return conn.future(conn)
        case .failure(let error):
            return conn.failed(with: error)
        }
    }
}

public func decode<T: Decodable>(_ type: T.Type) -> (Data) -> Result<T> {
    return { data in
        return Result {
            try JSONDecoder().decode(type, from: data)
        }
    }
}

public func encode<T: Encodable>(_ item: T) -> Result<Data> {
    return Result {
        return try JSONEncoder().encode(item)
    }
}
