//
//  SubscriptionManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 01.10.2023.
//

import SwiftUI
import ApphudSDK

class SubscriptionManager: ObservableObject {
    
    static let shared = SubscriptionManager()
    @Published var isUserHasSubscription = false
    
    var onSubscriptionUpdate: ((Bool) -> Void)?
    
    static private var lastServerSubscrUpdatedDate: Date?
    private var cachedSubscriptionDate: Date? = nil
    
    private init() {
        print("Subscription Manager debug: init")
        forceUpdateSubscriptionInfo()
    }
    
    func updateDate() {
        if let date = expiredAt() {
            KeychainHelper.standard.save(date, service: .KeychainServiceSubscriptionDateKey, account: .KeychainAccountKey)
            NetworkManager.updateSubscriptionInfo(withDate: date)
        }
    }
    
    func forceUpdateSubscriptionInfo() {
        checkCachedSubscriptionDate()
        updateSubscriptionDateFromServer()
    }
    
    private func checkCachedSubscriptionDate() {
        if let expireSubscrDate = KeychainHelper.standard.read(service: .KeychainServiceSubscriptionDateKey, account: .KeychainAccountKey, type: Date.self) {
            isUserHasSubscription = Date() < expireSubscrDate
        } else {
            isUserHasSubscription = false
        }
    }
    
    private func updateSubscriptionDateFromServer() {
        if let userId = UserDefaultsManager.userID  {
            Apphud.start(apiKey: ApiKeys.AppHudKey.value(), userID: userId)
            let hasSubscr = Apphud.hasPremiumAccess()
            || UserDefaultsManager.userHasTestSubscription
            || userHasServerSubscription()
            withAnimation {
                isUserHasSubscription = hasSubscr
            }
            onSubscriptionUpdate?(hasSubscr)
            printSubscriptionInfo()
            // updateServerSubscrDateIfNeeded()
        } else {
            isUserHasSubscription = false
            onSubscriptionUpdate?(false)
            printSubscriptionInfo()
        }
    }
    
//    private func updateServerSubscrDateIfNeeded() {
//        let now = Date()
//        let interval = abs(now.timeIntervalSince(SubscriptionManager.lastServerSubscrUpdatedDate ?? now))
//        if SubscriptionManager.lastServerSubscrUpdatedDate == nil || interval > 60 {
//            NetworkManager.updateSubscriptionInfo()
//            SubscriptionManager.lastServerSubscrUpdatedDate = Date()
//        }
//    }
	
    func printSubscriptionInfo() {
        let subscriptionObject = Apphud.subscription()
        if let subscriptionObject {
            print("Apphud: subscription expired at: \(subscriptionObject.expiresDate)")
        } else {
            print("Apphud: subscription object is empty")
        }
    }
    
    func expiredAt() -> Date? {
        let subscriptionObject = Apphud.subscription()
        return subscriptionObject?.expiresDate
    }
    
    func userHasServerSubscription() -> Bool {
        let currentDate = Date()
        let serverDate = UserDefaultsManager.serverSubscrExpireDate ?? currentDate
        let subscrIsActive = currentDate < serverDate
        return subscrIsActive
    }
}
