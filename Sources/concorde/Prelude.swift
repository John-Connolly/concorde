//
//  Prelude.swift
//  concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation

infix operator >>>: MonadicPrecedenceLeft

public func >>> <A,B,C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        return g(f(a))
    }
}

infix operator |>: MonadicPrecedenceLeft

public func |> <A,B>(a: A, f: @escaping (A) -> B) -> B {
    return f(a)
}

public func id<A>(_ a: A) -> A {
    return a
}

public func const<A, B>(_ a: A) -> (B) -> A {
    return { _ in a }
}

public func unzurry<A>(_ a: A) -> () -> A {
    return { a }
}
