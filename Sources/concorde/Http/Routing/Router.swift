//
//  Router.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIO
import NIOHTTP1

public func router(register routes: [Route<Middleware>]) -> (Conn, (Future<Conn>)
    -> ())
    -> () {
        return { conn, responder in
            for route in routes {
                guard let route = route.run(conn.request.head.uri, method: conn.request.method)?.0 else {
                    continue
                }
                responder(route(conn))
                return
            }

            conn.response = .notFound
            responder(conn.future(conn))
            return
        }
}
