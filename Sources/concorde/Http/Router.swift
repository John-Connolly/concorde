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
            return
        }
        response.write(AnyResponse(item: "Not Found", status: .notFound))
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


public typealias MiddleWare = (Request) -> Response

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
        var head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: response.status, headers: HTTPHeaders())
        head.headers.add(name: "Content-Type", value: response.contentType.rawValue)
        head.headers.add(name: "Content-Length", value: response.data.count |> String.init)
        return HTTPServerResponsePart.head(head)
    }

}
