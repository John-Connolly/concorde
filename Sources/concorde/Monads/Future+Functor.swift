//
//  Future+Functor.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation
import NIO

infix operator <^>: MonadicPrecedenceLeft

public func <^> <A, B>(a: EventLoopFuture<A>, f: @escaping (A) -> B) -> EventLoopFuture<B> {
    return a.map { value in
        return f(value)
    }
}
