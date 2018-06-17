//
//  Optional+Functor.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation

infix operator <^>: MonadicPrecedenceLeft

public func <^> <A, B>(a: Optional<A>, f: @escaping (A) -> B) -> Optional<B> {
    return a.map { value in
        return f(value)
    }
}
