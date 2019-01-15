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

func addToQueue(with conn: Conn) -> Future<Int> {
    let producer = conn.cached(SwiftQ.Producer.self)

    let tasks = (1...500).map { _ in
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


struct Deploy: Task {


    let args: [String]

    func execute(loop: EventLoop) -> EventLoopFuture<()> {
        let task = Process()
        task.launchPath = "/bin/sh"//"/Users/johnconnolly/documents/opensource/concorde"//"/root/concorde"
        task.arguments = args

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: String.Encoding.utf8)
        //        print(output)
        task.waitUntilExit()
        return loop.newSucceededFuture(result: ())
    }

}


func addTask<T: Task>(task: T, with conn: Conn) -> Future<Int> {
    let producer = conn.cached(SwiftQ.Producer.self)

    return producer.then { producer in
        producer.enqueue(task: task)
    }
}

func deploy(conn: Conn) -> Future<Conn> {
    struct Response: Codable {
        let queued: Int
    }
    let resp = addTask(task: Deploy(args: ["/root/concorde/deploy.sh"]), with: conn).map(Response.init)

    func writeBody(conn: Conn) -> Future<Conn> {
        return resp >>- { write(body: $0)(conn) }
    }

    return (write(status: .ok) >=> writeBody)(conn)
}
