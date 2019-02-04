import Foundation
import NIO
import NIOHTTP1

public let concorde = create >>> start

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

private func create(router: @escaping (Conn, (Future<Conn>) -> ()) -> (),
                    config: Configuration) -> ServerBootstrap {

    let variable = ThreadSpecificVariable<ThreadCache>()

    for _ in 0..<System.coreCount {
        let loop = group.next()

        loop.submit {
            var cons = config.resources.map { $0(loop) }
            let threadPool = BlockingIOThreadPool(numberOfThreads: 1)
            threadPool.start()
            cons.append(threadPool as Any)
            variable.currentValue = ThreadCache(items: cons)
        }.whenFailure { error in
            fatalError("Could not boot eventloop: \(error)")
        }
    }

    // Specify backlog and enable SO_REUSEADDR for the server itself
    let bootstrap = ServerBootstrap(group: group)
    .serverChannelOption(ChannelOptions.backlog, value: 256)
        .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

        // Set the handlers that are appled to the accepted Channels
        .childChannelInitializer { channel in
            // Ensure we don't read faster then we can write by adding the BackPressureHandler into the pipeline.
            channel.pipeline.configureHTTPServerPipeline(withPipeliningAssistance: false).then { _ in
                channel.pipeline.add(handler: BackPressureHandler()).then { _ in
                    channel.pipeline.add(handler: HTTPHandler(with: router, and: variable))
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

// Fix this!!
private func start(_ bootstrap: ServerBootstrap) -> Reader<Configuration, Never> {
    return Reader<Configuration, Never> { config in
        print("Listening on localhost:\(config.port)")
        let channel = try! bootstrap.bind(host: "localhost", port: config.port).wait()
        try! channel.closeFuture.wait()
        exit(0)
    }
}
