//
//  ClientSocket.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

public protocol ClientSocket {
    init(fd: FileDescriptor, isConnected: Bool)
}
