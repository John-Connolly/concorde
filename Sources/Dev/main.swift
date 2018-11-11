import Foundation
import concorde

let route = curry(users) <^> (path("users") *> string) <*> int
print(prettyPrint(route))

let flightPlan = router(register: siteMap)
let wings = Configuration(port: 8080, resources: preflightCheck)
let plane = concorde((flightPlan, config: wings))
plane.apply(wings)
