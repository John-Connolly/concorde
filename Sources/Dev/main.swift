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

    let view =
        zip(redisStats(with: conn),
            processedStats(with: conn),
            workersStats(with: conn))
        <^> DashBoardData.init
        <^> dashBoardView

    func writeBody(conn: Conn) -> Future<Conn> {
        return view >>- { write(body: $0, contentType: .html)(conn) }
    }

    return (write(status: .ok)
        >=> writeBody)(conn)
}

func redisStats(with conn: Conn) -> Future<RedisStats> {
    let query = curry(redisQuery)(.info(section: .all))
    let data = redis(conn: conn) >>- query
    return data
        <^> { $0.string?.parseStats() ?? [:] }
        <^> RedisStats.init
}

struct ProcessedStats {
    let total: String
    let queued: Int
    let failed: Int
}

func processedStats(with conn: Conn) -> Future<ProcessedStats> {
    let query = curry(redisQuery)(.get(key: "stats:proccessed"))
    let data = redis(conn: conn) >>- query
    return data
        <^> { $0.string ?? "None" }
        <^> { ProcessedStats.init(total: $0, queued: 12, failed: 0)}
}


struct ConsumerInfo: Codable {
    var beat: Int
    let info: Info
    var busy: Int

    struct Info: Codable {
        let hostname: String
        let startedAt: Int
    }


    var allFields: [String: String] {
        return [
            ConsumerInfo.CodingKeys.beat.stringValue: beat.description,
            ConsumerInfo.CodingKeys.busy.stringValue: busy.description,
            ConsumerInfo.CodingKeys.info.stringValue: "",
        ]
    }

}


import Redis

func workersStats(with conn: Conn) -> Future<[ConsumerInfo]> {
    let query = curry(redisQuery)(.smembers(key: "processes"))
    let data = redis(conn: conn) >>- query
    let consumersNames = data.map { $0.array?.compactMap { $0.string } ?? [] }
    return consumersNames.then { consumers -> Future<RedisData> in
        let query = curry(redisQuery)(.mget(keys: consumers)) // FIX ME!!
        return redis(conn: conn) >>- query
        }.map { redisData in
            let redisDatas = redisData.array ?? []
            return try redisDatas
                .compactMap { $0.data }
                .map { data in
                    try JSONDecoder().decode(ConsumerInfo.self, from: data)
            }
        }.mapIfError { error in
            return []
    }
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
    pure(unzurry(failed)) <*> (path("failed") *> end) |> get,
    curry(fileServing) <^> (suffix) |> get,
]

let flightPlan = router(register: routes)
let wings = Configuration(port: 8080, resources: preflightCheck)
let plane = concorde((flightPlan, config: wings))
plane.apply(wings)



// wrk -t6 -c400 -d30s http://localhost:8080/hello

