//
//  ClientSocketHandler.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

public protocol ClientSocketHandler: class {
    associatedtype Socket: ClientSocket
    var isOpen: Bool { get }
    func handle(socket: Socket) throws
    var isClosing: Bool { get }
    func close()
    func closeIfIdleSocket()
    func softClose()
    init()
}
