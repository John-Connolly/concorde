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
    let router: (Request, (Future<Response>) -> ()) -> ()

    var state = ServerState.idle
    let threadVariable: ThreadSpecificVariable<ThreadCache>

    init(with router: @escaping (Request, (Future<Response>) -> ()) -> (),
         and threadVariable: ThreadSpecificVariable<ThreadCache>) {
        self.router = router
        self.threadVariable = threadVariable
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let serverRequestPart = unwrapInboundIn(data)
        switch serverRequestPart {
        case .head(let header):
            let cache = threadVariable.currentValue!
            if header.method == .GET {
                router(Request(ctx.eventLoop, head: header, cache: cache), write(ctx))
                state.recievedGetRequest()
                return
            }

            let request = Request(ctx.eventLoop, head: header, cache: cache)
            state.receivedHead(header, request: request) // Fix body
            router(request, write(ctx))
        case .body(let body):
            switch state {
            case .idle, .sendingResponse: break
            case .waitingForRequestBody(_,let request):
                request.stream.yeild(.input(body))
            }
        case .end:
            switch state {
            case .idle, .sendingResponse: break
            case .waitingForRequestBody(_,let request): ()
                request.stream.yeild(.complete)
            state.done()
            }
        }
    }


    func write(_ ctx: ChannelHandlerContext) -> (Future<Response>) -> () {
        return { response in
            response.map { resp in
                self.write(resp, on: ctx)
            }.whenFailure { error in
                let resp = Response.error(error)
                self.write(resp, on: ctx)
            }
        }
    }

    private func write(_ response: Response, on ctx: ChannelHandlerContext) {
        ctx.write(self.wrapOutboundOut(.head(self.head(response))), promise: nil)
        var buffer = ctx.channel.allocator.buffer(capacity: response.data.count)
        buffer.write(bytes: response.data)
        self.writeAndflush(buffer: buffer, ctx: ctx) // save os calls here
    }

    private func writeAndflush(buffer: ByteBuffer, ctx: ChannelHandlerContext) {
        ctx.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: .none)
        ctx.writeAndFlush(wrapOutboundOut(.end(nil)), promise: .none)
    }

    private func head(_ response: Response) -> HTTPResponseHead {
        var head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: response.status, headers: HTTPHeaders())
        head.headers.add(name: "Content-Type", value: response.contentType.rawValue)
        head.headers.add(name: "Content-Length", value: String(response.data.count))
        return head
    }

}
