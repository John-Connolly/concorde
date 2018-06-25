//
//  RouteParser.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation


let url = "/Users/32"

let urlType = URL(string: url)!

enum Route: String {
    case home = "hello"
}

extension Route {

    init?(_ route: String) {
        //case .home: return nil
        return nil
    }
}

public struct RouteParser<A> {
    public typealias Stream = [String] // Change to slice
    public let parse: (Stream) -> (A, Stream)?
}

extension RouteParser {

    public func run(_ string: String) -> (A, Stream)? {
        let url = URL(string: string)
        let components = url?.pathComponents ?? []
        return parse(components)
    }

    public var many: RouteParser<[A]> {
        return RouteParser<[A]> { input in
            var result: [A] = []
            var remainder = input
            while let (element, newRemainder) = self.parse(remainder) {
                result.append(element)
                remainder = newRemainder
            }
            return (result, remainder)
        }
    }

    public func map<T>(_ transform: @escaping (A) -> T) -> RouteParser<T> {
        return RouteParser<T> { input in
            guard let (result, remainder) = self.parse(input) else { return nil }
            return (transform(result), remainder)
        }
    }

    public func followed<B>(by other: RouteParser<B>) -> RouteParser<(A, B)> {
        return RouteParser<(A, B)> { input in
            guard let (result1, remainder1) = self.parse(input) else { return nil }
            guard let (result2, remainder2) = other.parse(remainder1) else { return nil }
            return ((result1, result2), remainder2)
        }
    }
}


public func path(_ matching: String) -> RouteParser<String> {
    return RouteParser { input in
        guard let path = input.first, path == matching else { return nil }
        return (path, Array(input.dropFirst()))
    }
}

public let int: RouteParser<Int> = {
    return RouteParser { input in
        guard let int = input.first.flatMap(Int.init) else { return nil }
        return (int, Array(input.dropFirst()))
    }
}()

public let string: RouteParser<String> = {
    return RouteParser { input in
        guard let string = input.first else { return nil }
        return (string, Array(input.dropFirst()))
    }
}()


