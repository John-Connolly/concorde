import Foundation
import concorde


func authorize(_ bool: Bool) -> Middleware {
    return { conn in
        return bool
            ? conn.future(conn)
            : conn.failed(with: .custom(.unauthorized))
    }
}

func loginView() -> Middleware {
    return (authorize(true)
        >=> write(status: .ok)
        >=> write(body: loginPage(), contentType: .html))
}

func loginPost() -> Middleware {
    return authorize(true)
        >=> write(status: .ok)
        >=> redirect(to: "overview")
}

func dashBoard() -> Middleware {
    return { conn in
        let view =
            zip(redisStats(with: conn),
                processedStats(with: conn),
                workersStats(with: conn),
                graphItems(with: conn))
                <^> DashBoardData.init
                <^> dashBoardView

        func writeBody(conn: Conn) -> Future<Conn> {
            return view >>- { write(body: $0, contentType: .html)(conn) }
        }

        return (write(status: .ok)
            >=> writeBody)(conn)
    }
}

func redisStats(with conn: Conn) -> Future<RedisStats> {
    let query = curry(redisQuery)(.info(section: .all))
    let data = redis(conn: conn) >>- query
    return data
        <^> { $0.string?.parseStats() ?? [:] }
        <^> RedisStats.init
}


func graphItems(with conn: Conn) -> Future<[(String, Int)]> {
    let weekOfDates = ((1...6).map { Date().addingTimeInterval(-86_400 * Double($0)) } + [Date()]).sorted(by: <)
    let datesFormatted = weekOfDates.map(dateString(from:))
    let keys = datesFormatted.map { "stats:proccessed:" + $0 }
    let command = Command.mget(keys: keys)
    let query = curry(redisQuery)(command)
    let data = redis(conn: conn) >>- query

    let values = data.map { ($0.array?.map { Int($0.string ?? "0")! }) ?? [] }
    return values.map { zip(datesFormatted, $0).map { $0 } }
}

func dateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateStyle = .short
    return formatter.string(from: date)
}

struct ProcessedStats {
    let total: String
    let queued: String
    let failed: String

    private let formatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()


    private func formattedInt() -> (Int) -> String? {
        return NSNumber.init(integerLiteral:) >>> formatter.string(from:)
    }

    var formattedTotal: String {
        return Int(total).flatMap(formattedInt()) ?? "None"
    }

    var formattedQueued: String {
        return Int(queued).flatMap(formattedInt()) ?? "None"
    }

    var formattedFailed: String {
        return Int(failed).flatMap(formattedInt()) ?? "None"
    }

}

func processedStats(with conn: Conn) -> Future<ProcessedStats> {
    let processed = (redis(conn: conn) >>- curry(redisQuery)(.get(key: "stats:proccessed"))) <^> { $0.string ?? "None" }
    let failed = (redis(conn: conn) >>- curry(redisQuery)(.get(key: "stats:failed"))) <^> { $0.string ?? "None" }
    let queued = (redis(conn: conn) >>- curry(redisQuery)(.llen(key: "queue:default"))) <^> { $0.int?.description ?? "0" }
    return zip(processed, queued, failed).map(ProcessedStats.init)
}


extension Date {

    var unixTime: Int {
        return Int(self.timeIntervalSince1970)
    }

}

struct ConsumerInfo: Codable {
    var beat: Int
    let info: Info
    var busy: Int

    struct Info: Codable {
        let hostname: String
        let startedAt: Int
    }

    var isAlive: Bool {
        let tenSecondsAgo = Date().addingTimeInterval(-10).unixTime
        return tenSecondsAgo < beat
    }

    var health: String {
        return isAlive ? "Alive" : "💀Dead💀"
    }

    var lastBeatFormatted: String {
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone(abbreviation: "UTC")
        dateformatter.dateStyle = .full
        dateformatter.timeStyle = .medium
        return dateformatter.string(from: Date(timeIntervalSince1970: Double(beat)))
    }


    var uptime: String {
        let difference = Date().addingTimeInterval(-Double(info.startedAt)).unixTime
        return isAlive ? timePassed(since: difference) : "N/A"
    }

    var allFields: [String: String] {
        return [
            ConsumerInfo.CodingKeys.beat.stringValue: beat.description,
            ConsumerInfo.CodingKeys.busy.stringValue: busy.description,
            ConsumerInfo.CodingKeys.info.stringValue: "",
        ]
    }

}

func timePassed(since date: Int) -> String {
    let days = (date / 86_400)
    let hours = (date % 86_400) / 3600
    let minutes = (date % 3600) / 60
    let seconds = (date % 3600) % 60
    return days > 1
        ? String(days) + " days"
        : hours > 1
        ? String(hours) + " Hours"
        : minutes > 1
        ? String(minutes) + " Minutes"
        : String(seconds) + " Seconds"
}


import Redis

func logReq(item: String) -> Middleware  {
    return { conn in
        let query = curry(redisQuery)(.lpush(key: "logs", value: "INFO: \(item)"))
        let data = redis(conn: conn) >>- query
        return data.map { _ in
            return conn
        }
    }
}

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


func failedView() -> Middleware {
    return (authorize(true)
        >=> write(status: .ok)
        >=> write(body: failedView(), contentType: .html))
}


func logsView() -> Middleware {
    return (authorize(true)
        >=> write(status: .ok)
        >=> write(body: logsView(), contentType: .html))
}

func notFound() -> Middleware {
    return (write(status: .notFound)
        >=> write(body: "<h1> NOT FOUND!!!! </h1>", contentType: .html))
}

func retrieveLogs() -> Middleware {
    return { conn in
        let query = curry(redisQuery)(.lrange(key: "logs", range: 0...9999))
        let data = redis(conn: conn) >>- query

        struct Log: Codable {
            let item: [String]
        }

        let logs = data.map { item -> Log in
            return Log(item: item.array?.map({ $0.string ?? "Failed" }) ?? [])
        }

        func writeBody(conn: Conn) -> Future<Conn> {
            return logs >>- { write(body: $0)(conn) }
        }
        return (write(status: .ok)
            >=> writeBody)(conn)

    }
}



let f: (String) -> (MimeType) -> Middleware = curry(write(body:contentType:))
let g = flip(f)(.html)


func hello() -> Middleware {
    return write(status: .ok) >=> write(body: "loaderio-95e2de71ba5cfa095645d825903bc632")
}

enum Routes: Sitemap {
    case route

    func action() -> Middleware {
        switch self {
        case .route:
            return write(status: .ok) >=> write(body: "HELLO WORLD")
        }
    }
}

indirect enum SiteRoutes: Sitemap {

    case test(path: String, id: Int)
    case login
    case dashboard
    case failed
    case logs
    case hello
    case allLogs

    case posts(PostRoutes)
    case homePage(Homepage)


    func action() -> Middleware {
        switch self {
        case .test(let path, let id):
            return (write(status: .ok) >=> write(body: "Hello World \(path) - \(id)"))
        case .login:
            return loginView()
        case .dashboard:
            return dashBoard()
        case .allLogs: return retrieveLogs()
        case .failed:
            return failedView()
        case .logs:
            return logsView()
        case .hello:
            return write(status: .ok) >=> write(body: "loaderio-95e2de71ba5cfa095645d825903bc632")
        case .posts(let routes):
            return routes.action()
        case .homePage(let routes):
            return routes.action()
        }
    }

    enum PostRoutes: Sitemap {
        case addTaskP
        case loginP
        case deployP

        func action() -> Middleware {
            switch self {
            case .addTaskP:
                return addTask()
            case .loginP:
                return loginPost()
            case .deployP:
                return deploy()
            }
        }
    }

    enum Homepage: Sitemap {
        case home
        case json
        case advanced
        case routing(String, UInt)

        func action() -> Middleware {
            switch self {
            case .home: return mainView()
            case .json: return jsonExample()
            case .advanced: return advancedPage()
            case .routing(let str, let id):
                return routingExample(resource: str, id: id)
            }
        }
    }
}

let thing = pure(unzurry(SiteRoutes.failed)) <*> (path("failed") *> end)

let sitemap: [Route<SiteRoutes>] = [
    pure(curry(SiteRoutes.test)) <*> (path("addTask") *> string) <*> int,
    pure(unzurry(SiteRoutes.login)) <*> end,
    pure(unzurry(SiteRoutes.dashboard)) <*> (path("overview") *> end),
    pure(unzurry(SiteRoutes.allLogs)) <*> (path("allLogs") *> end),
    pure(unzurry(SiteRoutes.failed)) <*> (path("failed") *> end),
    pure(unzurry(SiteRoutes.logs)) <*> (path("logs") *> end),
    pure(unzurry(SiteRoutes.hello)) <*> (path("hello") *> end),
]

//print(choice(sitemap).inverse()?.pretty)
//sitemap.forEach { print($0.inverse()!.pretty) }

let posts: [Route<SiteRoutes.PostRoutes>] = [
    pure(unzurry(SiteRoutes.PostRoutes.addTaskP)) <*> (path("addTask") *> end),
    pure(unzurry(SiteRoutes.PostRoutes.loginP)) <*> (path("login") *> end),
    pure(unzurry(SiteRoutes.PostRoutes.deployP)) <*> (path("deploy") *> end),
]

//let type2 = unzurry(SiteRoutes.Homepage.home) <^> (path("home") *> end)

let home: [Route<SiteRoutes.Homepage>] = [
    pure(unzurry(SiteRoutes.Homepage.home)) <*> (path("home") *> end),
    pure(unzurry(SiteRoutes.Homepage.json)) <*> (path("json") *> end),
    pure(unzurry(SiteRoutes.Homepage.advanced)) <*> (path("advanced") *> end),
    curry(SiteRoutes.Homepage.routing) <^> (path("routing") *> string) <*> UInt,
]

let homeTransformed = choice(home).map(SiteRoutes.homePage)

//print(choice(sitemap).invert(a: SiteRoutes.test(path: "resource", id: 56)))

//print(homeTransformed.inverse().pretty)

let type = choice(posts).map(SiteRoutes.posts)

let t = method(.POST, route: type)

let fileMiddleware = curry(fileServing) <^> (suffix)

let flightPlan = router(register: sitemap + [t] + [homeTransformed], middleware: [fileMiddleware], notFound: mainView())
let wings = Configuration(port: 8080, resources: preflightCheck)
let plane = concorde((flightPlan, config: wings))
plane.apply(wings)

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
