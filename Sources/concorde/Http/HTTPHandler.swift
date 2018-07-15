//
//  HTTPHandler.swift
//  concorde
//
//  Created by John Connolly on 2018-06-28.
//

import Foundation
import NIO
import NIOHTTP1

final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    let router: (Request, (AnyResponse) -> ()) -> ()

    var state = ServerState.idle

    init(with router: @escaping (Request, (AnyResponse) -> ()) -> ()) {
        self.router = router
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let serverRequestPart = unwrapInboundIn(data)

        switch serverRequestPart {
        case .head(let header):
            if header.method == .GET {
                router(Request(head: header, body: nil), write(ctx))
                state.recievedGetRequest()
                return
            }
            state.receivedHead(header, request: Request(head: header, body: nil)) // Fix body
        case .body(let body):
            switch state {
            case .idle, .sendingResponse: break
            case .waitingForRequestBody(_,let request): ()

//                request.stream?(body)
//                router(request, write(ctx))


//                print("recieved data", body.readableBytes)
//                let data = body.getBytes(at: 0, length: body.readableBytes).flatMap(Data.init)

//                Request(head: header, body: nil), write(ctx)
            }
        case .end:
            print("end")
            state.done() /// BUG: close connection!
        }
    }

    func write(_ ctx: ChannelHandlerContext) -> (AnyResponse) -> () {
        return { response in
            print(response)
//            _ = ctx.write(self.wrapOutboundOut(.head(self.head(response))), promise: nil)
//            var buffer = ctx.channel.allocator.buffer(capacity: response.data.count)
//            buffer.write(bytes: response.data)
//            self.writeAndflush(buffer: buffer, ctx: ctx)
        }
    }

    private func writeAndflush(buffer: ByteBuffer, ctx: ChannelHandlerContext) {
        ctx.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        ctx.writeAndFlush(wrapOutboundOut(.end(nil)), promise: nil)
    }

    private func head(_ response: AnyResponse) -> HTTPResponseHead {
        var head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: response.status, headers: HTTPHeaders())
        head.headers.add(name: "Content-Type", value: response.contentType.rawValue)
        head.headers.add(name: "Content-Length", value: response.data.count |> String.init)
        return head
    }

}



