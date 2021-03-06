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
    func remove(handler: Handler)
    func fetchIdleHandler() -> Handler
    func closeAll(done: () -> Void)
    func prune()
    // FIXME: looks awful... will move to appropriate class.
    func acceptClientConnection(serverSocket: SSSocket) -> Handler.Socket?
}
