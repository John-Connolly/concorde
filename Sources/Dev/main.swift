import Foundation
import concorde

let get = route(method: .GET)
let hello = get("/hello") { req -> String in
    return "hello word"
}

let plane = router(register: [hello]) |> concorde
let wings = Configuration(port: 8080)

plane <*> wings
