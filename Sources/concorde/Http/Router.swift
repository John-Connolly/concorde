//
//  Router.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIO
import NIOHTTP1

public func router(register routes: [(Request) -> (AnyResponse?)]) -> (Request, (AnyResponse) -> ()) -> () {
    return { request, responder in
        for route in routes {
            guard let resp = route(request) else {
                continue
            }
            responder(resp)
            return
        }
        responder(.notFound)
    }
}

public func route(method: HTTPMethod) -> (String, @escaping (Request) -> (AnyResponse)) -> (Request) -> (AnyResponse?) {
    return { path, work in
        return { req in
            guard method == req.method else {
                return nil
            }
            guard req.head.uri.hasPrefix(path) else {
                return nil
            }
            return work(req)
        }
    }
}
