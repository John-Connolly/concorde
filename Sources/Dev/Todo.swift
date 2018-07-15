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
func addItem() -> (Request) -> AnyResponse {
    return { req in

        req.stream = { bytes in
            print(bytes.readableBytes)
        }
        
//         return (req.body >>- decode(TodoItem.self))
//            .map { item in
//                db.add(key: item.id, value: item)
//            }.map {
//                return db.all().count |> (String.init >>> AnyResponse.init)
//            } ?? .error
        return .error
    }
}

func allTodoItems() -> (Request) -> AnyResponse {
    return { req in
        return db.all() |> AnyResponse.init
    }
}

