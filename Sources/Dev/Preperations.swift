////
////  Preperations.swift
////  Dev
////
////  Created by John Connolly on 2018-11-11.
////
//
import Foundation
import Redis

let preflightCheck: [(EventLoopGroup) -> Any] = [
    redisConn,
]

func redisConn(group: EventLoopGroup) -> Future<RedisClient> {
    return RedisClient.connect(on: group, onError: log)
}

func log(_ err: Error) {
    print(err)
}

//import PostgreSQL
//
//func psqlConn(group: EventLoopGroup) -> Future<PostgreSQLConnection> {
//    let config = PostgreSQLDatabaseConfig(hostname: "localhost", username: "johnconnolly")
//    return PostgreSQLDatabase(config: config).newConnection(on: group)
//}
//

