Work in progress


A Swift µframework for building web apps. 


```swift
	
let get = route(method: .GET)
let hello = get("/") { req -> AnyResponse in
    return AnyResponse(item: "hello word")
}

let flightPlan = router(register: [hello])
let plane = flightPlan |> concorde
let wings = Configuration(port: 8080)

plane <*> wings


```
