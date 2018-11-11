//
//  Future.swift
//  concorde
//
//  Created by John Connolly on 2018-10-23.
//

import Foundation
import NIO

public typealias Future = EventLoopFuture
public typealias Promise = EventLoopPromise


extension Future {

//    static func wrap<T: ResponseRepresentable>(f: @escaping  () -> T) -> Future<T> {
//        Future.
//    }

}

public typealias Resp<T> = (EventLoop) -> Future<T>

public func impure<T>(_ val: T) -> (EventLoop) -> Future<T> {
    return { loop in
        loop.newSucceededFuture(result: val)
    }
}
