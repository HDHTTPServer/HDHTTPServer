//
//  SSSocket.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

import Foundation
import Dispatch

#if os(Linux)
    @_exported import Glibc
#else
    @_exported import Darwin.C
#endif

public enum SSSocketError: Error {
    case SocketOSError(errno: Int32)
    case InvalidSSSocketError
    case InvalidReadLengthError
    case InvalidWriteLengthError
    case InvalidBufferError
}

public class SSSocket {
    public let socketfd: FileDescriptor
    public let listeningPort: UInt16

    public init?() {
        let env = ProcessInfo().environment

        guard let value = env["SERVER_STARTER_PORT"] else {
            return nil
        }

        guard let port = UInt16(value.components(separatedBy: "=")[0]) else {
            return nil
        }

        guard let fd = FileDescriptor(value.components(separatedBy: "=")[1]) else {
            return nil
        }

        self.socketfd = fd
        self.listeningPort = port
    }

    public init(fd: FileDescriptor, port: UInt16) {
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
}
