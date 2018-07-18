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

    var input: ((StreamInput<ByteBuffer>) -> ())?

    public func output<S>(to inputStream: S) where S : InputStream, BodyStream.OutputValue == S.InputValue {
        input = { value in
            inputStream.input(value)
        }
    }

    public func input(_ value: StreamInput<ByteBuffer>) {
         self.input?(value)
    }

}

let utf8String = .utf8 |> flip(curry(String.init(data:encoding:)))


public final class CSVStream: DuplexStream {
    public typealias InputValue = ByteBuffer
    public typealias OutputValue = ByteBuffer

    var input: ((StreamInput<ByteBuffer>) -> ())?

    public var done: (() -> ())?

    public init() { }
    public func output<S>(to inputStream: S) where S : InputStream, BodyStream.OutputValue == S.InputValue {
        input = { value in
            inputStream.input(value)
        }
    }

    public func input(_ value: StreamInput<ByteBuffer>) {
        switch value {
        case .input(let input):
            guard let bytes = input.getBytes(at: 0, length: input.readableBytes) else {
                return
            }
            print((bytes |> (Data.init >>> utf8String)) ?? "")
        case .end:
            done?()
        case .error(_): ()

        }
        self.input?(value)
    }

}



public typealias DuplexStream = InputStream & PushStream

public final class BodySink: InputStream {

    public typealias InputValue = ByteBuffer

    var data = Data()
    let drain: ((Data) -> ())

    public init(drain: @escaping ((Data) -> ())) {
        self.drain = drain
    }

    public func input(_ value: StreamInput<ByteBuffer>) {
        switch value {
        case .input(let buffer):
            guard let data = buffer.getBytes(at: 0, length: buffer.readableBytes) else {
                return
            }
            self.data.append(contentsOf: data)
        case .end:
            drain(data)
        case .error(_): ()
        }
    }
}
