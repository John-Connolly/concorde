////
////  Preperations.swift
////  Dev
////
////  Created by John Connolly on 2018-11-11.
////
//
import Foundation
import Redis
import SwiftQ

let preflightCheck: [(EventLoopGroup) -> Any] = [
    redisConn,
    swiftQConn
]

func redisConn(group: EventLoopGroup) -> Future<RedisClient> {
    return RedisClient.connect(on: group, onError: log)
}

func swiftQConn(group: EventLoopGroup) -> Future<Producer> {
    return SwiftQ.Producer.connect(on: group.eventLoop)
}

func log(_ err: Error) {
    print(err)
}
