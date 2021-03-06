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

public func impure<T>(_ val: T) -> (EventLoop) -> Future<T> {
    return { loop in
        loop.makeSucceededFuture(val)
    }
}
