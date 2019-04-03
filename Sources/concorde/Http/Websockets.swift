//
//  Websockets.swift
//  concorde
//
//  Created by John Connolly on 2019-03-28.
//

import Foundation
import NIO
import NIOHTTP1
import NIOWebSocket

//private final class WebsocketHTTPHandler: ChannelInboundHandler, RemovableChannelHandler {
//    typealias InboundIn = HTTPServerRequestPart
//    typealias OutboundOut = HTTPServerResponsePart
//
//    private var responseBody: ByteBuffer!
//
//    var responseHandler: ((String) -> ())?
//
//    func channelRegistered(context: ChannelHandlerContext) {
//        responseHandler = { resp in
//            var buffer = context.channel.allocator.buffer(capacity: resp.utf8.count)
//            buffer.writeString(resp)
//            self.responseBody = buffer
//        }
//    }
//
//    func channelUnregistered(context: ChannelHandlerContext) {
//        self.responseBody = nil
//    }
//
//    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
//        let reqPart = self.unwrapInboundIn(data)
//
//        // We're not interested in request bodies here: we're just serving up GET responses
//        // to get the client to initiate a websocket request.
//        guard case .head(let head) = reqPart else {
//            return
//        }
//
//        // GETs only.
//        guard case .GET = head.method else {
//            self.respond405(context: context)
//            return
//        }
//
//        var headers = HTTPHeaders()
//        headers.add(name: "Content-Type", value: "text/html")
//        headers.add(name: "Content-Length", value: String(self.responseBody.readableBytes))
//        headers.add(name: "Connection", value: "close")
//        let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1),
//                                            status: .ok,
//                                            headers: headers)
//        context.write(self.wrapOutboundOut(.head(responseHead)), promise: nil)
//        context.write(self.wrapOutboundOut(.body(.byteBuffer(self.responseBody))), promise: nil)
//        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
//            context.close(promise: nil)
//        }
//        context.flush()
//    }
//
//    private func respond405(context: ChannelHandlerContext) {
//        var headers = HTTPHeaders()
//        headers.add(name: "Connection", value: "close")
//        headers.add(name: "Content-Length", value: "0")
//        let head = HTTPResponseHead(version: .init(major: 1, minor: 1),
//                                    status: .methodNotAllowed,
//                                    headers: headers)
//        context.write(self.wrapOutboundOut(.head(head)), promise: nil)
//        context.write(self.wrapOutboundOut(.end(nil))).whenComplete { (_: Result<Void, Error>) in
//            context.close(promise: nil)
//        }
//        context.flush()
//    }
//}
//
//private final class WebSocketTimeHandler: ChannelInboundHandler {
//    typealias InboundIn = WebSocketFrame
//    typealias OutboundOut = WebSocketFrame
//
//    private var awaitingClose: Bool = false
//
//    public func handlerAdded(context: ChannelHandlerContext) {
//        self.sendTime(context: context)
//    }
//
//    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
//        let frame = self.unwrapInboundIn(data)
//
//        switch frame.opcode {
//        case .connectionClose:
//            self.receivedClose(context: context, frame: frame)
//        case .ping:
//            self.pong(context: context, frame: frame)
//        case .text:
//            var data = frame.unmaskedData
//            let text = data.readString(length: data.readableBytes) ?? ""
//            print(text)
//        case .binary, .continuation, .pong:
//            // We ignore these frames.
//            break
//        default:
//            // Unknown frames are errors.
//            self.closeOnError(context: context)
//        }
//    }
//
//    public func channelReadComplete(context: ChannelHandlerContext) {
//        context.flush()
//    }
//
//    private func sendTime(context: ChannelHandlerContext) {
//        guard context.channel.isActive else { return }
//
//        // We can't send if we sent a close message.
//        guard !self.awaitingClose else { return }
//
//        let theTime = NIODeadline.now().uptimeNanoseconds
//        var buffer = context.channel.allocator.buffer(capacity: 12)
//        buffer.writeString("\(theTime)")
//
//        let frame = WebSocketFrame(fin: true, opcode: .text, data: buffer)
//        context.writeAndFlush(self.wrapOutboundOut(frame)).map {
//            context.eventLoop.scheduleTask(in: .seconds(1), { self.sendTime(context: context) })
//            }.whenFailure { (_: Error) in
//                context.close(promise: nil)
//        }
//    }
//
//    private func receivedClose(context: ChannelHandlerContext, frame: WebSocketFrame) {
//        // Handle a received close frame. In websockets, we're just going to send the close
//        // frame and then close, unless we already sent our own close frame.
//        if awaitingClose {
//            // Cool, we started the close and were waiting for the user. We're done.
//            context.close(promise: nil)
//        } else {
//            // This is an unsolicited close. We're going to send a response frame and
//            // then, when we've sent it, close up shop. We should send back the close code the remote
//            // peer sent us, unless they didn't send one at all.
//            var data = frame.unmaskedData
//            let closeDataCode = data.readSlice(length: 2) ?? context.channel.allocator.buffer(capacity: 0)
//            let closeFrame = WebSocketFrame(fin: true, opcode: .connectionClose, data: closeDataCode)
//            _ = context.write(self.wrapOutboundOut(closeFrame)).map { () in
//                context.close(promise: nil)
//            }
//        }
//    }
//
//    private func pong(context: ChannelHandlerContext, frame: WebSocketFrame) {
//        var frameData = frame.data
//        let maskingKey = frame.maskKey
//
//        if let maskingKey = maskingKey {
//            frameData.webSocketUnmask(maskingKey)
//        }
//
//        let responseFrame = WebSocketFrame(fin: true, opcode: .pong, data: frameData)
//        context.write(self.wrapOutboundOut(responseFrame), promise: nil)
//    }
//
//    private func closeOnError(context: ChannelHandlerContext) {
//        // We have hit an error, we want to close. We do that by sending a close frame and then
//        // shutting down the write side of the connection.
//        var data = context.channel.allocator.buffer(capacity: 2)
//        data.write(webSocketErrorCode: .protocolError)
//        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
//        context.write(self.wrapOutboundOut(frame)).whenComplete { (_: Result<Void, Error>) in
//            context.close(mode: .output, promise: nil)
//        }
//        awaitingClose = true
//    }
//}
