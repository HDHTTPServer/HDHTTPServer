//
//  PoCClientSocketHandleManager.swift
//  HDHTTPServerPackageDescription
//
//  Created by ukitaka on 2017/11/22.
//

import Foundation
import HDHTTPServer
import Dispatch

final class PoCClientSocketHandleManager: ClientSocketHandlerManager {
    typealias Handler = PoCClientSocketHandler

    private var handlers: [Handler] = []

    var count: Int {
        return handlers.count
    }

    func add(handler: Handler) {
        handlers.append(handler)
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
}
