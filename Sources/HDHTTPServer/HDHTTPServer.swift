//
//  HDHTTPServer.swift
//  HDHTTPServer
//
//  Created by Yuki Takahashi on 2017/11/11.
//

import Dispatch
import Signals

// For @convention closure.
private var currentSocketHandlerManager: AnyClientSocketHandlerManager? = nil

public class HDHTTPServer<SocketHandlerManager: ClientSocketHandlerManager> {
    typealias SocketHandler = SocketHandlerManager.Handler
    typealias Socket = SocketHandlerManager.Handler.Socket

    private let serverSocket: SSSocket

    private var clientSocketHandlerManager: SocketHandlerManager

    /// Timer that cleans up idle sockets on expire
    private let pruneSocketTimer: DispatchSourceTimer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "pruneSocketTimer"))

    public var port: UInt16 {
        return UInt16(serverSocket.listeningPort)
    }

    public init(serverSocket: SSSocket, clientSocketHandlerManager: SocketHandlerManager) {
        self.serverSocket = serverSocket
        self.clientSocketHandlerManager = clientSocketHandlerManager
    }

    private var queueMax: Int = 4
    private var acceptMax: Int = 8
    private let _isShuttingDownLock = DispatchSemaphore(value: 1)
    private var _isShuttingDown: Bool = false

    let isShuttingDown = Atomic<Bool>(false)

    /// Starts the server listening on a given port
    ///
    /// - Parameters:
    ///   - port: TCP port. See listen(2)
    ///   - handler: Function that creates the HTTP Response from the HTTP Request
    /// - Throws: Error (usually a socket error) generated
    public func start(port: UInt16 = 0,
                      queueCount: Int = 0,
                      acceptCount: Int = 0,
                      maxReadLength: Int = 1048576,
                      keepAliveTimeout: Double = 5.0) throws {

        currentSocketHandlerManager = AnyClientSocketHandlerManager(clientSocketHandlerManager)

        Signals.ignore(signal: .pipe)

        Signals.trap(signal: .term) { signal in
            print("Receive SIGTERM from start_server process.")
            currentSocketHandlerManager?.closeAll()
            //FIXME: Not graceful yet. Call exit(0) after all processes are shut down
            exit(0)
        }

        if queueCount > 0 {
            queueMax = queueCount
        }
        if acceptCount > 0 {
            acceptMax = acceptCount
        }

        Array(0..<acceptMax).forEach { _ in
            self.clientSocketHandlerManager.add(handler: SocketHandler())
        }

        pruneSocketTimer.setEventHandler { [weak self] in
            // FIXME
            // self?.clientSocketHandlerManager.prune()
        }
        pruneSocketTimer.schedule(deadline: .now() + keepAliveTimeout,
                                  repeating: .seconds(Int(keepAliveTimeout)))
        pruneSocketTimer.resume()

        let acceptQueue = DispatchQueue(label: "Accept Queue", qos: .default, attributes: .concurrent)
        let acceptSemaphore = DispatchSemaphore.init(value: acceptMax)

        DispatchQueue.global().async {
            repeat {
                let acceptedClientSocket: Socket? = self.clientSocketHandlerManager.acceptClientConnection(serverSocket: self.serverSocket)
                guard let clientSocket = acceptedClientSocket else {
                    if self.isShuttingDown.value {
                        print("Received nil client socket - exiting accept loop")
                    }
                    break
                }
                let handler = self.clientSocketHandlerManager.fetchIdleHandler();
                acceptSemaphore.wait()
                acceptQueue.async { [weak handler] in
                    do {
                        defer {
                            handler?.close() { }
                        }
                        try handler?.handle(socket: clientSocket)
                    }
                    catch {
                        print(error)
                    }

                    acceptSemaphore.signal()
                }
            } while !self.isShuttingDown.value
        }

        let semaphore = DispatchSemaphore(value: 0)
        semaphore.wait()
    }

    /// Stop the server and close the sockets
    public func stop() {
        isShuttingDown.value = true
        clientSocketHandlerManager.closeAll()
    }

    /// Count the connections - can be used in XCTests
    public var connectionCount: Int {
        return clientSocketHandlerManager.count
    }
}
