//
//  Todo.swift
//  Dev
//
//  Created by John Connolly on 2018-07-03.
//

import Foundation
import concorde

struct TodoItem: Codable {
    let id: String
    let contents: String
    let title: String

    init(contents: String, title: String) {
        self.contents = contents
        self.title = title
        self.id = UUID().uuidString.prefix(10) |> String.init
    }
}


let db = KeyValueStore<String, TodoItem>()

/// Post req
func addItem() -> (Request) -> Future<AnyResponse> {
    return { req in
        return req.body
            <^> decode(TodoItem.self)
            <^> AnyResponse.init
    }
}


func csvStream() -> (Request) -> Future<AnyResponse> {
    return { req in
        let promise: Promise<AnyResponse> = req.promise()
        let csvStream = CSVStream()
        req.stream.output(to: csvStream)
        csvStream.done = {
            promise.succeed(result: "Hello" |> AnyResponse.init)
        }
        return promise.futureResult
    }
}

func allTodoItems() -> (Request) -> AnyResponse {
    return { req in
        return db.all() |> AnyResponse.init
    }
}

