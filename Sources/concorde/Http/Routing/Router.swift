//
//  Router.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIO
import NIOHTTP1

public let get = register(method: .GET)
public let post = register(method: .POST)

public func router(register routes: [(Conn) -> (Future<Conn>?)])
    -> (Conn, (Future<Conn>)
    -> ())
    -> () {
    return { conn, responder in
        for route in routes {
            guard let resp = route(conn) else {
                continue
            }
            responder(resp)
            return
        }
        responder(conn.future(conn))
    }
}

public func register(method: HTTPMethod)
    -> (Route<(Conn) -> Future<Conn>>)
    -> (Conn)
    -> Future<Conn>? {
        return { route in
            return { conn in
                guard conn.request.method == method else {
                    return nil
                }

                guard let matchedRoute = route.run(conn.request.head.uri)?.0 else {
                    return nil
                }
                return matchedRoute(conn)
            }
        }
}
