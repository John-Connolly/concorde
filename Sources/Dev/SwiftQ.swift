//
//  SwiftQ.swift
//  Dev
//
//  Created by John Connolly on 2019-01-08.
//

import Foundation
import concorde
import NIO
import SwiftQ

struct Email: Task {

    let email: String

    func execute(loop: EventLoop) -> EventLoopFuture<()> {

        let promise: EventLoopPromise<()> = loop.newPromise()
        _ = loop.scheduleTask(in: TimeAmount.seconds(1)) {
            promise.succeed(result: ())
        }
        return promise.futureResult //loop.newSucceededFuture(result: ())
    }

}


func addToQueue(with conn: Conn) -> EventLoopFuture<Int> {
    let producer = conn.cached(SwiftQ.Producer.self)
    let tasks = (1...30_000).map { _ in
        Email(email: "Hello@hello.com")
    }
    return producer.then { producer in
        producer.enqueue(tasks: tasks)
    }
}

func addTask(conn: Conn) -> Future<Conn> {
    struct Response: Codable {
        let queued: Int
    }
    let resp = addToQueue(with: conn).map(Response.init)

    func writeBody(conn: Conn) -> Future<Conn> {
        return resp >>- { write(body: $0)(conn) }
    }
    
    return (write(status: .ok) >=> writeBody)(conn)
}
