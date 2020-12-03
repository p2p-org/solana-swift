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

public protocol SolanaSoketHttpClient: class {
    func accountSubscribe() -> Single<UInt64>
    func accountUnsubscribe() -> Single<Bool>
    func programSubscribe(pubkey: String)
    func programUnsubscribe(pubkey: String)
    func signatureSubscribe(_ signature: String, commitment: String)
    func signatureUnsubscribe(_ signature: String) -> Single<Bool>
}

extension SolanaSDK {
    public class Socket {
        let disposeBag = DisposeBag()
        weak var httpClient: SolanaSoketHttpClient?
        
        let manager: SocketManager
        public lazy var socket = manager.defaultSocket
        
        public let status = BehaviorRelay<Status>(value: .initializing)
        var wsHeartBeat: Timer!

        public init(endpoint: String, httpClient: SolanaSoketHttpClient) {
            manager = SocketManager(socketURL: URL(string: endpoint)!, config: [.log(true), .compress, .reconnectAttempts(-1)])
            
            self.httpClient = httpClient
            
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
        
        deinit {
            socket.disconnect()
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

extension SolanaSDK.Socket {
    public enum Status {
        case initializing
        case connected
        case disconnected
        case error(Error)
    }
}
