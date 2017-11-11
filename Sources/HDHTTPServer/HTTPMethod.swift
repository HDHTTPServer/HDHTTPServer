//
//  HTTPMethod.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

import Foundation

public enum HTTPMethod: String {
    /// DELETE method.
    case delete
    /// GET method.
    case get
    /// HEAD method.
    case head
    /// POST method.
    case post
    /// PUT method.
    case put
    /// CONNECT method.
    case connect
    /// OPTIONS method.
    case options
    /// TRACE method.
    case trace
    /// COPY method.
    case copy
    /// LOCK method.
    case lock
    /// MKCOL method.
    case mkcol
    /// MOVE method.
    case move
    /// PROPFIND method.
    case propfind
    /// PROPPATCH method.
    case proppatch
    /// SEARCH method.
    case search
    /// UNLOCK method.
    case unlock
    /// BIND method.
    case bind
    /// REBIND method.
    case rebind
    /// UNBIND method.
    case unbind
    /// ACL method.
    case acl
    /// REPORT method.
    case report
    /// MKACTIVITY method.
    case mkactivity
    /// CHECKOUT method.
    case checkout
    /// MERGE method.
    case merge
    /// MSEARCH method.
    case msearch
    /// NOTIFY method.
    case notify
    /// SUBSCRIBE method.
    case subscribe
    /// UNSUBSCRIBE method.
    case unsubscribe
    /// PATCH method.
    case patch
    /// PURGE method.
    case purge
    /// MKCALENDAR method.
    case mkcalendar
    /// LINK method.
    case link
    /// UNLINK method.
    case unlink
}

public extension HTTPMethod {
    var name: String {
        return rawValue.uppercased()
    }
}

extension HTTPMethod: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral.lowercased())!
    }

    public init(unicodeScalarLiteral: String) {
        self.init(rawValue: unicodeScalarLiteral.lowercased())!
    }

    public init(extendedGraphemeClusterLiteral: String) {
        self.init(rawValue: extendedGraphemeClusterLiteral.lowercased())!
    }
}

extension HTTPMethod: CustomStringConvertible {
    public var description: String {
        return name
    }
}
