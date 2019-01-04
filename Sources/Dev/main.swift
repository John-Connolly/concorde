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

func loginPost(conn: Conn) -> Future<Conn> {
    return (authorize(true)
        >=> write(status: .ok)
        >=> redirect(to: "overview"))(conn)
}

func dashBoard(conn: Conn) -> Future<Conn> {
    let query = curry(redisQuery)(.info(section: .all))
    let data = redis(conn: conn) >>- query
    let stats = data
                    <^> { $0.string?.parseStats() ?? [:] }
                    <^> RedisStats.init
                    <^> dashBoardView

    func writeBody(conn: Conn) -> Future<Conn> {
        return stats >>- { write(body: $0, contentType: .html)(conn) }
    }
    return (write(status: .ok)
        >=> writeBody)(conn)
}


func dashTest(conn: Conn) -> Future<Conn> {
    return (authorize(true)
        >=> write(status: .ok) //render(view: mainPage, with: ()
        >=> write(body: failedView(), contentType: .html))(conn)
}

func failed(conn: Conn) -> Future<Conn> {
    return (authorize(true)
        >=> write(status: .ok) //render(view: mainPage, with: ()
        >=> write(body: failedView(), contentType: .html))(conn)
}

let f: (String) -> (MimeType) -> Middleware = curry(write(body:contentType:))
let g = flip(f)(.html)

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
    pure(unzurry(loginPost)) <*> (path("login") *> end) |> post,
    pure(unzurry(dashBoard)) <*> (path("overview") *> end) |> get,
    pure(unzurry(dashTest)) <*> (path("test") *> end) |> get,
    pure(unzurry(failed)) <*> (path("failed") *> end) |> get,
    curry(fileServing) <^> (suffix) |> get,
]

let flightPlan = router(register: routes)
let wings = Configuration(port: 8080, resources: preflightCheck)
let plane = concorde((flightPlan, config: wings))
plane.apply(wings)



// wrk -t6 -c400 -d30s http://localhost:8080/hello

