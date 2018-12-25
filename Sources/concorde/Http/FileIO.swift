//
//  FileIO.swift
//  concorde
//
//  Created by John Connolly on 2018-12-25.
//

import Foundation
import NIO


let threadPool : BlockingIOThreadPool = {
    let tp = BlockingIOThreadPool(numberOfThreads: 4)
    tp.start()
    return tp
}()

func readFile(path: String,
              eventLoop: EventLoop,
              maxSize: Int = 1024 * 1024,
              _ cb: @escaping (Error?, ByteBuffer? ) -> ())
{

    func emit(error: Error? = nil, result: ByteBuffer? = nil) {
        if eventLoop.inEventLoop { cb(error, result) }
        else { eventLoop.execute { cb(error, result) } }
    }


    let fh : NIO.FileHandle
    do {
        fh = try NIO.FileHandle(path: path)
    }
    catch { return emit(error: error) }


    let fileIO = NonBlockingFileIO.init(threadPool: threadPool)

    fileIO.read(fileHandle : fh, byteCount: maxSize,
                allocator  : ByteBufferAllocator(),
                eventLoop  : eventLoop)
        .map         { try? fh.close(); emit(result: $0) }
        .whenFailure { try? fh.close(); emit(error:  $0) }
}
