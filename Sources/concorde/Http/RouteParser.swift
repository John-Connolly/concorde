//
//  RouteParser.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-03.
//

import Foundation

typealias Stream = String.SubSequence
typealias Parser<A> = (Stream) -> (A, Stream)?

let url = "/Users/32"

let urlType = URL(string: url)!


enum Route {
    case home
}

extension Route {

    init?(_ route: String) {
        //case .home: return nil
        return nil
    }
}

func char(predicate: @escaping (Character) -> Bool) -> Parser<Character> {
    let parser: Parser<Character> = { stream -> (Character, Stream)? in
        guard let char = stream.first, predicate(char) else {
            return nil
        }
        return (char, stream.dropFirst())
    }
    return parser
}

func parse<A>(_ item: Stream, with parser: Parser<A>) -> (A, String)? {
    guard let (result, remainder) = parser(item) else { return nil }
    return (result, String(remainder))
}

func parse<A>(with parse: @escaping Parser<A>) -> Parser<[A]> {
    let parser: Parser<[A]> = { stream in
        var result: [A] = []
        var remainder = stream
        while let (element, newRemainder) = parse(remainder) {
            result.append(element)
            remainder = newRemainder
        }
        return (result, remainder)
    }
    return parser
}
