//
//  Route.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation
import NIOHTTP1

public indirect enum Endpoint {
    case empty
    case nothing
    case constant(String)
    case parameter(String)
    case joined(Endpoint, Endpoint)

    public var pretty: String {
        switch self {
        case .nothing:
            return ""
        case .empty:
            return "/"
        case .parameter(let param):
            return ":" + param
        case .constant(let str):
            return str
        case .joined(let a, let b):
            return a.pretty + b.pretty
        }
    }
}

public struct Route<A> {

    public typealias Stream = ArraySlice<String>

    public let parse: (Stream) -> (A, Stream)?

    public let inverse: () -> Endpoint?

    public let method: HTTPMethod
}

extension Route {

    init(parse: @escaping (Stream) -> (A, Stream)?) {
        self.parse = parse
        self.method = .GET // FIX
        self.inverse = {
            return .empty
        }
    }

    init(_ parse: @escaping (Stream) -> (A, Stream)?, inverse: @escaping () -> Endpoint?) {
        self.parse = parse
        self.method = .GET // FIX
        self.inverse = inverse
    }

    init(method: HTTPMethod, parse: @escaping (Stream) -> (A, Stream)?) {
        self.parse = parse
        self.method = method
        self.inverse = { 
            return .empty
        }
    }
}


extension Route where A: ExpressibleByIntegerLiteral {

    init(_ parse: @escaping (Stream) -> (A, Stream)?) {
        self.parse = parse
        self.method = .GET // FIX
        self.inverse =  {
            return .parameter(String(describing: A.self))
        }
    }

}

extension Route {

    public func run(_ string: String, method: HTTPMethod) -> (A, Stream)? {
        guard method == self.method else {
            return nil
        }
        guard let url = URL(string: string) else { return nil }
        let queryString = url.query?.components(separatedBy: "&") ?? []
        let combined = url.pathComponents + queryString
        return parse(combined.dropFirst())
    }

    public func map<T>(_ transform: @escaping (A) -> T) -> Route<T> {
        return Route<T>.init({ input in
            guard let (result, remainder) = self.parse(input) else { return nil }
            return (transform(result), remainder)
        }, inverse: {
            return self.inverse()
        })
    }

    public func followed<B>(by other: Route<B>) -> Route<(A, B)> {
        return Route<(A,B)>.init( { input -> ((A, B), ArraySlice<String>)? in
            guard let (result1, remainder1) = self.parse(input) else { return nil }
            guard let (result2, remainder2) = other.parse(remainder1) else { return nil }
            return ((result1, result2), remainder2)
        }) {
            guard let a = self.inverse(), let b = other.inverse() else { return nil }
            return .joined(a, b)
        }
    }

    public func or(_ route: Route<A>) -> Route<A> {
        return Route<A> { input in
            self.parse(input) ?? route.parse(input)
        }
    }
}


public func choice<A>(_ routes: [Route<A>]) -> Route<A> {
    return routes.dropFirst().reduce(routes[0], { $0.or($1) })
}

public func path(_ matching: String) -> Route<String> {
    return Route({ input -> (String, ArraySlice<String>)? in
        guard let path = input.first, path == matching else { return nil }
        return (path, input.dropFirst())
    }, inverse: {
        return .constant(matching)
    })
}

public let end: Route<()> = Route({ input in
    guard input.count == 0 else { return nil }
    return ((), input)
}, inverse: {
    return .nothing
})

public func method<A>(_ method: HTTPMethod, route: Route<A>) -> Route<A> {
    return Route(method: method, parse: route.parse)
}

public let suffix: Route<String> = Route { input in
    guard let last = input.last, last.contains("."), last != "favicon.ico" else { return nil }
    return (last, input)
}

public let double: Route<Double> = Route { input in
    guard let double = input.first.flatMap(Double.init) else { return nil }
    return (double, input.dropFirst())
}

public let string: Route<String> = Route({ input in
    guard let string = input.first else { return nil }
    return (string, input.dropFirst())
}, inverse: {
    return .parameter("String")
})

public let uuid: Route<UUID> = Route { input in
    guard let string = input.first, let uuid = UUID.init(uuidString: string) else { return nil }
    return (uuid, input.dropFirst())
}

public let int: Route<Int> = Route { input in
    guard let int = input.first.flatMap(Int.init) else { return nil }
    return (int, input.dropFirst())
}

public let int8: Route<Int8> = Route { input in
    guard let int = input.first.flatMap(Int8.init) else { return nil }
    return (int, input.dropFirst())
}

public let int16: Route<Int16> = Route { input in
    guard let int = input.first.flatMap(Int16.init) else { return nil }
    return (int, input.dropFirst())
}

public let int32: Route<Int32> = Route { input in
    guard let int = input.first.flatMap(Int32.init) else { return nil }
    return (int, input.dropFirst())
}

public let int64: Route<Int64> = Route { input in
    guard let int = input.first.flatMap(Int64.init) else { return nil }
    return (int, input.dropFirst())
}

public let UInt: Route<UInt> = Route { input in
    guard let uint = input.first.flatMap(Swift.UInt.init) else { return nil }
    return (uint, input.dropFirst())
}

public let UInt8: Route<UInt8> = Route { input in
    guard let uint = input.first.flatMap(Swift.UInt8.init) else { return nil }
    return (uint, input.dropFirst())
}

public let UInt16: Route<UInt16> = Route { input in
    guard let uint = input.first.flatMap(Swift.UInt16.init) else { return nil }
    return (uint, input.dropFirst())
}

public let UInt32: Route<UInt32> = Route { input in
    guard let uint = input.first.flatMap(Swift.UInt32.init) else { return nil }
    return (uint, input.dropFirst())
}

public let UInt64: Route<UInt64> = Route { input in
    guard let uint = input.first.flatMap(Swift.UInt64.init) else { return nil }
    return (uint, input.dropFirst())
}

public func query(_ param: String) -> Route<String> {
    return Route { input in
        let components = input.first?.split(separator: "=")
        guard let key = components?.first,
              let value = components?.last,
              key == param else { return nil }
        return (String(value), input.dropFirst())
    }
}
