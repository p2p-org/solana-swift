//
//  Socket+WebSocketDelegate.swift
//  SolanaSwift
//
//  Created by Chung Tran on 31/05/2021.
//

import Foundation
import Starscream

extension SolanaSDK.Socket: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            Logger.log(message: "websocket is connected: \(headers)", event: .event)
            status.accept(.connected)
            onOpen()
        case .disconnected(let reason, let code):
            Logger.log(message: "websocket is disconnected: \(reason) with code: \(code)", event: .event)
            status.accept(.disconnected)
            onClose(Int(code))
            socket.connect()
        case .text(let string):
            Logger.log(message: "Received text: \(string)", event: .event)
            if let data = string.data(using: .utf8) {
                dataSubject.onNext(data)
            }
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
                onError(SolanaSDK.Error.socket(error))
            }
            // reconnect
            socket.connect()
        }
    }
    
    // MARK: - Handlers
    /// On socket opened
    func onOpen() {
        // wipe old subscriptions
        unsubscribeToAllSubscriptions()
        
        // set status
        status.accept(.connected)
        
        // set heart beat
        wsHeartBeat?.invalidate()
        wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            // Ping server every 5s to prevent idle timeouts
            self?.socket.write(ping: Data())
        }
        
        // resubscribe
        subscribeToAllAccounts()
    }
    
    /// On socket error
    /// - Parameter error: socket's error
    func onError(_ error: Error) {
        status.accept(.error(error))
        Logger.log(message: "Socket error: \(error.localizedDescription)", event: .error)
    }
    
    /// On socket closed
    /// - Parameter code: code
    func onClose(_ code: Int) {
        wsHeartBeat?.invalidate()
        wsHeartBeat = nil
    }
}
