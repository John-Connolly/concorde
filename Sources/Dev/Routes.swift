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

let cars = [Car(wheels: 4, name: "Ford"), Car(wheels: 4, name: "Chevvy")]

let get = route(method: .GET)
let hello = get("/hello") { req -> AnyResponse in
    return AnyResponse(item: "hello word")
}

let vehicle = get("/car") { req -> AnyResponse in
    return AnyResponse(item: cars)
}

let lots = cars + cars + cars + cars + cars + cars

let largerResp = get("/large") { req -> AnyResponse in
    return AnyResponse(item: lots)
}
