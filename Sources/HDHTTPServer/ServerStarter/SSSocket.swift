//
//  SSSocket.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

import Foundation
import Dispatch

public enum SSSocketError: Error {
    case SocketOSError(errno: Int32)
    case InvalidSSSocketError
    case InvalidReadLengthError
    case InvalidWriteLengthError
    case InvalidBufferError
}

public class SSSocket {
    let socketfd: FileDescriptor

    let listeningPort: Port

    public init(fd: FileDescriptor, port: Port) {
        self.socketfd = fd
        self.listeningPort = port
    }

    func socketRead(into readBuffer: inout UnsafeMutablePointer<Int8>, maxLength:Int) throws -> Int {
        if maxLength <= 0 || maxLength > Int(Int32.max) {
            throw SSSocketError.InvalidReadLengthError
        }
        if socketfd <= 0 {
            throw SSSocketError.InvalidSSSocketError
        }

        let readBufferPointer: UnsafeMutablePointer<Int8>! = readBuffer
        if readBufferPointer == nil {
            throw SSSocketError.InvalidBufferError
        }

        readBuffer.initialize(to: 0x0, count: maxLength)

        return recv(self.socketfd, readBuffer, maxLength, Int32(0))
    }

    func acceptClientConnection<Socket: ClientSocket>() throws -> Socket? {
        var retVal = Socket()

        var maxRetryCount = 100

        var acceptFD: Int32 = -1
        repeat {
            var acceptAddr = sockaddr_in()
            var addrSize = socklen_t(MemoryLayout<sockaddr_in>.size)

            acceptFD = withUnsafeMutablePointer(to: &acceptAddr) { pointer in
                return accept(self.socketfd, UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: sockaddr.self), &addrSize)
            }
            if acceptFD < 0 && errno != EINTR {
                maxRetryCount = maxRetryCount - 1
                print("Could not accept on socket \(socketfd). Error is \(errno). Will retry.")
            }
        }
            while acceptFD < 0 && maxRetryCount > 0

        if acceptFD < 0 {
            throw SSSocketError.SocketOSError(errno: errno)
        }

        retVal.isConnected = true
        retVal.socketfd = acceptFD

        return retVal
    }

    /// Sets the socket to Blocking or non-blocking mode.
    ///
    /// - Parameter mode: true for blocking, false for nonBlocking
    /// - Returns: `fcntl(2)` flags
    /// - Throws: SSSocketError if `fcntl` fails
    @discardableResult func setBlocking(mode: Bool) throws -> Int32 {
        let flags = fcntl(self.socketfd, F_GETFL)
        if flags < 0 {
            //Failed
            throw SSSocketError.SocketOSError(errno: errno)
        }

        let newFlags = mode ? flags & ~O_NONBLOCK : flags | O_NONBLOCK

        let result = fcntl(self.socketfd, F_SETFL, newFlags)
        if result < 0 {
            //Failed
            throw SSSocketError.SocketOSError(errno: errno)
        }
        return result
    }
}
