//
//  HTMLPages.swift
//  Dev
//
//  Created by John Connolly on 2018-11-11.
//

import Foundation
import concorde
import Html

func generate(with name: String) -> Node {
    let welcome = "Welcome! \(name)"
    return html([
        body([
            h1([.raw(welcome)]),
            p(["You have found our site!"])
        ])
    ])
}


func page(name: String, req: Request) -> Future<Response> {
    return generate(with: name)
            |> render
            |> flip(curry(Response.init(item:type:)))(.html)
            |> req.future
}


import Redis

func redis(req: Request) -> Future<RedisClient> {
    return req.cached(RedisClient.self)
}

func redisQuery(_ client: RedisClient) -> Future<RedisData> {
    return client.rawGet("hello")
}

let getRedis = redis >=> redisQuery

func redisRoute(req: Request) -> Future<Response> {
    return getRedis(req).map { data in
        return Response(data.string ?? "")
    }
}
