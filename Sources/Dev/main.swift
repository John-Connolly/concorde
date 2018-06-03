import Foundation
import concorde

struct Car: Encodable {
    let wheels: Int
    let name: String
}

let car = Car(wheels: 4, name: "Ford")

let get = route(method: .GET)
let hello = get("/hello") { req -> AnyResponse in
    return AnyResponse(item: "hello word")
}

let vehicle = get("/car") { req -> AnyResponse in
    return AnyResponse(item: car)
}

let plane = router(register: [hello, vehicle]) |> concorde
let wings = Configuration(port: 8080)

plane <*> wings
