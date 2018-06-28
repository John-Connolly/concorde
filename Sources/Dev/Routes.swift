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

let cars = [Car(wheels: 4, name: "Ford"), Car(wheels: 4, name: "Chevvy")]

let get = register(method: .GET)

let siteMap = [
    curry(users) <^> (path("users") *> string) <*> int |> get

]


func users(name: String, id: Int) -> (Request) -> AnyResponse {
    return { request in
        return "hello \(name)! your id is: \(id)" |> AnyResponse.init(item:)
    }
}




//let post = route(method: .POST)
//
//let hello = get("/hello") { req -> AnyResponse in
//    return AnyResponse(item: "hello word")
//}
//
//let vehicle = get("/car") { req -> AnyResponse in
//    return cars |> AnyResponse.init(item:)
//}
//
//let token = get("/loaderio-95e2de71ba5cfa095645d825903bc632/") { req -> AnyResponse in
//    return "loaderio-95e2de71ba5cfa095645d825903bc632" |> AnyResponse.init(item:)
//}
//
//let largerResp = get("/large") { req -> AnyResponse in
//    return AnyResponse(item: cars + cars + cars + cars + cars + cars)
//}
//
//let update = post("/update") { req -> AnyResponse in
//    return (req.body >>- utf8String <^> AnyResponse.init(item:)) ?? .error
//}
//
