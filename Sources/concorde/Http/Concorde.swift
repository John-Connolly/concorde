import Foundation
import NIO
import NIOHTTP1

public let concorde = create >>> start


private func create(
    router: @escaping (Conn, (EventLoopFuture<Conn>) -> ()) -> (),
    other: String
    ) -> String {

    return ""
}
//
//// Fix this!!
private func start(_ bootstrap: String) {

}
