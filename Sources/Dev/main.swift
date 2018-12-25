import Foundation
import concorde


func authorize(_ bool: Bool) -> Middleware {
    return { conn in
        return bool
            ? conn.future(conn)
            : conn.failed(with: .custom(.unauthorized))
    }
}

func login(conn: Conn) -> Future<Conn> {
    return (authorize(true)
        >=> write(status: .ok)
        >=> write(body: loginPage(), contentType: .html))(conn)
}

func dashBoard(conn: Conn) -> Future<Conn> {
    return (write(status: .ok) >=> write(body: dashBoardView(), contentType: .html))(conn)
}

// FIXME: Hack
func fileServing(fileName: String, conn: Conn) -> Future<Conn> {
    let directory = #file
    let fileDirectory = directory.components(separatedBy: "/Sources").first! + "/public/"
    let url = URL(fileURLWithPath: fileDirectory + fileName)
    guard let data = try? Data(contentsOf: url) else {
        return conn.failed(with: .abort)
    }
    return (write(status: .ok) >=> write(body: data, contentType: .png))(conn)
}

let routes = [
    pure(unzurry(login)) <*> end |> get,
    pure(unzurry(dashBoard)) <*> (path("login") *> end) |> get,
    curry(fileServing) <^> (suffix) |> get,
]

let flightPlan = router(register: routes)
let wings = Configuration(port: 8080, resources: [])
let plane = concorde((flightPlan, config: wings))
plane.apply(wings)



// wrk -t6 -c400 -d30s http://localhost:8080/hello

