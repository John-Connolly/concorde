import Foundation
import concorde

let flightPlan = router(register: [hello, vehicle, largerResp, update, token])
let plane = flightPlan |> concorde
let wings = Configuration(port: 8080)

plane <*> wings




func home(param: Int) -> (Int) -> () -> () {
    return { param2 in
        return {
            print(param, param2)
        }
    }
}

let path2 = "users/3434/34"

let url = URL(string: path2)
print(url?.pathComponents ?? "")

let parse2 = path("users") *> int
let parse = home <^> (path("users") *> int) <*> int

let nextFunc = parse.run(path2)?.0
print(nextFunc?())
//nextFunc?()

