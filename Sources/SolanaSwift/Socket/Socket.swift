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
        private let disposeBag = DisposeBag()
        let socket: WebSocket
        var wsHeartBeat: Timer!
        
        // MARK: - Subscriptions
        private var subscribers = [Subscriber]()
        private var accountSubscriptions = [Subscription]()
        
        // MARK: - Subjects
        let status = BehaviorRelay<Status>(value: .initializing)
        let dataSubject = PublishSubject<Data>()
        var socketDidConnect: Completable {
            status.filter{$0 == .connected}.take(1).asSingle().asCompletable()
        }

        // MARK: - Initializer
        public init(endpoint: String) {
            var request = URLRequest(url: URL(string: endpoint)!)
            request.timeoutInterval = 5
            if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
                socket = WebSocket(request: request, engine: NativeEngine())
            } else {
                socket = WebSocket(request: request)
            }
            defer {socket.delegate = self}
        }
        
        deinit {
            disconnect()
        }
        
        // MARK: - Socket actions
        /// Connect to Solana's websocket
        public func connect() {
            // connecting
            status.accept(.connecting)
            
            // connect
            socket.connect()
        }
        
        /// Disconnect from Solana's websocket
        public func disconnect() {
            unsubscribeToAllSubscriptions()
            status.accept(.disconnected)
            socket.disconnect()
        }
        
        public var isConnected: Bool {
            status.value == .connected
        }
        
        // MARK: - Account notifications
        public func subscribeAccountNotification(account: String, isNative: Bool) {
            let subscriber = Subscriber(pubkey: account, isNative: isNative)
            
            // check if subscriptions exists
            guard !accountSubscriptions.contains(where: {$0.account == subscriber.pubkey })
            else {
                // already registered
                return
            }
            
            // if account was not registered, add account to self.accounts
            if !subscribers.contains(subscriber) {
                subscribers.append(subscriber)
            }
            
            // add subscriptions
            let id = write(
                method: .init(.account, .subscribe),
                params: [
                    subscriber.pubkey,
                    ["encoding":"jsonParsed", "commitment": "recent"]
                ]
            )
            subscribe(id: id)
                .subscribe(onSuccess: {[weak self] subscriptionId in
                    guard let strongSelf = self else {return}
                    if strongSelf.accountSubscriptions.contains(where: {$0.account == subscriber.pubkey})
                    {
                        strongSelf.accountSubscriptions.removeAll(where: {$0.account == subscriber.pubkey})
                    }
                    strongSelf.accountSubscriptions.append(.init(entity: .account, id: subscriptionId, account: subscriber.pubkey))
                })
                .disposed(by: disposeBag)
        }
        
        public func observeAccountNotifications() -> Observable<(pubkey: String, lamports: Lamports)>
        {
            observeNotification(.account)
                .flatMap { [weak self] data -> Observable<(pubkey: String, lamports: Lamports)> in
                    guard let self = self else {throw SolanaSDK.Error.unknown}
                    return self.decodeDataToAccountNotification(data: data)
                }
        }
        
        // MARK: - Signature notifications
        public func observeSignatureNotification(signature: String) -> Completable
        {
            let id = write(
                method: .init(.signature, .subscribe),
                params: [signature, ["commitment": "confirmed"]]
            )
            
            return subscribe(id: id)
                .flatMapCompletable {[weak self] subscription in
                    self?.dataSubject
                        .filter {data in
                            guard let response = try? JSONDecoder().decode(Response<SignatureNotification>.self, from: data),
                                  response.method == "signatureNotification",
                                  response.params?.subscription == subscription
                            else {
                                return false
                            }
                            return true
                        }
                        .take(1)
                        .asSingle()
                        .asCompletable()
                    ?? .empty()
                }
                
        }
        
        @discardableResult
        public func write(method: Method, params: [Encodable]) -> String {
            let requestAPI = RequestAPI(
                method: method.rawValue,
                params: params
            )
            write(requestAPI: requestAPI)
            return requestAPI.id
        }
        
        // MARK: - Helpers
        /// Subscribe to accountNotification from all accounts in the queue
        func subscribeToAllAccounts() {
            subscribers.forEach {subscribeAccountNotification(account: $0.pubkey, isNative: $0.isNative)}
        }
        
        /// Unsubscribe to all current subscriptions
        func unsubscribeToAllSubscriptions() {
            for subscription in accountSubscriptions {
                write(method: .init(subscription.entity, .unsubscribe), params: [subscription.id])
            }
            accountSubscriptions = []
        }
        
        private func subscribe(id: String) -> Single<UInt64> {
            dataSubject
                .filter { data in
                    guard let json = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)) as? [String: Any]
                        else {
                            return false
                    }
                    return (json["id"] as? String) == id
                }
                .map { data in
                    guard let subscription = try JSONDecoder().decode(Response<UInt64>.self, from: data).result
                    else {
                        throw Error.other("Subscription is not valid")
                    }
                    return subscription
                }
                .take(1)
                .asSingle()
        }
        
        private func observeNotification(_ entity: Entity, subscription: UInt64? = nil) -> Observable<Data>
        {
            dataSubject
                .filter { data in
                    guard let json = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)) as? [String: Any]
                        else {
                            return false
                    }
                    return (json["method"] as? String) == entity.notificationMethodName
                }
        }
        
        private func write(requestAPI: RequestAPI, completion: (() -> ())? = nil) {
            // closure for writing
            let writeAndLog: () -> Void = { [weak self] in
                do {
                    let data = try JSONEncoder().encode(requestAPI)
                    guard let string = String(data: data, encoding: .utf8) else {
                        throw Error.other("Request is invalid \(requestAPI)")
                    }
                    Logger.log(message: string, event: .request)
                    self?.socket.write(string: string, completion: {
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
        
        func decodeDataToAccountNotification(data: Data) -> Observable<(pubkey: String, lamports: Lamports)>
        {
            let decoder = JSONDecoder()
            
            var account: String?
            var lamports: SolanaSDK.Lamports?
            
            if let result = try? decoder
                .decode(NativeAccountNotification.self, from: data),
               let subscription = accountSubscriptions.first(where: {$0.id == result.params?.subscription}),
               let subscriber = subscribers.first(where: {$0.pubkey == subscription.account}),
               subscriber.isNative
            {
                account = accountSubscriptions.first(where: {$0.id == result.params?.subscription})?.account
                lamports = result.params?.result?.value.lamports
            } else if let result = try? decoder
                .decode(TokenAccountNotification.self, from: data),
                      let subscription = accountSubscriptions.first(where: {$0.id == result.params?.subscription}),
                      let subscriber = subscribers.first(where: {$0.pubkey == subscription.account}),
                      !subscriber.isNative
            {
                account = accountSubscriptions.first(where: {$0.id == result.params?.subscription})?.account
                let string = result.params?.result?.value.data.parsed.info.tokenAmount.amount ?? "0"
                lamports = Lamports(string)
            }
            
            if let pubkey = account,
               let lamports = lamports
            {
                return .just((pubkey: pubkey, lamports: lamports))
            }
            
            return .empty()
        }
    }
}
