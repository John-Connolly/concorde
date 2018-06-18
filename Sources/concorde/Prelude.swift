//
//  Prelude.swift
//  concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation

infix operator >>>: MonadicPrecedenceLeft
/// Forward composition h(x) = (f ∘ g)
public func >>> <A,B,C>(f: @escaping(A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        return f(a) |> g
    }
}

infix operator |>: MonadicPrecedenceLeft
/// Pipeforward
public func |> <A,B>(a: A, f: @escaping (A) -> B) -> B {
    return f(a)
}
