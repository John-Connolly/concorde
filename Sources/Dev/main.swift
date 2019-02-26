import Foundation
import concorde


func authorize(_ bool: Bool) -> Middleware {
    return { conn in
        return bool
            ? conn.future(conn)
            : conn.failed(with: .custom(.unauthorized))
    }
}

func login() -> Middleware {
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

    var formattedTotal: String {
        return Int(total).flatMap { formatter.string(from: NSNumber(integerLiteral: $0)) } ?? "None"
    }

    var formattedQueued: String {
        return Int(queued).flatMap { formatter.string(from: NSNumber(integerLiteral: $0)) } ?? "None"
    }

    var formattedFailed: String {
        return Int(failed).flatMap { formatter.string(from: NSNumber(integerLiteral: $0)) } ?? "None"
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


func failed() -> Middleware {
    return (authorize(true)
        >=> write(status: .ok)
        >=> write(body: failedView(), contentType: .html))
}


func logs() -> Middleware {
    return (authorize(true)
        >=> write(status: .ok)
        >=> write(body: logsView(), contentType: .html))
}

func notFound() -> Middleware {
    return (write(status: .notFound)
        >=> write(body: "not found", contentType: .plain))
}



let f: (String) -> (MimeType) -> Middleware = curry(write(body:contentType:))
let g = flip(f)(.html)


func weatherData(conn: Conn) -> Future<Conn> {
    let url = "http://api.openweathermap.org/data/2.5/weather?q=Wolfville,ca&APPID=1c612550bab05b2d74696169c71bdc84"

    let urlRequest = URLRequest(url: URL(string: url)!)
    let session = URLSession(configuration: .default)
    let promise: EventLoopPromise<Data> = conn.promise()

    session.dataTask(with: urlRequest, completionHandler: { data, resp , _ in

        guard let data = data else {
            promise.fail(error: "Could not get data")
            return
        }

        if let resp = resp as? HTTPURLResponse, resp.statusCode != 200 {
            promise.succeed(result: data)
            return
        }

        promise.succeed(result: data)

    }).resume()

    return promise.futureResult.flatMap { data in
        (write(status: .ok) >=> write(body: data, contentType: .json))(conn)
    }

}

func hello() -> Middleware {
    return write(status: .ok) >=> write(body: "loaderio-95e2de71ba5cfa095645d825903bc632")
}

let postRoutes = [
    pure(addTask) <*> (path("addTask") *> end),
    pure(loginPost) <*> (path("login") *> end),
    pure(deploy) <*> (path("deploy") *> end),
]

let getRoutes = [
    pure(login) <*> end,
    pure(dashBoard) <*> (path("overview") *> end),
    pure(failed) <*> (path("failed") *> end),
    pure(logs) <*> (path("logs") *> end),
    pure(hello) <*> (path("loaderio-95e2de71ba5cfa095645d825903bc632") *> end),
//    pure(unzurry(weatherData)) <*> (path("weather") *> end),
    curry(fileServing) <^> (suffix),
]



//let proutes = prettyPrint(getRoutes)
//postRoutes.forEach { print($0) }

let getGrouped = method(.GET, route: choice(getRoutes))
let postGrouped = method(.POST, route: choice(postRoutes))

let flightPlan = router(register: [getGrouped, postGrouped])
let wings = Configuration(port: 8080, resources: preflightCheck)
let plane = concorde((flightPlan, config: wings))
plane.apply(wings)

// wrk -t6 -c400 -d30s http://localhost:8080/hello

