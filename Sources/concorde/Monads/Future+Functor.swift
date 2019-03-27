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

extension Future {

//    func mapTT<A, B>(f: @escaping (A) -> B) -> Future<Optional<B>> where T == Optional<A> {
//        return self.map { maybe -> Optional<B> in
//            switch maybe {
//            case .some(let a): return f(a)
//            case .none: return .none
//            }
//        }
//    }
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
