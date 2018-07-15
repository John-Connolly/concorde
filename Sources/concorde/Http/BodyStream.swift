//
//  BodyStream.swift
//  concorde
//
//  Created by John Connolly on 2018-07-14.
//

import Foundation
import NIO

public final class BodyStream: PushStream {

    typealias OutputValue = ByteBuffer


    func output<S>(to inputStream: S) where S : PullStream, BodyStream.OutputValue == S.InputValue {

    }
}

public final class BodySink: InputStream {

    typealias InputValue = ByteBuffer

    var data = Data()
    var drain: ((Data) -> ())?

    func input(_ value: Input<ByteBuffer>) {
        switch value {
        case .input(let buffer):
            guard let data = buffer.getBytes(at: 0, length: buffer.readableBytes) else {
                return
            }
            self.data.append(contentsOf: data)
        case .done:
            drain?(data)
        }
    }


}
