//
//  UserDefaultsManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import Foundation

class UserDefaultsManager {
	static var isLoggedIn: Bool {
		get {
//			UserDefaults().bool(forKey: "isLoggedIn")
			false
		}
		set {
			UserDefaults().setValue(newValue, forKey: "isLoggedIn")
		}
	}
}
