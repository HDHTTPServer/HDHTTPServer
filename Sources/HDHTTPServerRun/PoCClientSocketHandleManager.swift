//
//  PoCClientSocketHandleManager.swift
//  HDHTTPServerPackageDescription
//
//  Created by ukitaka on 2017/11/22.
//

import Foundation
import HDHTTPServer
import Dispatch
#if os(Linux)
    @_exported import Glibc
#else
    @_exported import Darwin.C
#endif

final class PoCClientSocketHandleManager: ClientSocketHandlerManager {
    typealias Handler = PoCClientSocketHandler

    private var handlers: [Handler] = []

    var count: Int {
        return handlers.count
    }

    func add(handler: Handler) {
        handlers.append(handler)
    }
    
    func remove(handler: Handler) {
        if let i = handlers.index(of: handler) {
            handlers.remove(at: i)
        }
    }

    func closeAll() {
        handlers.forEach { h in
            h.close()
        }
    }

    func prune() {
        //TODO
        closeAll()
    }

    func acceptClientConnection(serverSocket: SSSocket) -> PoCClientSocket? {
        var maxRetryCount = 100

        var acceptFD: Int32 = -1
        repeat {
            var acceptAddr = sockaddr_in()
            var addrSize = socklen_t(MemoryLayout<sockaddr_in>.size)

            acceptFD = withUnsafeMutablePointer(to: &acceptAddr) { pointer in
                return accept(serverSocket.socketfd, UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: sockaddr.self), &addrSize)
            }
            if acceptFD < 0 && errno != EINTR {
                maxRetryCount = maxRetryCount - 1
            }
        }
            while acceptFD < 0 && maxRetryCount > 0

        if acceptFD < 0 {
            fatalError()
        }
        return PoCClientSocket(fd: acceptFD, isConnected: true)
    }
}
