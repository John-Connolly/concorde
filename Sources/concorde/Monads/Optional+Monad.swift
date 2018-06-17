//
//  Optional+Monad.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-17.
//

import Foundation

infix operator >>-: MonadicPrecedenceLeft

public func >>- <A, B>(a: Optional<A>, f: @escaping (A) -> Optional<B>) -> Optional<B> {
    return a.flatMap { value in
        return f(value)
    }
}
