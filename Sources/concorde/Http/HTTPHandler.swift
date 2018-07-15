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
    let router: (Request, (Future<AnyResponse>) -> ()) -> ()

    var state = ServerState.idle

    init(with router: @escaping (Request, (Future<AnyResponse>) -> ()) -> ()) {
        self.router = router
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let serverRequestPart = unwrapInboundIn(data)

        switch serverRequestPart {
        case .head(let header):
            if header.method == .GET {
                router(Request(ctx.eventLoop, head: header, body: nil), write(ctx))
                state.recievedGetRequest()
                return
            }

            let request = Request(ctx.eventLoop, head: header, body: nil)
            state.receivedHead(header, request: request) // Fix body
            router(request, write(ctx))
        case .body(let body):
            switch state {
            case .idle, .sendingResponse: break
            case .waitingForRequestBody(_,let request):
                request.stream.input(.input(body))
            }
        case .end:
            switch state {
            case .idle, .sendingResponse: break
            case .waitingForRequestBody(_,let request): ()
                request.stream.input(.end)
            state.done()
            }
        }
    }

    func write(_ ctx: ChannelHandlerContext) -> (Future<AnyResponse>) -> () {
        return { response in
            _ = response.map { resp in
                ctx.write(self.wrapOutboundOut(.head(self.head(resp))), promise: nil)
                var buffer = ctx.channel.allocator.buffer(capacity: resp.data.count)
                buffer.write(bytes: resp.data)
                self.writeAndflush(buffer: buffer, ctx: ctx)
            }
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
