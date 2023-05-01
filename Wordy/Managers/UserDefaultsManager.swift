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
			UserDefaults().bool(forKey: "isLoggedIn")
		}
		set {
			UserDefaults().setValue(newValue, forKey: "isLoggedIn")
		}
	}
	
	static var langCodeForLearn: String? {
		get {
			UserDefaults().string(forKey: "langCodeForLearn")
		}
		set {
			UserDefaults().setValue(newValue, forKey: "langCodeForLearn")
		}
	}
}
