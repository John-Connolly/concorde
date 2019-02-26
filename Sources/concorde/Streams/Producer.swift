//
//  PushStream.swift
//  concorde
//
//  Created by John Connolly on 2018-03-30.
//  Copyright © 2018 John Connolly. All rights reserved.
//

import Foundation

public typealias DuplexStream = Consumer & Producer

public protocol Producer: class {

    associatedtype OutputValue

    @discardableResult
    func connect<S>(to inputStream: S) -> S where S : Consumer, S.InputValue == OutputValue

    var yeild: ((StreamInput<OutputValue>) -> ())? { get set }

    func yeild(_ value: StreamInput<OutputValue>)
}
