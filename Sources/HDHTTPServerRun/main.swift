import Foundation
import HDHTTPServer
import HTTP

let socket = SSSocket()!
print("port: \(socket.listeningPort)")

CFRunLoopRun()
