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

let flightPlan = router(register: [hello, vehicle])
let plane = flightPlan |> concorde
let wings = Configuration(port: 8080)
plane <*> wings
