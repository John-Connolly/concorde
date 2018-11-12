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
    curry(users) <^> (path("users") *> string) <*> int |> get, //users/john/234
//    curry(cars) <^> (path("cars") *> UInt) |> get,
    pure(unzurry(redisRoute)) <*> (path("redis") *> end) |> get,
    pure(unzurry(hello)) <*> (path("hello") *> end) |> get,
    pure(unzurry(verify)) <*> (path(verifyToken) *> end) |> get,
    pure(unzurry(update)) <*> (path("post") *> end) |> post,
    curry(sendNums) <^> (path("nums") *> UInt) |> get,
    curry(page) <^> (path("welcome") *> string) |> get,
    pure(unzurry(signUp)) <*> (path("register") *> end) |> post,
    curry(items) <^> (path("items") *> int) |> get,
]

func users(name: String, id: Int, req: Request) -> Future<Response> {
    return "hello \(name)! your id is: \(id)" |> Response.init |> req.future
}

func hello(req: Request) -> Future<Response> {
    return "hello world" |> Response.init |> req.future
}

//func cars(amount: UInt, req: Request) -> Future<Response> {
//    return (amount < 500_000
//        ? (0...amount)
//            .map { n in
//                return Car(wheels: Int(n), name: (n % 2 == 0 ? "Ford" : "GM"))
//            } |> Response.init
//        : ("To many cars" |> Response.init)) |> req.future
//}

func verify(req: Request) -> Future<Response> {
    return "loaderio-95e2de71ba5cfa095645d825903bc632"
            |> Response.init
            |> req.future
}

///// Post req
func update(req: Request) -> Future<Response> {
    return req.body <^> utf8String <^> Response.init
}



struct Num: Codable {
    let n: UInt
}

func sendNums(n: UInt, req: Request) -> Future<Response> {
    return req.future {
        (0...n).map(Num.init) |> Response.init
    }
}

func testRoute() -> Resp<String> {
    return impure("Hello!")
}
