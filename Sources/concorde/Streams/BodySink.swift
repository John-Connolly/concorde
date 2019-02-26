//
//  BodySink.swift
//  concorde
//
//  Created by John Connolly on 2018-11-10.
//

import Foundation
import NIO

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
        case .error(_): () // TODO Handle this
        }
    }
}


final class Sink<I>: Consumer {

    typealias InputValue = I
    let drain: ((StreamInput<I>) -> ())

    public init(drain: @escaping ((StreamInput<I>) -> ())) {
        self.drain = drain
    }

    func await(_ value: StreamInput<I>) {
        drain(value)
    }
    
}
