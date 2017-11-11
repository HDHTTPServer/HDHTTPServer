//
//  ClientSocket.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

public protocol ClientSocket {
    var socketfd: FileDescriptor { get set }
    var isConnected: Bool { get set }
    init()
}
