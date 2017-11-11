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
