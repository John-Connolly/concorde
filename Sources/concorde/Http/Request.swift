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

    public let stream = BodyStream()

    public init(head: HTTPRequestHead) {
        self.head = head
    }

    public var method: HTTPMethod {
        return head.method
    }

    /// Reads the entire body into memory then returns it.
//    public var body: Future<Data> {
//        let promise: Promise<Data> = self.promise()
//        stream.connect(to: BodySink { data in
//            promise.succeed(result: data)
//        })
//        return promise.futureResult
//    }

}

public func decode<T: Decodable>(_ type: T.Type) -> (Data) -> Result<T> {
    return { data in
        return Result {
            try JSONDecoder().decode(type, from: data)
        }
    }
}
