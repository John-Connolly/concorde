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

public func router(register routes: [(Request) -> (Future<Response>?)])
    -> (Request, (Future<Response>)
    -> ())
    -> () {
    return { request, responder in
        for route in routes {
            guard let resp = route(request) else {
                continue
            }
            responder(resp)
            return
        }
        responder(.notFound |> request.future)
    }
}

public func register(method: HTTPMethod)
    -> (Route<(Request) -> Future<Response>>)
    -> (Request)
    -> Future<Response>? {
        return { route in
            return { req in
                guard req.method == method else {
                    return nil
                }

                guard let matchedRoute = route.run(req.head.uri)?.0 else {
                    return nil
                }
                return matchedRoute(req)
            }
        }
}