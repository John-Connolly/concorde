//
//  Redis.swift
//  Dev
//
//  Created by John Connolly on 2018-12-25.
//

import Foundation
import concorde
import Redis

func redis(conn: Conn) -> Future<RedisClient> {
    return conn.cached(RedisClient.self)
}

func redisQuery(command: Command, client: RedisClient) -> Future<RedisData> {
    return client.command(command.rawValue, command.args)
}

//let getRedis = redis >=> curry(redisQuery)

enum Command {

    enum Section: String {
        case clients
        case memory
        case server
        case all
    }

    case get(key: String)
    case mget(keys: [String])
    case llen(key: String)
    case smembers(key: String)
    case lrange(key: String, range: CountableClosedRange<Int>)
    case info(section: Section)

    var rawValue: String {
        switch self {
        case .get: return "GET"
        case .llen: return "LLEN"
        case .smembers: return "SMEMBERS"
        case .mget: return "MGET"
        case .lrange: return "LRANGE"
        case .info: return "INFO"
        }
    }

    var args: [RedisData] {
        switch self {
        case .get(let key): return [RedisData(bulk: key)]
        case .llen(let key): return [RedisData(bulk: key)]
        case .smembers(let key): return [RedisData(bulk: key)]
        case .mget(let keys): return keys.compactMap { RedisData(bulk: $0) }
        case .info(let section):
            switch section {
            case .all: return []
            default: return [RedisData(bulk: section.rawValue.uppercased())]
            }
        case .lrange(let key, let range):
            let lower = String(range.lowerBound)
            let upper = String(range.upperBound)
            return [RedisData(bulk: key), RedisData(bulk: lower), RedisData(bulk: upper)]
        }
    }
}


struct RedisStats {

    let connectedClients: Int
    let blockedClients: Int
    let usedMemoryHuman: String
    let uptime: Int // Seconds
    let usedMemory: Int
    let totalMemory: Int

    private let formatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()

    init(_ stats: [String : String]) {
        self.connectedClients = Int(stats["connected_clients"]?.digits ?? "") ?? 0
        self.blockedClients =  Int(stats["blocked_clients"]?.digits ?? "") ?? 0
        self.usedMemoryHuman = stats["used_memory_human"] ?? ""
        self.uptime = Int(stats["uptime_in_seconds"]?.digits ?? "") ?? 0
        self.usedMemory = Int(stats["used_memory"]?.digits ?? "") ?? 0
        self.totalMemory = Int(stats["total_system_memory"]?.digits ?? "") ?? 0
    }

    var formattedClients: String {
        return formatter.string(from: NSNumber(integerLiteral: connectedClients)) ?? ""
    }

    var formattedBlocked: String {
        return formatter.string(from: NSNumber(integerLiteral: blockedClients)) ?? ""
    }
}


extension String {

    /// Parses a string in the redis stats format into
    /// a key value pair.
    func parseStats() -> [String: String] {
        var results: [String : String] = [:]
        var currentField = "".unicodeScalars

        var key = "".unicodeScalars
        var value = "".unicodeScalars

        var newSection = false
        for char in self.unicodeScalars {
            switch char {
            case "\n":
                guard !newSection else {
                    newSection = false
                    break
                }

                value.append(contentsOf: currentField)
                currentField.removeAll()
                results[String(key)] = String(value)
                key.removeAll()
                value.removeAll()
            case ":":
                key.append(contentsOf: currentField)
                currentField.removeAll()
            case "#":
                newSection = true
            default:
                guard !newSection else {
                    break
                }
                currentField.append(char)
            }
        }
        return results
    }
}

extension String {

    private static let digits = UnicodeScalar("0")..."9"

    var digits: String {
        return String(unicodeScalars.filter { String.digits ~= $0 })
    }

}
