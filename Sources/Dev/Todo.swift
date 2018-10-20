//
//  Todo.swift
//  Dev
//
//  Created by John Connolly on 2018-07-03.
//

import Foundation
import concorde

struct TodoItem: Codable {
    let contents: String
    let title: String
}


/// Post req
func addItem(req: Request) -> Future<Response> {
    return req.body
        <^> decode(TodoItem.self)
        <^> Response.init
}

func csvStream(req: Request) -> Future<Response> {
    let promise: Promise<Response> = req.promise()
    let csvStream = CSVStream()
    req.stream.connect(to: csvStream)
    csvStream.done = {
        promise.succeed(result: "Hello" |> Response.init)
    }
    return promise.futureResult
}
