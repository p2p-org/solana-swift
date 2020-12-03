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
        weak var httpClient: SolanaSoketHttpClient?
        
        let socket: WebSocket
        
        public let status = BehaviorRelay<Status>(value: .initializing)
        var wsHeartBeat: Timer!

        public init(endpoint: String, httpClient: SolanaSoketHttpClient) {
            var request = URLRequest(url: URL(string: endpoint)!)
            request.timeoutInterval = 5
            socket = WebSocket(request: request)
            socket.delegate = self
            
            self.httpClient = httpClient
        }
        
        public func connect() {
            socket.connect()
        }
        
        deinit {
            socket.disconnect()
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
            httpClient?.accountSubscribe()
                .subscribe(onSuccess: {number in
                    Logger.log(message: "Account subscribed: \(number)", event: .event)
                }, onError: { (error) in
                    Logger.log(message: "Account subscribed failed: \(error)", event: .error)
                })
                .disposed(by: disposeBag)
        }
        
        func resetSubscriptions() {
            httpClient?.accountUnsubscribe()
                .subscribe(onSuccess: {bool in
                    Logger.log(message: "Account unsubscribed: \(bool)", event: .event)
                }, onError: { (error) in
                    Logger.log(message: "Account unsubscribed failed: \(error)", event: .error)
                })
                .disposed(by: disposeBag)
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
