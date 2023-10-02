//
//  SubscriptionManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 01.10.2023.
//

import Foundation
import ApphudSDK

class SubscriptionManager: ObservableObject {
	
	var userHasSubscription: Bool {
		Apphud.hasPremiumAccess()
	}
	
	var hasActiveSubscription: Bool {
		Apphud.hasActiveSubscription()
	}
}
