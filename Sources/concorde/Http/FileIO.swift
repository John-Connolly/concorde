//
//  FileIO.swift
//  concorde
//
//  Created by John Connolly on 2018-12-25.
//

import Foundation
import NIO

func read(from path: String, on eventLoop: EventLoop, threadPool: BlockingIOThreadPool) -> Future<ByteBuffer> {
    let filehandle = try? NIO.FileHandle(path: path)
    let fileIO = NonBlockingFileIO(threadPool: threadPool)
    let future = fileIO.read(fileHandle: filehandle!,
                             byteCount: 1024 * 1024,
                             allocator: ByteBufferAllocator(),
                             eventLoop: eventLoop)
    future.whenComplete {
        try? filehandle?.close()
    }
    future.whenFailure {
        print($0)
    }
    return future
}

public func fileServing(fileName: String) -> Middleware {
    return { conn in
        let directory = #file
        let fileDirectory = directory.components(separatedBy: "/Sources").first! + "/public/" + fileName
        return read(from: fileDirectory, on: conn.eventLoop, threadPool: conn.threadPool).map { bytes -> Conn in
            conn.response.data = .byteBuffer(bytes)
            return conn
        }
    }
}
