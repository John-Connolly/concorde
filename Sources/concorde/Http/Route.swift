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
    /// String respresentation of what is being matched on.
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
        let url = URL(string: string)
        let components = url?.pathComponents ?? []
        return parse(components.dropFirst())
    }

    public func map<T>(_ transform: @escaping (A) -> T) -> Route<T> {
        return Route<T>(uriFormat: self.uriFormat) { input in
            guard let (result, remainder) = self.parse(input) else { return nil }
            return (transform(result), remainder)
        }
    }

    public func followed<B>(by other: Route<B>) -> Route<(A, B)> {
        return Route<(A, B)>(uriFormat: self.uriFormat + "/" + other.uriFormat) { input in
            guard let (result1, remainder1) = self.parse(input) else { return nil }
            guard let (result2, remainder2) = other.parse(remainder1) else { return nil }
            return ((result1, result2), remainder2)
        }
    }
}

public func prettyPrint(_ route: Route<(Request) -> Future<AnyResponse>>) -> String {
    return route.uriFormat
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

public let int: Route<Int> = Route(uriFormat: ":Int") { input in
    guard let int = input.first.flatMap(Int.init) else { return nil }
    return (int, input.dropFirst())
}

public let UInt: Route<UInt> = Route(uriFormat: ":UInt") { input in
    guard let uint = input.first.flatMap(Swift.UInt.init) else { return nil }
    return (uint, input.dropFirst())
}

public let double: Route<Double> = Route(uriFormat: ":Double") { input in
    guard let double = input.first.flatMap(Double.init) else { return nil }
    return (double, input.dropFirst())
}

public let string: Route<String> = Route(uriFormat: ":String") { input in
    guard let string = input.first else { return nil }
    return (string, input.dropFirst())
}

/// Inverses
public struct RouteInverse<A> {
    public typealias Stream = String
    public let construct: (Stream) -> (A, Stream)?
}

public func path(_ matching: String) -> RouteInverse<String> {
    return RouteInverse { input in
        return (matching, matching)
    }
}

