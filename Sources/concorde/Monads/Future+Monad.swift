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
    return a.flatMap { value in
        return f(value)
    }
}

extension Future {

//    func flatMapTT<A, B>(f: @escaping (A) -> Future<B>) -> Future<Optional<B>> where T == Optional<A> {
//        return self.flatMap { maybe -> Future<Optional<B>> in
//            switch maybe {
//            case .some(let a): return f(a).map(Optional.some)
//            case .none: return self.eventLoop.newSucceededFuture(result: .none)
//            }
//        }
//    }
    
}

func flatMapTT<A,B>(f: @escaping (A) -> Future<B>) -> (Future<Optional<A>>) -> Future<Optional<B>> {
    return { future in
        future.flatMap { maybeA in
            return maybeA.map { a in
                f(a).map(Optional.some)
            } ?? future.map { _ in
                return (Optional<B>.none)
            }
        }
    }
}

//public func flatten<T>(_ future: Future<Result<T>>) -> Future<T> {
//    return future.flatMap { result -> Future<T> in
//        switch result {
//        case .success(let value):
//            return future.eventLoop.newSucceededFuture(result: value)
//        case .failure(let error):
//            return future.eventLoop.newFailedFuture(error: error)
//        }
//    }
//}
