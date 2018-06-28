import Foundation
import NIO
import NIOHTTP1

public let concorde = create >>> start

private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

private func create(router: @escaping (Request, (AnyResponse) -> ()) -> ()) -> ServerBootstrap {
    // Specify backlog and enable SO_REUSEADDR for the server itself
    let bootstrap = ServerBootstrap(group: group)
    .serverChannelOption(ChannelOptions.backlog, value: 256)
        .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

        // Set the handlers that are appled to the accepted Channels
        .childChannelInitializer { channel in
            // Ensure we don't read faster then we can write by adding the BackPressureHandler into the pipeline.
            channel.pipeline.configureHTTPServerPipeline().then { _ in
                channel.pipeline.add(handler: BackPressureHandler()).then { _ in
                    channel.pipeline.add(handler: HTTPHandler(with: router))
                }
            }
        }

        // Enable TCP_NODELAY and SO_REUSEADDR for the accepted Channels
        .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
        .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    return bootstrap
}

private func start(_ bootstrap: ServerBootstrap) -> Reader<Configuration, Never> {
    return Reader<Configuration, Never> { config in
        Try(bootstrap.bind(host: "localhost", port: config.port).wait)
            .flatMap { channel -> Try<Void> in
                print("Server running on:", channel.localAddress ?? "")
                return Try(channel.closeFuture.wait)
            }.onError { error in
                fatalError("Could not start Sever:\(error)")
            }
        exit(0)
    }
}


enum ServerState {
    case idle
    case waitingForRequestBody(HTTPRequestHead)
    case sendingResponse


    mutating func recievedGetRequest() {
        self = .sendingResponse
    }

    mutating func receivedHead(_ head: HTTPRequestHead) {
        self = .waitingForRequestBody(head)
    }

    mutating func done() {
        self = .idle
    }
}


final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    let router: (Request, (AnyResponse) -> ()) -> ()

    var state = ServerState.idle

    init(with router: @escaping (Request, (AnyResponse) -> ()) -> ()) {
        self.router = router
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let request = unwrapInboundIn(data)
        switch request {
        case .head(let header):
            if header.method == .GET {
                router(Request(head: header, body: nil), write(ctx))
                state.recievedGetRequest()
                return
            }
            state.receivedHead(header)
        case .body(let body):
            switch state {
            case .idle, .sendingResponse: break
            case .waitingForRequestBody(let header):
                let data = body.getBytes(at: 0, length: body.readableBytes).flatMap(Data.init)
                router(Request(head: header, body: data), write(ctx))
            }
        case .end:
            state.done() /// BUG: close connection!
        }
    }

    func write(_ ctx: ChannelHandlerContext) -> (AnyResponse) -> () {
        return { response in
            _ = ctx.write(self.wrapOutboundOut(.head(self.head(response))), promise: nil)
            var buffer = ctx.channel.allocator.buffer(capacity: response.data.count)
            buffer.write(bytes: response.data)
            self.writeAndflush(buffer: buffer, ctx: ctx)
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
