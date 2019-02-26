//
//  ChunckStream.swift
//  concorde
//
//  Created by John Connolly on 2019-02-22.
//

import Foundation
import NIO

final class ChunkedStream: DuplexStream {

    typealias InputValue = ByteBuffer

    typealias OutputValue = ByteBuffer

    func await(_ value: StreamInput<ByteBuffer>) {
        switch value {
        case .input(let bytes): ()
//            bytes.readableBytes convert to hex
            // end with /r/n
        case .complete:
            ()
        case .error(_):
            ()
        }
    }

    func connect<S>(to inputStream: S) -> S where S : Consumer, ChunkedStream.OutputValue == S.InputValue {
        return inputStream
    }

    var yeild: ((StreamInput<ByteBuffer>) -> ())?

    func yeild(_ value: StreamInput<ByteBuffer>) {

    }


}
