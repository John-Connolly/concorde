//
//  Consumer.swift
//  concorde
//
//  Created by John Connolly on 2018-07-14.
//

import Foundation

public enum StreamInput<Value> {
    case input(Value)
    case complete
    case error(Error)
}

public protocol Consumer: class {

    associatedtype InputValue

    func await(_ value: StreamInput<InputValue>)
}
