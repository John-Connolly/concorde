//
//  Response.swift
//  concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIO
import NIOHTTP1

public enum ResponseStorage {
    case data(Data)
    case byteBuffer(ByteBuffer)
    case stream(ChunkedStream)

    var count: Int {
        switch self {
        case .data(let data):
            return data.count
        case .byteBuffer(let buffer):
            return buffer.readableBytes
        case .stream(_):
            return 0
        }
    }

    var isStreamed: Bool {
        switch self {
        case .data: return false
        case .byteBuffer: return false
        case .stream: return true
        }
    }
}

public struct Response {
    public internal(set) var contentType: MimeType
    public var status: HTTPResponseStatus = .ok
    public var headers: [String: String] = [:]
    public internal(set) var data: ResponseStorage


    public static var error: Response {
        return .init(contentType: .plain,
                     status: .badRequest,
                     headers: [:],
                     data: .data(Data("Bad request".utf8)))
    }

    public static var notFound: Response {
        return .init(item: "Not Found",
                     status: .notFound)
    }

    public static var empty: Response {
        return .init(contentType: .plain,
                     status: .ok,
                     headers: [:],
                     data: .data(Data()))
    }

    public static func error(_ error: Error) -> Response {
        return  .init(contentType: .plain,
                      status: .badRequest,
                      headers: [:],
                      data: .data(Data(error.localizedDescription.utf8)))
    }

    public static var unauthorized: Response {
        return .init(item: "Unauthorized",
                     status: .unauthorized)
    }
}

public extension Response {

    init<T: Encodable>(_ item: T) {
        guard let data = try? JSONEncoder().encode(item) else {
            self = .error
            return
        }
        self.data = .data(data)
        self.contentType = .json
    }

    init(_ item: String) {
        self.data = .data(Data(item.utf8))
        self.contentType = .plain
    }

    init(item: String, type: MimeType) {
        self.data = .data(Data(item.utf8))
        self.contentType = type
    }

    init(item: String, status: HTTPResponseStatus) {
        self.data = .data(Data(item.utf8))
        self.contentType = .plain
        self.status = status
    }

}
