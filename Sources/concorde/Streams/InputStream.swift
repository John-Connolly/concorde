//
//  InputStream.swift
//  concorde
//
//  Created by John Connolly on 2018-07-14.
//

import Foundation

enum StreamInput<Value> {
    case input(Value)
    case complete
    case error(Error)
}

protocol InputStream: class {
    associatedtype InputValue
    func input(_ value: Input<InputValue>)
}
