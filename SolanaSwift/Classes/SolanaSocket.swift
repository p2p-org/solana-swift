//
//  SolanaSocket.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/4/20.
//

import Foundation
import SocketIO
import RxCocoa

public class SolanaSocket {
    public enum Status {
        case initializing
        case connected
        case disconnected
        case error(Error)
    }
    #if DEBUG
    let endpoint = "wss://testnet.solana.com"
    #else
    let endpoint = "wss://testnet.solana.com"
    #endif
    
    lazy var manager = SocketManager(socketURL: URL(string: endpoint)!, config: [.log(true), .compress, .reconnectAttempts(-1)])
    public lazy var socket = manager.defaultSocket
    
    public let status = BehaviorRelay<Status>(value: .initializing)
    var wsHeartBeat: Timer!
    
    public static let shared = SolanaSocket()
    private init() {
        socket.on("open") { _,_  in self.onOpen() }
        socket.on("error") { (data, _) in
            guard let error = data[0] as? Error else {return}
            self.onError(error)
        }
        socket.on("close") { data,_ in
            guard let code = data[0] as? Int else {return}
            self.onClose(code)
        }
        socket.on("accountNotification") { data,_ in
            guard let info = data[0] as? SolanaSDK.AccountNotification else {return}
            self.onNotification(info)
        }
        socket.connect()
    }
    
    func onOpen() {
        status.accept(.connected)
        wsHeartBeat?.invalidate()
        wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            // Ping server every 5s to prevent idle timeouts
            self.socket.emit("ping")
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
    
    func onNotification(_ notification: SolanaSDK.AccountNotification) {
        
    }
    
    func updateSubscriptions() {
        
    }
    
    func resetSubscriptions() {
        
    }
}
