import Foundation
import HDHTTPServer
import HTTP

let socket = SSSocket()!
print("port: \(socket.listeningPort)")

let manager = PoCClientSocketHandleManager()
let server = HDHTTPServer(serverSocket: socket, clientSocketHandlerManager: manager)

try! server.start(port: 8080)

CFRunLoopRun()
