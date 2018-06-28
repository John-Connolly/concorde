//
//  Route.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation


public struct Route<A> {
    public typealias Stream = ArraySlice<String> // Change to slice
    public let parse: (Stream) -> (A, Stream)?
}

extension Route {

    public func run(_ string: String) -> (A, Stream)? {
        let url = URL(string: string)
        let components = url?.pathComponents ?? []

        return parse(components.dropFirst())
    }

    public var many: Route<[A]> {
        return Route<[A]> { input in
            var result: [A] = []
            var remainder = input
            while let (element, newRemainder) = self.parse(remainder) {
                result.append(element)
                remainder = newRemainder
            }
            return (result, remainder)
        }
    }

    public func map<T>(_ transform: @escaping (A) -> T) -> Route<T> {
        return Route<T> { input in
            guard let (result, remainder) = self.parse(input) else { return nil }
            return (transform(result), remainder)
        }
    }

    public func followed<B>(by other: Route<B>) -> Route<(A, B)> {
        return Route<(A, B)> { input in
            guard let (result1, remainder1) = self.parse(input) else { return nil }
            guard let (result2, remainder2) = other.parse(remainder1) else { return nil }
            return ((result1, result2), remainder2)
        }
    }
}


public func path(_ matching: String) -> Route<String> {
    return Route { input in
        guard let path = input.first, path == matching else { return nil }
        return (path, input.dropFirst())
    }
}

public let int: Route<Int> = {
    return Route { input in
        guard let int = input.first.flatMap(Int.init) else { return nil }
        return (int, input.dropFirst())
    }
}()

public let string: Route<String> = {
    return Route { input in
        guard let string = input.first else { return nil }
        return (string, input.dropFirst())
    }
}()


