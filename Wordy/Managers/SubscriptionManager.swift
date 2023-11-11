//
//  SubscriptionManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 01.10.2023.
//

import Foundation
import ApphudSDK

class SubscriptionManager: ObservableObject {
	
//	lazy var userHasSubscription: Bool = {
//		Apphud.hasPremiumAccess()
//	}()
    
    func userHasSubscription() -> Bool {
        if let userId = UserDefaultsManager.userID  {
            Apphud.start(apiKey: "app_6t9G2dfKPDzUt3jifCJdTPMLbaKCPr", userID: userId)
            return Apphud.hasPremiumAccess() || UserDefaultsManager.userHasTestSubscription
        } else {
            return false
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
}
