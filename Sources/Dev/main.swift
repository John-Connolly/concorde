import Foundation
import concorde


func authorize(_ bool: Bool) -> Middleware {
    return { conn in
        return bool
            ? conn.future(conn)
            : conn.failed(with: .custom(.unauthorized))
    }
}

func hello(conn: Conn) -> Future<Conn> {
    return (authorize(!true) >=> write(status: .ok) >=> write(body: "Hello"))(conn)
}

let route = pure(unzurry(hello)) <*> (path("hello") *> end) |> get

let flightPlan = router(register: [route])
let wings = Configuration(port: 8080, resources: [])
let plane = concorde((flightPlan, config: wings))
plane.apply(wings)

// wrk -t6 -c400 -d30s http://localhost:8080/hello
// swift build -c release
//.build/release/dev

// Release mode
// Concorde
//6 threads and 400 connections
//Thread Stats   Avg      Stdev     Max   +/- Stdev
//Latency     5.89ms  718.20us  55.17ms   87.14%
//Req/Sec     6.81k     1.03k    9.77k    62.67%
//1219230 requests in 30.01s, 80.23MB read
//Socket errors: connect 151, read 12905, write 0, timeout 0
//Requests/sec:  40627.05
//Transfer/sec:      2.67MB



// Vapor
//Running 30s test @ http://localhost:8080/hello
//6 threads and 400 connections
//Thread Stats   Avg      Stdev     Max   +/- Stdev
//Latency     5.32ms    2.37ms  45.44ms   83.02%
//Req/Sec     7.49k   754.45    11.92k    65.78%
//1345911 requests in 30.10s, 186.12MB read
//Socket errors: connect 151, read 98, write 0, timeout 0
//Requests/sec:  44709.10
//Transfer/sec:      6.18MB



