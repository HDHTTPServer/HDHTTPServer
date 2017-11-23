//
//  PoCClientSocketHandler.swift
//  HDHTTPServerRun
//
//  Created by ukitaka on 2017/11/22.
//

import Foundation
import HDHTTPServer
import Dispatch

final class PoCClientSocketHandler: ClientSocketHandler, Equatable {
    typealias Socket = PoCClientSocket

    private let id: String;
    
    private var socket: Socket? = nil
    
    var isClosing: Bool = false
    
    init() {
        self.id = NSUUID().uuidString
    }

    var isOpen: Bool {
        return socket?.isConnected ?? false
    }

    static func ==(lhs: PoCClientSocketHandler, rhs: PoCClientSocketHandler) -> Bool {
        return lhs.id == rhs.id
    }

    func handle(socket: Socket) {
        self.socket = socket
        print("handle client socket fd=\(socket.socketfd)")
        let data = """
HTTP/1.1 200 OK
Date: Wed, 22 Nov 2017 02:18:40 GMT
Content-Type: text/html; charset=utf-8
Connection: close

hello world!
""".data(using: .utf8)!

        do {
            var written: Int = 0
            var offset = 0

            print("writing...")

            while written < data.count {
                try data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
                    let result = try socket.socketWrite(from: ptr + offset, bufSize:
                        data.count - offset)
                    if result < 0 {
                        print("Received broken write socket indication")
                    } else {
                        written += result
                    }
                }
                offset = data.count - written
            }
        } catch {
            print("Received write socket error: \(error)")
            close() {
                // TODO: Remove a handler from manager
            }
        }
    }

    func close(done: () -> Void) {
        socket?.shutdownAndClose()
        socket = nil
        done()
    }

    func closeIfIdleSocket() {
        // do nothing
    }

    func softClose(done: () -> Void) {
        if (isOpen) {
            isClosing = true
        } else {
            close(done: done)
        }
    }
}
