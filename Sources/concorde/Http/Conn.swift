//
//  Conn
//  concorde
//
//  Created by John Connolly on 2018-11-11.
//

import Foundation
import NIO

public typealias Middleware = (Conn) -> EventLoopFuture<Conn>

public final class Conn {
    
    private let cache: ThreadCache
    public let eventLoop: EventLoop
    public let request: Request
    public internal(set) var response: Response
    
//    let stream = BodyStream()

    init(
        cache: ThreadCache,
        eventLoop: EventLoop,
        request: Request,
        response: Response
        ) {
        self.cache = cache
        self.eventLoop = eventLoop
        self.request = request
        self.response = response
    }
    
    var threadPool: NIOThreadPool {
        return cache.get()
    }
    
    public func future<T>(_ t: T) -> EventLoopFuture<T> {
        return eventLoop.makeSucceededFuture(t)
    }
    
    public func promise<T>() -> EventLoopPromise<T> {
        return eventLoop.makePromise()
    }
    
    public func cached<T>(_ type: T.Type) -> EventLoopFuture<T> {
        return cache.get()
    }
    
    public func future<T>(_ f: @escaping () -> T) -> EventLoopFuture<T> {
        return eventLoop.makeSucceededFuture(f())
    }
    
    public func failed<T>(with error: Error) -> EventLoopFuture<T> {
        return eventLoop.makeFailedFuture(error)
    }
    
    public func failed<T>(with error: ResponseError) -> EventLoopFuture<T> {
        return eventLoop.makeFailedFuture(error)
    }
    
    // Reads the entire body into memory then returns it.
    public var body: EventLoopFuture<Data> {
        let promise: EventLoopPromise<Data> = self.promise()
//        _ = stream.connect(to: BodySink { data in
//            promise.succeed(data)
//        })
        return promise.futureResult
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
        conn.response.data = .data(Data(body.utf8))
        return conn.future(conn)
    }
}

public func write(body: String, contentType: MimeType) -> Middleware {
    return { conn in
        conn.response.data = .data(Data(body.utf8))
        conn.response.contentType = contentType
        return conn.future(conn)
    }
}

public func write(body: Data, contentType: MimeType) -> Middleware {
    return { conn in
        conn.response.data = .data(body)
        conn.response.contentType = contentType
        return conn.future(conn)
    }
}

public func write<T: Codable>(body: T) -> Middleware {
    return { conn in
        switch encode(body) {
        case .success(let value):
            conn.response.data = .data(value)
            conn.response.contentType = .json
            return conn.future(conn)
        case .failure(let error):
            return conn.failed(with: error)
        }
    }
}

public func redirect(to uri: String) -> Middleware {
    return { conn in
        conn.response.status = .seeOther
        conn.response.headers["Location"] = uri
        return conn.future(conn)
    }
}

//public func stream<C: Consumer>(to stream: C) -> (Conn) -> C {
//    return { conn in
//          return conn.stream.connect(to: stream)
////        return conn.future(conn)
//    }
//}

public func decode<T: Decodable>(_ type: T.Type) -> (Data) -> Result<T, Error> {
    return { data in
        return Result { try JSONDecoder().decode(type, from: data) }
    }
}

public func encode<T: Encodable>(_ item: T) -> Result<Data, Error> {
    return Result {
        return try JSONEncoder().encode(item)
    }
}
