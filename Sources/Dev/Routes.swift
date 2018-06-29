//
//  Routes.swift
//  Dev
//
//  Created by John Connolly on 2018-06-07.
//

import Foundation
import concorde

struct Car: Codable {
    let wheels: Int
    let name: String
}

let utf8String = .utf8 |> flip(curry(String.init(data:encoding:)))
let verifyToken = "loaderio-95e2de71ba5cfa095645d825903bc632.txt"

let siteMap = [
    curry(users) <^> (path("users") *> string) <*> int |> get,
    cars <^> (path("cars") *> UInt) |> get,
    pure(hello) <*> (path("hello") *> end) |> get,
    pure(verify) <*> (path(verifyToken) *> end) |> get,
    pure(update) <*> (path("post") *> end) |> post,
]

func users(name: String, id: Int) -> (Request) -> AnyResponse {
    return { request in
        return "hello \(name)! your id is: \(id)" |> AnyResponse.init(item:)
    }
}

func hello() -> (Request) -> AnyResponse {
    return { req in
        return "hello world" |> AnyResponse.init(item:)
    }
}


func cars(amount: UInt) -> (Request) -> AnyResponse {
    return { req in
        return amount < 1000 ? (0...amount).map { n in
            return Car(wheels: Int(n), name: (n % 2 == 0 ? "Ford" : "GM"))
        } |> AnyResponse.init(item:) : ("To many cars" |> AnyResponse.init(item:))
    }
}

func verify() -> (Request) -> AnyResponse {
    return { req in
        return "loaderio-95e2de71ba5cfa095645d825903bc632" |> AnyResponse.init(item:)
    }
}

/// Post req
func update() -> (Request) -> AnyResponse {
    return { req in
        return (req.body >>- utf8String <^> AnyResponse.init(item:)) ?? .error
    }
}
