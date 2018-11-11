//
//  Route.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation

public struct Route<A> {
    public typealias Stream = ArraySlice<String>
    public let parse: (Stream) -> (A, Stream)?
    /// String representation of what is being matched on.
    let uriFormat: String
}

extension Route {

    init(parse: @escaping (Stream) -> (A, Stream)?) {
        self.parse = parse
        self.uriFormat = "/"
    }

    init(uriFormat: String, parse: @escaping (Stream) -> (A, Stream)?) {
        self.parse = parse
        self.uriFormat = uriFormat
    }

}

extension Route {

    public func run(_ string: String) -> (A, Stream)? {
        guard let url = URL(string: string) else { return nil }
        let queryString = url.query?.components(separatedBy: "&") ?? []
        let combined = url.pathComponents + queryString
        return parse(combined.dropFirst())
    }

    public func map<T>(_ transform: @escaping (A) -> T) -> Route<T> {
        return Route<T>(uriFormat: uriFormat) { input in
            guard let (result, remainder) = self.parse(input) else { return nil }
            return (transform(result), remainder)
        }
    }

    public func followed<B>(by other: Route<B>) -> Route<(A, B)> {
        return Route<(A, B)>(uriFormat: uriFormat + "/" + other.uriFormat) { input in
            guard let (result1, remainder1) = self.parse(input) else { return nil }
            guard let (result2, remainder2) = other.parse(remainder1) else { return nil }
            return ((result1, result2), remainder2)
        }
    }
}

public func prettyPrint(_ route: Route<(Request) -> Future<Response>>) -> String {
    return route.uriFormat
}

public func prettyPrint(_ routes: [Route<(Request) -> Future<Response>>]) -> [String] {
    return routes.map { $0.uriFormat }
}

public func path(_ matching: String) -> Route<String> {
    return Route(uriFormat: "/" + matching) { input in
        guard let path = input.first, path == matching else { return nil }
        return (path, input.dropFirst())
    }
}

public let end: Route<()> = Route { input in
    guard input.count == 0 else { return nil }
    return ((), input)
}

public let double: Route<Double> = Route(uriFormat: ":Double") { input in
    guard let double = input.first.flatMap(Double.init) else { return nil }
    return (double, input.dropFirst())
}

public let string: Route<String> = Route(uriFormat: ":String") { input in
    guard let string = input.first else { return nil }
    return (string, input.dropFirst())
}

public let uuid: Route<UUID> = Route(uriFormat: ":UUID") { input in
    guard let string = input.first, let uuid = UUID.init(uuidString: string) else { return nil }
    return (uuid, input.dropFirst())
}

public let int: Route<Int> = Route(uriFormat: ":Int") { input in
    guard let int = input.first.flatMap(Int.init) else { return nil }
    return (int, input.dropFirst())
}

public let int8: Route<Int8> = Route(uriFormat: ":Int8") { input in
    guard let int = input.first.flatMap(Int8.init) else { return nil }
    return (int, input.dropFirst())
}

public let int16: Route<Int16> = Route(uriFormat: ":Int16") { input in
    guard let int = input.first.flatMap(Int16.init) else { return nil }
    return (int, input.dropFirst())
}

public let int32: Route<Int32> = Route(uriFormat: ":Int32") { input in
    guard let int = input.first.flatMap(Int32.init) else { return nil }
    return (int, input.dropFirst())
}

public let int64: Route<Int64> = Route(uriFormat: ":Int64") { input in
    guard let int = input.first.flatMap(Int64.init) else { return nil }
    return (int, input.dropFirst())
}

public let UInt: Route<UInt> = Route(uriFormat: ":UInt") { input in
    guard let uint = input.first.flatMap(Swift.UInt.init) else { return nil }
    return (uint, input.dropFirst())
}

public let UInt8: Route<UInt8> = Route(uriFormat: ":UInt8") { input in
    guard let uint = input.first.flatMap(Swift.UInt8.init) else { return nil }
    return (uint, input.dropFirst())
}

public let UInt16: Route<UInt16> = Route(uriFormat: ":UInt16") { input in
    guard let uint = input.first.flatMap(Swift.UInt16.init) else { return nil }
    return (uint, input.dropFirst())
}

public let UInt32: Route<UInt32> = Route(uriFormat: ":UInt32") { input in
    guard let uint = input.first.flatMap(Swift.UInt32.init) else { return nil }
    return (uint, input.dropFirst())
}

public let UInt64: Route<UInt64> = Route(uriFormat: ":UInt64") { input in
    guard let uint = input.first.flatMap(Swift.UInt64.init) else { return nil }
    return (uint, input.dropFirst())
}

func query(_ param: String) -> Route<String> {
    return Route(uriFormat: "/" + "?\(param)=") { input in
        guard let path = input.first, path == param else { return nil }
        return (path, input.dropFirst())
    }
}


enum ComponentType {
    case string
    case double
    indirect case bind(String, to: ComponentType, in: ComponentType)

}
