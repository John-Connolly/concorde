//
//  Router.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIO
import NIOHTTP1

public func router(register routes: [(Request) -> (AnyResponse?)]) -> (Request, Response) -> () {
    return { request, response in
        for route in routes {
            guard let resp = route(request) else {
                continue
            }
            response.write(resp)
        }

    }
}

public struct AnyResponse {
    let contentType: String
    let data: Data
}

public extension AnyResponse {

    public init<T: Encodable>(item: T) {
        let data = try! JSONEncoder().encode(item)
        self.data = data
        self.contentType = "application/json"
    }

    public init(item: String) {
        self.data = item.data(using: .utf8) ?? Data()
        self.contentType = "text/plain"
    }

}

public func route(method: HTTPMethod) -> (String, @escaping (Request) -> (AnyResponse)) -> (Request) -> (AnyResponse?) {
    return { path, work in
        return { req in
            guard method == req.method else {
                return nil
            }
            guard req.head.uri.hasPrefix(path) else {
                return nil
            }
            return work(req)
        }
    }
}


public typealias MiddleWare = (Request) -> Request

// Currently just for a get request.
// Need to include body data here.
public struct Request {
    let head: HTTPRequestHead

    public init(head: HTTPRequestHead) {
        self.head = head
    }

    public var method: HTTPMethod {
        return head.method
    }
}

public struct Response {

    let channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }

    func write(_ response: AnyResponse) {
        _ = head(response) |> channel.writeAndFlush
        var buffer = channel.allocator.buffer(capacity: response.data.count)
        buffer.write(bytes: response.data)
        let part = HTTPServerResponsePart.body(.byteBuffer(buffer))
        _ = channel.writeAndFlush(part).map {
            _ = self.channel.writeAndFlush(HTTPServerResponsePart.end(nil)).map {
                    self.channel.close()
            }
        }
    }

    private func head(_ response: AnyResponse) -> HTTPPart<HTTPResponseHead, IOData> {
        var head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: HTTPHeaders())
        head.headers.add(name: "Content-Type", value: response.contentType)
        head.headers.add(name: "Content-Length", value: response.data.count |> String.init)
        return HTTPServerResponsePart.head(head)
    }

}
