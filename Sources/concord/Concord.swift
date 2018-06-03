import NIO
import NIOHTTP1

public let concord = create >>> start

private let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

private func create(router: @escaping (Request, Response) -> ()) -> ServerBootstrap {
    let reuseAddrOpt = ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR)
    let bootstrap = ServerBootstrap(group: loopGroup)
        .serverChannelOption(ChannelOptions.backlog, value: 1000) // TODO: Make backlog configurable?
        .serverChannelOption(reuseAddrOpt, value: 1)
        .childChannelInitializer { channel in
            channel.pipeline.configureHTTPServerPipeline().then { _ in
                channel.pipeline.add(handler: HTTPHandler(with: router))
            }
        }
        .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
        .childChannelOption(reuseAddrOpt, value: 1)
        .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
    return bootstrap
}

private func start(_ bootstrap: ServerBootstrap) -> Reader<Configuration, Never> {
    return Reader<Configuration, Never> { config in
        Try(bootstrap.bind(host: "localhost", port: config.port).wait)
            .flatMap { channel -> Try<Void> in
                print("Server running on:", channel.localAddress!)
                return Try(channel.closeFuture.wait)
            }.onError { error in
                fatalError("Could not start Sever:\(error)")
            }
        exit(0)
    }
}


final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart

    let router: (Request, Response) -> ()

    init(with router: @escaping (Request, Response) -> ()) {
        self.router = router
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let request = unwrapInboundIn(data)
        let channel = ctx.channel
        switch request {
        case .head(let header):
            router(Request(head: header), Response(channel: channel))
        case .body, .end: break
        }
    }

    private func head() -> HTTPPart<HTTPResponseHead, IOData> {
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: HTTPHeaders())
        return HTTPServerResponsePart.head(head)
    }
}
