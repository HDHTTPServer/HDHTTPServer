//
//  ClientSocketHandlerManager.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

import Foundation

public protocol ClientSocketHandlerManager {
    associatedtype Handler: ClientSocketHandler
    var count: Int { get }
    func add(handler: Handler)
    func closeAll()
    func prune()
}

//FIXME: conform to `ClientSocketHandlerManager`
final class AnyClientSocketHandlerManager {
    private let _closeAll: () -> Void

    init<Manager: ClientSocketHandlerManager>(_ manager: Manager) {
        self._closeAll = manager.closeAll
    }

    func closeAll() {
        self._closeAll()
    }
}
