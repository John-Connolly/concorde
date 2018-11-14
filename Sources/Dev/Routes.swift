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

let siteMap = [
//    curry(users) <^> (path("users") *> string) <*> int |> get, //users/john/234
//    pure(unzurry(hello)) <*> (path("hello") *> end) |> get,
    pure(unzurry(verify)) <*> (path(verifyToken) *> end) |> get,
//    pure(unzurry(update)) <*> (path("post") *> end) |> post,
//    curry(sendNums) <^> (path("nums") *> UInt) |> get,
//    curry(page) <^> (path("welcome") *> string) |> get,
//    pure(unzurry(signUp)) <*> (path("register") *> end) |> post,
//    curry(items) <^> (path("items") *> int) |> get,
]


//func users(name: String, id: Int, req: Request) -> Future<Response> {
//    return "hello \(name)! your id is: \(id)" |> Response.init |> req.future
//}

let verifyToken = "loaderio-95e2de71ba5cfa095645d825903bc632.txt"

func verify(conn: Conn) -> Future<Conn> {
    let token = "loaderio-95e2de71ba5cfa095645d825903bc632"
    return (write(status: .ok) >=> write(body: token))(conn)
}
