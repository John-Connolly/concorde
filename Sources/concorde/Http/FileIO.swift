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

    return fileIO.read(fileHandle: filehandle!,
                byteCount: 1024 * 1024,
                allocator: ByteBufferAllocator(),
                eventLoop: eventLoop)
}
