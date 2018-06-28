import Foundation
import concorde

let flightPlan = router(register: siteMap) //hello, vehicle, largerResp, update, token
let plane = flightPlan |> concorde
let wings = Configuration(port: 8080)

plane <*> wings
