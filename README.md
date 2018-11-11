Work in progress


A Swift µframework for building web apps. 


```swift
let siteMap = [
    curry(users) <^> (path("users") *> string) <*> int |> get,
]

func users(name: String, id: Int, req: Request) -> AnyResponse {
    return "hello \(name)! your id is: \(id)" |> AnyResponse.init(item:)
}


let flightPlan = router(register: siteMap)
let plane = flightPlan |> concorde
let wings = Configuration(port: 8080)

plane <*> wings


```
