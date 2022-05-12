//
//  Socket+WebSocketDelegate.swift
//  SolanaSwift
//
//  Created by Chung Tran on 31/05/2021.
//

import Foundation
import Starscream
import LoggerSwift

extension Socket: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            Logger.log(event: .event, message: "websocket is connected: \(headers)")
            status.accept(.connected)
            onOpen()
        case .disconnected(let reason, let code):
            Logger.log(event: .event, message: "websocket is disconnected: \(reason) with code: \(code)")
            status.accept(.disconnected)
            onClose(Int(code))
            socket.connect()
        case .text(let string):
            Logger.log(event: .event, message: "Received text: \(string)")
            if let data = string.data(using: .utf8) {
                dataSubject.onNext(data)
            }
        case .binary(let data):
            Logger.log(event: .event, message: "Received data: \(data.count)")
        case .ping(_):
//            Logger.log(message: "Socket ping", event: .event)
            break
        case .pong(_):
//            Logger.log(message: "Socket pong", event: .event)
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(let bool):
            Logger.log(event: .event, message: "reconnectSuggested \(bool)")
            if bool { socket.connect() }
        case .cancelled:
            status.accept(.disconnected)
        case .error(let error):
            if let error = error {
                onError(SolanaError.socket(error))
            }
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
        guard !status.value.isError else {return}
        status.accept(.error(error))
        Logger.log(event: .error, message: "Socket error: \(error.localizedDescription)")
    }
    
    /// On socket closed
    /// - Parameter code: code
    func onClose(_ code: Int) {
        wsHeartBeat?.invalidate()
        wsHeartBeat = nil
    }
}
