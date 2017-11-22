//
//  PoCClientSocket.swift
//  HDHTTPServerRun
//
//  Created by Yuki Takahashi on 2017/11/11.
//

import Foundation
import HDHTTPServer
import Dispatch

public enum PoCSocketError: Error {
    case SocketOSError(errno: Int32)
    case InvalidSocketError
    case InvalidReadLengthError
    case InvalidWriteLengthError
    case InvalidBufferError
}

class PoCClientSocket: ClientSocket {

    required init(fd: FileDescriptor, isConnected: Bool) {
        self.socketfd = fd
        self.isConnected = isConnected
    }

    var scheme: String {
        return "http"
    }

    var hostname: String {
        return "0.0.0.0"
    }
    var port: Int32 {
        return listeningPort
    }

    var address: String {
        return "" //FIXME
    }

    var socketfd: Int32 = -1
    var listeningPort: Int32 = -1
    private(set) var isConnected = false
    private let isShuttingDown = Atomic<Bool>(false)

    @discardableResult func socketWrite(from buffer: UnsafeRawPointer, bufSize: Int) throws -> Int {
        if socketfd <= 0 {
            throw PoCSocketError.InvalidSocketError
        }
        if bufSize < 0 || bufSize > Int(Int32.max) {
            throw PoCSocketError.InvalidWriteLengthError
        }

        //Make sure we weren't handed a nil buffer
        let writeBufferPointer: UnsafeRawPointer! = buffer
        if writeBufferPointer == nil {
            throw PoCSocketError.InvalidBufferError
        }

        let sent = send(self.socketfd, buffer, Int(bufSize), Int32(0))
        //Leave this as a local variable to facilitate Setting a Watchpoint in lldb
        return sent
    }

    func shutdownAndClose() {
        self.isShuttingDown.value = true
        if socketfd < 1 {
            return
        }
        if isConnected {
            _ = shutdown(self.socketfd, Int32(SHUT_RDWR))
        }
        self.isConnected = false
        close(self.socketfd)
    }
}
