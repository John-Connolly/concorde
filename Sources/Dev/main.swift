import Foundation
import concorde

let f: (String) -> (MimeType) -> Middleware = curry(write(body:contentType:))
let g = flip(f)(.html)

enum SiteRoutes: Sitemap {

    case home
    case json
    case advanced
    case routing(String, UInt)
    case benchmark

    func action() -> Middleware {
        switch self {
        case .home: return mainView()
        case .json: return jsonExample()
        case .advanced: return advancedPage()
        case .benchmark: return write(body: "Hello")
        case .routing(let str, let id):
            return routingExample(resource: str, id: id)
        }
    }

}

let routes = [
    pure(unzurry(SiteRoutes.home)) <*> end,
    pure(unzurry(SiteRoutes.json)) <*> (path("json") *> end),
    pure(unzurry(SiteRoutes.advanced)) <*> (path("advanced") *> end),
    curry(SiteRoutes.routing) <^> (path("routing") *> string) <*> UInt,
].reduce(.e, <>)

let fileMiddleware = curry(fileServing) <^> (suffix) // TODO Need to move this!

let flightPlan = router(register: [routes], middleware: [fileMiddleware], notFound: mainView())
let wings = Configuration(port: 8080, resources: [])
takeOff(router: flightPlan, config: wings)



//let route = unzurry(SiteRoutes.benchmark) <^> end
//
//let flightPlan = router(register: [route])
//let wings = Configuration(port: 8080, resources: [])
//let plane = concorde((flightPlan, config: wings))
//plane.apply(wings)

// wrk -t6 -c400 -d30s http://localhost:8080/hello

//Running 30s test @ http://localhost:8080/hello
//6 threads and 400 connections
//Thread Stats   Avg      Stdev     Max   +/- Stdev
//Latency     4.49ms    3.21ms  83.06ms   89.20%
//Req/Sec     8.33k     1.51k   12.12k    69.28%
//1491679 requests in 30.01s, 150.79MB read
//Socket errors: connect 151, read 119, write 0, timeout 0
//Requests/sec:  49703.19
//Transfer/sec:      5.02MB


//let sitemap: [Route<SiteRoutes>] = [
//    pure(unzurry(SiteRoutes.home)) <*> (path("home") *> end)
//]
//
//let flightPlan = router(register: sitemap, middleware: [fileMiddleware], notFound: notFoundPage())
//let wings = Configuration(port: 8080, resources: preflightCheck)
//let plane = concorde(flightPlan, config: wings)
//plane.apply(wings)
