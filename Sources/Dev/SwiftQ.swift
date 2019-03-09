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
        
        return loop.newSucceededFuture(result: ())
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

func addTask() -> Middleware {
    return { conn in 
        struct Response: Codable {
            let queued: Int
        }
        let resp = addToQueue(with: conn).map(Response.init)
        
        func writeBody(conn: Conn) -> Future<Conn> {
            return resp >>- { write(body: $0)(conn) }
        }
        
        return (write(status: .ok) >=> writeBody)(conn)
    }
}


struct Deploy: Task {
    
    
    let args: [String]
    
    func execute(loop: EventLoop) -> EventLoopFuture<()> {
        return loop.newSucceededFuture(result: ())
    }
    
}


func addTask<T: Task>(task: T, with conn: Conn) -> Future<Int> {
    let producer = conn.cached(SwiftQ.Producer.self)
    
    return producer.then { producer in
        producer.enqueue(task: task)
    }
}

func deploy() -> Middleware {
    return { conn in
        struct Response: Codable {
            let queued: Int
        }
        
        let resp = addTask(task: Deploy(args: ["/root/concorde/deploy.sh"]), with: conn).map(Response.init)
        
        func writeBody(conn: Conn) -> Future<Conn> {
            return resp >>- { write(body: $0)(conn) }
        }
        
        return (write(status: .ok) >=> writeBody)(conn)
    }
}
