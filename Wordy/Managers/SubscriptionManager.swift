//
//  SubscriptionManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 01.10.2023.
//

import SwiftUI
import ApphudSDK

class SubscriptionManager: ObservableObject {
	
//	lazy var userHasSubscription: Bool = {
//		Apphud.hasPremiumAccess()
//	}()
    
    @Published var isUserHasSubscription = false
    var onSubscriptionUpdate: ((Bool) -> Void)?
    
    static private var lastServerSubscrUpdatedDate: Date?
    
    init() {
        isUserHasSubscription = userHasSubscription()
    }
    
    @discardableResult
    func userHasSubscription() -> Bool {
        if let userId = UserDefaultsManager.userID  {
            Apphud.start(apiKey: "app_6t9G2dfKPDzUt3jifCJdTPMLbaKCPr", userID: userId)
            let hasSubscr = Apphud.hasPremiumAccess()
            || UserDefaultsManager.userHasTestSubscription
            || userHasServerSubscription()
            withAnimation {
                isUserHasSubscription = hasSubscr
            }
            onSubscriptionUpdate?(hasSubscr)
            printSubscriptionInfo()
            updateServerSubscrDateIfNeeded()
            return hasSubscr
        } else {
            isUserHasSubscription = false
            onSubscriptionUpdate?(false)
            printSubscriptionInfo()
            return false
        }
    }
    
    private func updateServerSubscrDateIfNeeded() {
        let now = Date()
        let interval = abs(now.timeIntervalSince(SubscriptionManager.lastServerSubscrUpdatedDate ?? now))
        if SubscriptionManager.lastServerSubscrUpdatedDate == nil || interval > 60 {
            NetworkManager.updateSubscriptionInfo()
            SubscriptionManager.lastServerSubscrUpdatedDate = Date()
        }
    }
	
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
    
//    func getServerSubscr() {
//        Task {
//            do {
//                let expireSubscriptionDateFromServer = try await NetworkManager.getSubscriptionExpireDateFromServer()
//                UserDefaultsManager.serverSubscrExpireDate = expireSubscriptionDateFromServer
//            } catch (let error) {
//                print("error in SubscriptionManager -> getServerSubscr -> try await NetworkManager.getSubscriptionExpireDateFromServer(): \(error.localizedDescription)")
//            }
//        }
//    }
}
