//
//  Future+Functor.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation
import NIO

infix operator <^>: MonadicPrecedenceLeft

public func <^> <A, B>(a: Future<A>, f: @escaping (A) -> B) -> Future<B> {
    return a.map { value in
        return f(value)
    }
}


func mapTT<A,B>(f: @escaping (A) -> B) -> (Future<Optional<A>>) -> Future<Optional<B>> {
    return { future in
        future.map { maybeA in
            return maybeA.flatMap { a in
                return Optional<B>.some(f(a))
            }
        }
    }
}
