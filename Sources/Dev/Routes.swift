//
//  Routes.swift
//  Dev
//
//  Created by John Connolly on 2018-06-07.
//

import Foundation
import concorde

struct Car: Encodable {
    let wheels: Int
    let name: String
}

let utf8String = .utf8 |> flip(curry(String.init(data:encoding:)))

let cars = [Car(wheels: 4, name: "Ford"), Car(wheels: 4, name: "Chevvy")]

let get = route(method: .GET)
let post = route(method: .POST)

let hello = get("/hello") { req -> AnyResponse in
    return AnyResponse(item: "hello word")
}

let vehicle = get("/car") { req -> AnyResponse in
    print("Car called!")
    return AnyResponse(item: cars)
}

let largerResp = get("/large") { req -> AnyResponse in
    return AnyResponse(item: cars + cars + cars + cars + cars + cars)
}


let update = post("/update") { req -> AnyResponse in
    let body = req.body.flatMap(utf8String)
    return AnyResponse(item: body ?? "")
}

