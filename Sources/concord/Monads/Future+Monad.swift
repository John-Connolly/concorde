//
//  Future+Monad.swift
//  concord
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation
import NIO

infix operator >>-: MonadicPrecedenceLeft

/// flatmaps a Future if the future throws an error f with never be called.
public func >>- <A, B>(a: EventLoopFuture<A>, f: @escaping (A) -> EventLoopFuture<B>) -> EventLoopFuture<B> {
    return a.then { value in
        return f(value)
    }
}

infix operator >>>: MonadicPrecedenceLeft
public func >>> <A,B,C>(f: @escaping(A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        return f(a) |> g
    }
}

infix operator |>: MonadicPrecedenceLeft

public func |> <A,B>(a: A, f: @escaping (A) -> B) -> B {
    return f(a)
}
