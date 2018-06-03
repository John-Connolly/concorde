//
//  Router.swift
//  concord
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIO
import NIOHTTP1

public func router(register routes: [(Request) -> (String?)]) -> (Request, Response) -> () {
    return { request, response in
        for route in routes {
            guard let resp = route(request) else {
                continue
            }
            response.write(resp)
        }

    }
}

public func route(method: HTTPMethod) -> (String, @escaping (Request) -> (String)) -> (Request) -> (String?) {
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

    func write(_ string: String) {
        _ = head() |> channel.writeAndFlush
        var buffer = channel.allocator.buffer(capacity: string.utf8.count)
        buffer.write(bytes: string.utf8)
        let part = HTTPServerResponsePart.body(.byteBuffer(buffer))
        _ = channel.writeAndFlush(part).map {
            _ = self.channel.writeAndFlush(HTTPServerResponsePart.end(nil)).map {
                    self.channel.close()
            }
        }
    }

    private func head() -> HTTPPart<HTTPResponseHead, IOData> {
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: HTTPHeaders())
        return HTTPServerResponsePart.head(head)
    }

}
