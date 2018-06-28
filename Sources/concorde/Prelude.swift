//
//  Prelude.swift
//  concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation

infix operator >>>: MonadicPrecedenceLeft
/// Forward composition h(x) = (f ∘ g)
public func >>> <A,B,C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        return f(a) |> g
    }
}

infix operator |>: MonadicPrecedenceLeft
/// Pipeforward
public func |> <A,B>(a: A, f: @escaping (A) -> B) -> B {
    return f(a)
}

public func id<A>(_ a: A) -> A {
    return a
}

public func const<A, B>(_ a: A) -> (B) -> A {
    return { _ in a }
}

infix operator <^>: ParserPrecedence
public func <^> <A, B>(lhs: @escaping (A) -> B, rhs: Route<A>) -> Route<B> {
    return rhs.map(lhs)
}

infix operator <*>: ParserPrecedence

public func <*> <A, B>(lhs: Route<(A) -> B>, rhs: Route<A>) -> Route<B> {
    return lhs.followed(by: rhs).map { f, x in f(x) }
}


infix operator *>: ParserPrecedence
public func *> <A, B>(lhs: Route<A>, rhs: Route<B>) -> Route<B> {
    return const(id) <^> lhs <*> rhs
}



