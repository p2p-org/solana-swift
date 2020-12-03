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
        // MARK: - Properties
        let disposeBag = DisposeBag()
        let socket: WebSocket
        let account: PublicKey?
        var wsHeartBeat: Timer!
        
        // MARK: - Subjects
        public let status = BehaviorRelay<Status>(value: .initializing)
        let textSubject = PublishSubject<String>()

        // MARK: - Initializer
        public init(endpoint: String, publicKey: PublicKey?) {
            var request = URLRequest(url: URL(string: endpoint)!)
            request.timeoutInterval = 5
            socket = WebSocket(request: request)
            account = publicKey
            defer {socket.delegate = self}
        }
        
        deinit {
            socket.disconnect()
            unsubscribe(method: "accountSubscribe", params: [account?.base58EncodedString])
        }
        
        // MARK: - Methods
        public func connect() {
            status.accept(.connecting)
            socket.connect()
        }
        
        func updateSubscriptions() {
            subscribe(method: "accountSubscribe", params: [account?.base58EncodedString])
        }
        
        func resetSubscriptions() {
            // TODO: - resetSubscriptions
        }
        
        // MARK: - Handlers
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
        
        // MARK: - Writting
        public func subscribe(method: String, params: [Encodable]) {
            let requestAPI = RequestAPI(
                method: method,
                params: params + [["encoding":"jsonParsed"]]
            )
            write(requestAPI: requestAPI)
        }
        
        public func unsubscribe(method: String, params: [Encodable]) {
            let requestAPI = RequestAPI(
                method: method,
                params: params
            )
            write(requestAPI: requestAPI)
        }
        
        public func observe<T: Decodable>(method: String, params: [Encodable], decodedTo: T.Type) -> Observable<T> {
            let requestAPI = RequestAPI(
                method: method,
                params: params
            )
            write(requestAPI: requestAPI)
            return textSubject
                .filter { string in
                    guard let jsonData = string.data(using: .utf8),
                        let json = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: Any]
                        else {
                            return false
                    }
                    return (json["method"] as? String) == method
                }
                .map { string in
                    guard let data = string.data(using: .utf8) else {
                        throw Error.other("The response is not valid")
                    }
                    guard let result = try JSONDecoder().decode(Response<T>.self, from: data).result
                    else {
                        throw Error.other("The response is empty")
                    }
                    return result
                }
        }
        
        // MARK: - Helpers
        private func write(requestAPI: RequestAPI, completion: (() -> ())? = nil) {
            // closure for writing
            let writeAndLog: () -> Void = { [weak self] in
                do {
                    let data = try JSONEncoder().encode(requestAPI)
                    guard let string = String(data: data, encoding: .utf8) else {
                        throw Error.other("Request is invalid \(requestAPI)")
                    }
                    self?.socket.write(string: string, completion: {
                        Logger.log(message: "\(requestAPI.method) success", event: .event)
                        completion?()
                    })
                } catch {
                    Logger.log(message: "\(requestAPI.method) failed: \(error)", event: .event)
                }
            }
            
            // auto reconnect
            if status.value != .connected {
                socket.connect()
                status.filter {$0 == .connected}
                    .take(1).asSingle()
                    .subscribe(onSuccess: { _ in
                        writeAndLog()
                    })
                    .disposed(by: disposeBag)
            } else {
                writeAndLog()
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
            textSubject.onNext(string)
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
    public enum Status: Equatable {
        case initializing
        case connecting
        case connected
        case disconnected
        case error(Error)
        
        public static func == (rhs: Self, lhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.initializing, .initializing), (.connected, .connected), (.disconnected, .disconnected):
                return true
            case (.error(let err1), .error(let err2)):
                return err1.localizedDescription == err2.localizedDescription
            default:
                return false
            }
        }
    }
}
