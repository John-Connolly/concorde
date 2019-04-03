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
    let router: (Conn, (EventLoopFuture<Conn>) -> ()) -> ()

    var state = ServerState.idle
    let threadVariable: ThreadSpecificVariable<ThreadCache>

    init(with router: @escaping (Conn, (EventLoopFuture<Conn>) -> ()) -> (),
        and threadVariable: ThreadSpecificVariable<ThreadCache>
        ) {
        self.router = router
        self.threadVariable = threadVariable
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let serverRequestPart = unwrapInboundIn(data)
        switch serverRequestPart {
        case .head(let header):
            let cache = threadVariable.currentValue!
            if header.method == .GET {
                let request = Request(head: header)
                let conn = Conn(
                    cache: cache,
                    eventLoop: context.eventLoop,
                    request: request,
                    response: .empty
                )
                router(conn, write(context))
                state.recievedGetRequest()
                return
            }

            let request = Request(head: header)
            let conn = Conn(
                cache: cache,
                eventLoop: context.eventLoop,
                request: request,
                response: .empty
            )
            state.receivedHead(header, conn: conn)
            router(conn, write(context))
        case .body(let body):
            switch state {
            case .idle, .sendingResponse:
                break
            case .waitingForRequestBody(_, let conn): ()
//                conn.stream.yeild(.input(body))
            }
        case .end:
            switch state {
            case .idle, .sendingResponse:
                break
            case .waitingForRequestBody(_, let conn):
//                conn.stream.yeild(.complete)
                state.done()
            }
        }
    }

    func write(_ context: ChannelHandlerContext) -> (EventLoopFuture<Conn>) -> () {
        return { response in
            response
                .map { resp in
                    self.write(resp.response, on: context)
                }
                .whenFailure { error in
                    if let error = error as? ResponseError {
                        switch error {
                        case .internalServerError:
                            () // TODO: Handle these!
                        case .abort:
                            ()
                        case .custom(let response):
                            self.write(response, on: context)
                        }
                    } else {
                        let resp = Response.error(error)
                        self.write(resp, on: context)
                    }
            }
        }
    }

    private func write(_ response: Response, on context: ChannelHandlerContext) {
        context.write(self.wrapOutboundOut(.head(self.head(response))), promise: .none)
        var buffer = context.channel.allocator.buffer(capacity: response.data.count)

        switch response.data {
        case .data(let data):
             buffer.writeBytes(data)
            self.writeAndflush(buffer: buffer, context: context)
        case .byteBuffer(var bytes):
            buffer.writeBuffer(&bytes)
            self.writeAndflush(buffer: buffer, context: context)
        case .stream(let stream): ()
//            _ = stream.connect(
//                to: Sink<Data>(drain: { input in
//                    switch input {
//                    case .input(_):
////                        buffer.write(bytes: data)
//                        context.writeAndFlush(
//                            self.wrapOutboundOut(.body(.byteBuffer(buffer))),
//                            promise: .none
//                        )
//                        buffer.clear()
//                    case .complete:
//                        context.writeAndFlush(self.wrapOutboundOut(.end(.none)), promise: nil)
//                    case .error:
//                        ()
//                    }
//                })
//            )
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        context.close(promise: nil)
    }

    private func writeAndflush(buffer: ByteBuffer, context: ChannelHandlerContext) {
        context.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: .none)
        context.writeAndFlush(self.wrapOutboundOut(.end(.none)), promise: .none)
    }

    private func head(_ response: Response) -> HTTPResponseHead {
        var head = HTTPResponseHead(
            version: .init(major: 1, minor: 1),
            status: response.status,
            headers: HTTPHeaders()
        )
        head.headers.add(name: "Content-Type", value: response.contentType.rawValue)
        if response.data.isStreamed {
            head.headers.add(name: "Transfer-Encoding", value: "chunked")
        } else {
            head.headers.add(name: "Content-Length", value: String(response.data.count))
        }
        response.headers.forEach { head.headers.add(name: $0.key, value: $0.value) }
        return head
    }
}
