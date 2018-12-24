////
////  Middleware.swift
////  Dev
////
////  Created by John Connolly on 2018-07-13.
////
//
//import Foundation
//import concorde
//import Redis
//
//func redis(conn: Conn) -> Future<RedisClient> {
//    return conn.cached(RedisClient.self)
//}
//
//func redisQuery(_ client: RedisClient, id: Int) -> Future<RedisData> {
//    return client.rawGet("\(id)")
//}
//
//func authorize(req: Request) -> Future<Response>? {
//    return .none
//}
//
////let getRedis = redis >=> curry(redisQuery)
//
////func redisRoute(req: Request) -> Future<Response> {
//////    return getRedis(req).map { data in
//////        return Response(data.string ?? "")
//////    }
////}
