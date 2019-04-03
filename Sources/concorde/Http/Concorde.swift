import Foundation
import NIO
import NIOHTTP1

public let concorde = create >>> start

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount) //System.coreCount
private func create(
    router: @escaping (Conn, (EventLoopFuture<Conn>) -> ()) -> (),
    config: Configuration
    ) -> String {
    return ""
}
//
//// Fix this!!
private func start(_ bootstrap: String) {
    
}
