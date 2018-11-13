//
//  Conn
//  concorde
//
//  Created by John Connolly on 2018-11-11.
//

import Foundation
import NIO

typealias Middleware = (Conn) -> Future<Conn>

public final class Conn {

    let cache: ThreadCache
    public let request: Request
    public let response: Response

    init(cache: ThreadCache,
         request: Request,
         response: Response) {
        self.cache = cache
        self.request = request
        self.response = response
    }

    public func cached<T>(_ type: T.Type) -> EventLoopFuture<T> {
        return cache.items.compactMap { $0 as? EventLoopFuture<T> }.first!
    }

}
