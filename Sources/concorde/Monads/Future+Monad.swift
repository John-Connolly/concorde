//
//  Future+Monad.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation
import NIO

infix operator >>-: MonadicPrecedenceLeft

public func >>- <A, B>(a: Future<A>, f: @escaping (A) -> Future<B>) -> Future<B> {
    return a.then { value in
        return f(value)
    }
}

func flatMapTT<A,B>(f: @escaping (A) -> Future<B>) -> (Future<Optional<A>>) -> Future<Optional<B>> {
    return { future in
        future.then { maybeA in
            return maybeA.map { a in
                f(a).map(Optional.some)
            } ?? future.map { _ in
                return (Optional<B>.none)
            }
        }
    }
}
