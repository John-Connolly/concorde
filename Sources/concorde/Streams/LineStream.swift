//
//  BodyStream.swift
//  concorde
//
//  Created by John Connolly on 2018-07-14.
//

import Foundation
import NIO

let utf8String = .utf8 |> flip(curry(String.init(data:encoding:)))

public final class CSVStream: DuplexStream {
    public func yeild(_ value: StreamInput<ByteBuffer>) { }

    public typealias InputValue = ByteBuffer
    public typealias OutputValue = ByteBuffer

    public var yeild: ((StreamInput<ByteBuffer>) -> ())?
    public var done: (() -> ())?

    public init() { }
    public func connect<S>(to inputStream: S) -> S where S : Consumer, BodyStream.OutputValue == S.InputValue {
        yeild = { value in
            inputStream.await(value)
        }
        return inputStream
    }

    public func await(_ value: StreamInput<ByteBuffer>) {
        switch value {
        case .input(_):
            print("Input!")
        case .complete:
            done?()
        case .error(_): ()
        }
        self.yeild?(value)
    }

}
