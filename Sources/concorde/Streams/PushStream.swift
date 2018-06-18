//
//  PushStream.swift
//  concorde
//
//  Created by John Connolly on 2018-03-30.
//  Copyright © 2018 John Connolly. All rights reserved.
//

import Foundation

typealias DuplexStream = PushStream & PullStream

protocol PushStream: class {
    associatedtype OutputValue
    func output<S>(to inputStream: S) where S : PullStream, S.InputValue == OutputValue
}


extension PushStream where Self: ConnectionContext {

    @discardableResult
    func stream<S>(to stream: S) -> S where S: PullStream, S.InputValue == Self.OutputValue {
        output(to: stream)
        stream.upstream = self
        return stream
    }

}

final class AnyPushStream<T>: PushStream {

    typealias OutputValue = T
    private let onOutput: (AnyPullStream<T>) -> ()

    init<S: PushStream>(_ wrapped: S) where S: OutputStream, S.OutputValue == T {
        onOutput = { [unowned wrapped] inputStream in
            wrapped.output(to: inputStream)
        }
    }

    func output<S>(to inputStream: S) where S : PullStream, AnyPushStream.OutputValue == S.InputValue {
        onOutput(AnyPullStream<T>(inputStream))
    }
}
