//
//  BodyStream.swift
//  concorde
//
//  Created by John Connolly on 2018-07-14.
//

import Foundation
import NIO

public final class BodyStream: DuplexStream {

    public typealias InputValue = ByteBuffer
    public typealias OutputValue = ByteBuffer

    public var yeild: ((StreamInput<ByteBuffer>) -> ())?

    public func connect<S>(to inputStream: S) where S : Consumer, BodyStream.OutputValue == S.InputValue {
        yeild = { value in
            inputStream.await(value)
        }
    }

    public func yeild(_ value: StreamInput<ByteBuffer>) {
        self.yeild?(value)
    }

    public func await(_ value: StreamInput<ByteBuffer>) {
        yeild(value)
    }

}

let utf8String = .utf8 |> flip(curry(String.init(data:encoding:)))


public final class CSVStream: DuplexStream {
    public func yeild(_ value: StreamInput<ByteBuffer>) { }

    public typealias InputValue = ByteBuffer
    public typealias OutputValue = ByteBuffer

    public var yeild: ((StreamInput<ByteBuffer>) -> ())?

    public var done: (() -> ())?

    public init() { }
    public func connect<S>(to inputStream: S) where S : Consumer, BodyStream.OutputValue == S.InputValue {
        yeild = { value in
            inputStream.await(value)
        }
    }

    public func await(_ value: StreamInput<ByteBuffer>) {
        switch value {
        case .input(_):
            print("Input!")
//            guard let bytes = input.getBytes(at: 0, length: input.readableBytes) else {
//                return
//            }
//            print((bytes |> (Data.init >>> utf8String)) ?? "")
        case .complete:
            done?()
        case .error(_): ()

        }
        self.yeild?(value)
    }

}



public final class BodySink: Consumer {

    public typealias InputValue = ByteBuffer

    var data = Data()
    let drain: ((Data) -> ())

    public init(drain: @escaping ((Data) -> ())) {
        self.drain = drain
    }

    public func await(_ value: StreamInput<ByteBuffer>) {
        switch value {
        case .input(let buffer):
            guard let data = buffer.getBytes(at: 0, length: buffer.readableBytes) else {
                return
            }
            self.data.append(contentsOf: data)
        case .complete:
            drain(data)
        case .error(_): ()
        }
    }
}
