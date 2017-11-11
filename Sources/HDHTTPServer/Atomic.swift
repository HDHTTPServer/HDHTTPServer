//
//  Atomic.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

import Dispatch

public class Atomic<T> {
    private let lock = DispatchSemaphore(value: 1)
    private var _value: T

    public init(_ value: T) {
        self._value = value
    }

    var value: T {
        get {
            lock.wait()
            defer {
                lock.signal()
            }
            return _value
        }
        set {
            lock.wait()
            defer {
                lock.signal()
            }
            _value = newValue
        }
    }
}
