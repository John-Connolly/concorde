////
////  ChunkedStream.swift
////  concorde
////
////  Created by John Connolly on 2019-02-22.
////
//
//import Foundation
//import NIO
//
//public final class ChunkedStream: DuplexStream {
//
//    public typealias InputValue = ByteBuffer
//    public typealias OutputValue = Data
//
//    public func await(_ value: StreamInput<ByteBuffer>) {
//        switch value {
//        case .input(let bytes):
//            let start = String(bytes.readableBytes, radix: 16, uppercase: true) + "/r/n"
//            var chunk = Data(start.utf8)
//            chunk.append(contentsOf: bytes.getBytes(at: 0, length: bytes.readableBytes)!)
//            chunk.append(contentsOf: "/r/n".utf8)
//            yeild?(.input(chunk))
//        case .complete:
//            yeild?(.complete)
//        case .error(let error):
//            yeild?(.error(error))
//        }
//    }
//
//    public func connect<S>(to inputStream: S) -> S where S : Consumer, ChunkedStream.OutputValue == S.InputValue {
//        yeild = { value in
//            inputStream.await(value)
//        }
//        return inputStream
//    }
//
//    public var yeild: ((StreamInput<Data>) -> ())?
//
//    public func yeild(_ value: StreamInput<Data>) {
//        self.yeild?(value)
//    }
//
//
//}
