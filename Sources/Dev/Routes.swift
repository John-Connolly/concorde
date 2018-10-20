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


let siteMap = [   //cars/20
    curry(users) <^> (path("users") *> string) <*> int |> get, //users/john/234
    curry(cars) <^> (path("cars") *> UInt) |> get,
    pure(unzurry(hello)) <*> (path("hello") *> end) |> get,
    pure(unzurry(verify)) <*> (path(verifyToken) *> end) |> get,
    pure(unzurry(update)) <*> (path("post") *> end) |> post,
    pure(unzurry(addCar)) <*> (path("addCar") *> end) |> post,
    pure(unzurry(csvStream)) <*> (path("csv") *> end) |> post,
    pure(unzurry(addItem)) <*> (path("addItem") *> end) |> post,
//    pure(allTodoItems) <*> (path("allTodos") *> end) |> get,
]

func users(name: String, id: Int, req: Request) -> Future<Response> {
    return "hello \(name)! your id is: \(id)" |> Response.init |> req.future
}

func hello(req: Request) -> Future<Response> {
    return "hello world" |> Response.init |> req.future
}

func cars(amount: UInt, req: Request) -> Future<Response> {
    return (amount < 500_000
        ? (0...amount)
            .map { n in
                return Car(wheels: Int(n), name: (n % 2 == 0 ? "Ford" : "GM"))
            } |> Response.init
        : ("To many cars" |> Response.init)) |> req.future
}

func verify(req: Request) -> Future<Response> {
    return "loaderio-95e2de71ba5cfa095645d825903bc632"
            |> Response.init
            |> req.future
}

///// Post req
func update(req: Request) -> Future<Response> {
    return req.body <^> utf8String <^> Response.init
}

/// Post req
func addCar(req: Request) -> Future<Response> {
    let promise: Promise<Response> = req.promise()
    let csvStream = CSVStream()
    req.stream.connect(to: csvStream)
    csvStream.done = {
        promise.succeed(result: Response.init("Hello"))
    }
    return promise.futureResult //(req.body <^> decode(Car.self) <^> Response.init)
}


//enum Sitemap {
//
//    case usersRoute
//
//
//    var route: (Request) -> Future<AnyResponse>? {
//        switch self {
//        case .usersRoute:
//            return  curry(users) <^> (path("users") *> string) <*> int |> get
//        }
//    }
//
//}
