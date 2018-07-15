//
//  InputStream.swift
//  concorde
//
//  Created by John Connolly on 2018-07-14.
//

import Foundation

public enum StreamInput<Value> {
    case input(Value)
    case end
    case error(Error)
}

public protocol InputStream: class {
    associatedtype InputValue
    func input(_ value: StreamInput<InputValue>)
}
