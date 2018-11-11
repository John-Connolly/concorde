//
//  Future+Kleisli.swift
//  concorde
//
//  Created by John Connolly on 2018-11-11.
//

import Foundation

infix operator >=>: MonadicPrecedenceLeft

public func >=> <A, B, C>(f: @escaping (A) -> Future<B>, g: @escaping (B) -> Future<C>) -> (A) -> Future<C> {
    return { a in
        return f(a).then { g($0) }
    }
}
