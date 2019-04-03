//
//  Future+Monad.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation
import NIO


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
