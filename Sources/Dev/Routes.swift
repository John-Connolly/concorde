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

let siteMap = [
    curry(users) <^> (path("users") *> string) <*> int |> get,
    cars <^> path("cars") *> int |> get,
    hello |> pure <*> path("hello") *> end |> get
]

func hello() -> (Request) -> AnyResponse {
    return { req in
        return "hello world" |> AnyResponse.init(item:)
    }
}

func users(name: String, id: Int) -> (Request) -> AnyResponse {
    return { request in
        return "hello \(name)! your id is: \(id)" |> AnyResponse.init(item:)
    }
}

func cars(amount: Int) -> (Request) -> AnyResponse {
    return { req in
        return (1...amount).map { n in
            return Car(wheels: n, name: (n % 2 == 0 ? "Ford" : "GM"))
        } |> AnyResponse.init(item:)
    }
}

//let token = get("/loaderio-95e2de71ba5cfa095645d825903bc632/") { req -> AnyResponse in
//    return "loaderio-95e2de71ba5cfa095645d825903bc632" |> AnyResponse.init(item:)
//}

//let update = post("/update") { req -> AnyResponse in
//    return (req.body >>- utf8String <^> AnyResponse.init(item:)) ?? .error
//}
//
