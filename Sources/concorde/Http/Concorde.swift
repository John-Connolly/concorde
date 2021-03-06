import Foundation
import NIO
import NIOHTTP1

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

public func takeOff(
    router: @escaping (Conn, (Future<Conn>) -> ()) -> (),
    config: Configuration
    ) -> Never {
    
    let variable = ThreadSpecificVariable<ThreadCache>()

    for _ in 0..<System.coreCount {
        let loop = group.next()
        
        loop.submit {
            var cons = config.resources.map { $0(loop) }
            let threadPool = NIOThreadPool(numberOfThreads: 1)
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
        .serverChannelOption(
            ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR),
            value: 1
        )
        
        .childChannelInitializer { channel in
            // Ensure we don't read faster then we can write by adding the BackPressureHandler into the pipeline.
            channel
                .pipeline
                .configureHTTPServerPipeline(withPipeliningAssistance: true)
                .flatMap { _ in
                    channel.pipeline
                        .addHandler(BackPressureHandler())
                        .flatMap { _ in
                            channel.pipeline.addHandler(HTTPHandler(
                                with: router,
                                and: variable
                            ))
                    }
            }
        }
        
        // Enable TCP_NODELAY and SO_REUSEADDR for the accepted Channels
        .childChannelOption(
            ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY),
            value: 1
        )
        .childChannelOption(
            ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR),
            value: 1
        )
        .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        .childChannelOption(
            ChannelOptions.recvAllocator,
            value: AdaptiveRecvByteBufferAllocator()
    )


    let channel = try! bootstrap
        .bind(host: "localhost", port: config.port)
        .wait()
    try! channel.closeFuture.wait()
    exit(0)
}
