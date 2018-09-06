import Foundation
import NIO
import NIOHTTP1

public let concorde = create >>> start

private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

private func create(router: @escaping (Request, (Future<AnyResponse>) -> ()) -> ()) -> ServerBootstrap {
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
//        .childChannelOption(ChannelOptions.autoRead, value: false)
        .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
        .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    return bootstrap
}

private func start(_ bootstrap: ServerBootstrap) -> Reader<Configuration, Never> {
    return Reader<Configuration, Never> { config in
        Result(bootstrap.bind(host: "localhost", port: config.port).wait)
            .flatMap { channel -> Result<Void> in
                print("Server running on:", channel.localAddress ?? "")
                return Result(channel.closeFuture.wait)
            }.onError { error in
                fatalError("Could not start Sever:\(error)")
            }
        exit(0)
    }
}
