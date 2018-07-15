//
//  PushStream.swift
//  concorde
//
//  Created by John Connolly on 2018-03-30.
//  Copyright © 2018 John Connolly. All rights reserved.
//

import Foundation

//typealias DuplexStream = PushStream & PullStream

public protocol PushStream: class {
    associatedtype OutputValue
    func output<S>(to inputStream: S) where S : InputStream, S.InputValue == OutputValue
}
