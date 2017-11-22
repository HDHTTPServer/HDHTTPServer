//
//  ClientSocket.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

public protocol ClientSocket {
    associatedtype Address
    var scheme: String { get }
    var hostname: String { get }
    var port: Port { get }
    var address: Address { get }
}
