//
//  Socket.swift
//  SolanaSwift
//
//  Created by Chung Tran on 03/12/2020.
//

import Foundation
import RxSwift
import SocketIO
import RxCocoa

extension SolanaSDK {
    public class Socket {
        let manager: SocketManager
        public lazy var socket = manager.defaultSocket
        
        public let status = BehaviorRelay<Status>(value: .initializing)
        var wsHeartBeat: Timer!

        public init(endpoint: String) {
            manager = SocketManager(socketURL: URL(string: endpoint)!, config: [.log(true), .compress, .reconnectAttempts(-1)])
            
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
                guard let string = data.first as? String else {
                    Logger.log(message: String.init(describing: data), event: .event)
                    return
                }
                Logger.log(message: string, event: .event)
                guard let data = string.data(using: .utf8),
                      let notification = try? JSONDecoder().decode(Notification.Account.self, from: data)
                else {return}
                self.onNotification(notification)
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
        
        func onNotification(_ notification: Notification.Account) {
            
        }
        
        func updateSubscriptions() {
            
        }
        
        func resetSubscriptions() {
            
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
