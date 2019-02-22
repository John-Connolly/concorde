//
//  BodyStream.swift
//  concorde
//
//  Created by John Connolly on 2018-11-10.
//

import Foundation
import NIO

public final class BodyStream: DuplexStream {

    public typealias InputValue = ByteBuffer
    public typealias OutputValue = ByteBuffer

    public var yeild: ((StreamInput<ByteBuffer>) -> ())?

    public func connect<S>(to inputStream: S) -> S where S : Consumer, BodyStream.OutputValue == S.InputValue {
        yeild = { value in
            inputStream.await(value)
        }
        return inputStream
    }

    public func yeild(_ value: StreamInput<ByteBuffer>) {
        self.yeild?(value)
    }

    public func await(_ value: StreamInput<ByteBuffer>) {
        yeild(value)
    }

}
