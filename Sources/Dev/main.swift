import Foundation
import concorde

let route = curry(users) <^> (path("users") *> string) <*> int
print(prettyPrint(route))

let flightPlan = router(register: siteMap)
let plane = flightPlan |> concorde
let wings = Configuration(port: 8080)
plane.apply(wings)
