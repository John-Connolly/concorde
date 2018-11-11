//
//  Route+Operators.swift
//  concorde
//
//  Created by John Connolly on 2018-06-27.
//

import Foundation

infix operator <*>: ParserPrecedence
infix operator <^>: ParserPrecedence
infix operator *>: ParserPrecedence

public func *> <A, B>(lhs: Route<A>, rhs: Route<B>) -> Route<B> {
    return const(id) <^> lhs <*> rhs
}

/// Functor
public func <^> <A, B>(lhs: @escaping (A) -> B, rhs: Route<A>) -> Route<B> {
    return rhs.map(lhs)
}

/// Applicative
public func <*> <A, B>(lhs: Route<(A) -> B>, rhs: Route<A>) -> Route<B> {
    return lhs.followed(by: rhs).map { f, x in f(x) }
}


public func pure<A>(_ a: A) -> Route<A> {
    return Route { stream in
        return (a, stream)
    }
}
