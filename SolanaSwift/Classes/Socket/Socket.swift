//
//  Socket.swift
//  SolanaSwift
//
//  Created by Chung Tran on 03/12/2020.
//

import Foundation
import RxSwift
import Starscream
import RxCocoa

extension SolanaSDK {
    public class Socket {
        let disposeBag = DisposeBag()
        let socket: WebSocket
        let account: PublicKey?
        
        public let status = BehaviorRelay<Status>(value: .initializing)
        var wsHeartBeat: Timer!

        public init(endpoint: String, publicKey: PublicKey?) {
            var request = URLRequest(url: URL(string: endpoint)!)
            request.timeoutInterval = 5
            socket = WebSocket(request: request)
            account = publicKey
            defer {socket.delegate = self}
        }
        
        public func connect() {
            socket.connect()
        }
        
        deinit {
            socket.disconnect()
            unsubscribe(method: "accountSubscribe", params: [account?.base58EncodedString])
        }

        func onOpen() {
            status.accept(.connected)
            wsHeartBeat?.invalidate()
            wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
                // Ping server every 5s to prevent idle timeouts
                self.socket.write(ping: Data())
            }
            updateSubscriptions()
        }

        func onError(_ error: Error) {
            status.accept(.error(error))
            Logger.log(message: "Socket error: \(error.localizedDescription)", event: .error)
        }
        
        func onClose(_ code: Int) {
            wsHeartBeat?.invalidate()
            wsHeartBeat = nil
            
            if code == 1000 {
                // explicit close, check if any subscriptions have been made since close
                updateSubscriptions()
                return
            }
            
            // implicit close, prepare subscriptions for auto-reconnect
            resetSubscriptions()
        }
        
        func onNotification(_ notification: Notification.Account) {
            
        }
        
        func updateSubscriptions() {
            subscribe(method: "accountSubscribe", params: [account?.base58EncodedString])
        }
        
        func resetSubscriptions() {
        }
        
        private func subscribe(method: String, params: [Encodable]) {
            let requestAPI = RequestAPI(
                method: method,
                params: params + [["encoding":"jsonParsed"]]
            )
            write(requestAPI: requestAPI)
        }
        
        private func unsubscribe(method: String, params: [Encodable]) {
            let requestAPI = RequestAPI(
                method: method,
                params: params
            )
            write(requestAPI: requestAPI)
        }
        
        private func write(requestAPI: RequestAPI, completion: (() -> ())? = nil) {
            do {
                let data = try JSONEncoder().encode(requestAPI)
                guard let string = String(data: data, encoding: .utf8) else {
                    throw Error.other("Request is invalid \(requestAPI)")
                }
                socket.write(string: string, completion: {
                    Logger.log(message: "\(requestAPI.method) success", event: .event)
                    completion?()
                })
            } catch {
                Logger.log(message: "\(requestAPI.method) failed: \(error)", event: .event)
            }
        }
    }
}

extension SolanaSDK.Socket: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            status.accept(.connected)
            onOpen()
            Logger.log(message: "websocket is connected: \(headers)", event: .event)
        case .disconnected(let reason, let code):
            status.accept(.disconnected)
            onClose(Int(code))
            Logger.log(message: "websocket is disconnected: \(reason) with code: \(code)", event: .event)
            socket.connect()
        case .text(let string):
            Logger.log(message: "Received text: \(string)", event: .event)
        case .binary(let data):
            Logger.log(message: "Received data: \(data.count)", event: .event)
        case .ping(_):
//            Logger.log(message: "Socket ping", event: .event)
            break
        case .pong(_):
//            Logger.log(message: "Socket pong", event: .event)
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(let bool):
            Logger.log(message: "reconnectSuggested \(bool)", event: .event)
            if bool { socket.connect() }
        case .cancelled:
            status.accept(.disconnected)
        case .error(let error):
            if let error = error {
                status.accept(.error(error))
                Logger.log(message: "Socket error: \(error)", event: .error)
                onError(.socket(error))
                
                // reconnect
                socket.connect()
            }
        }
    }
}

extension SolanaSDK.Socket {
    public enum Status {
        case initializing
        case connected
        case disconnected
        case error(Error)
    }
}
