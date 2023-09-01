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
	
	static var userHasSubscription: Bool {
		get {
			UserDefaults().bool(forKey: "userHasSubscription")
		}
		set {
			UserDefaults().setValue(newValue, forKey: "userHasSubscription")
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
	
	static var isAlreadyLaunched: Bool {
		get {
			UserDefaults().bool(forKey: "isFirstLaunch")
		}
		set {
			UserDefaults().setValue(newValue, forKey: "isFirstLaunch")
		}
	}
	
	static var nativeLanguage: Language? {
		get {
			do {
				if let data = UserDefaults.standard.data(forKey: "nativeLanguage") {
					let user = try JSONDecoder().decode(Language.self, from: data)
					return user
				}
			} catch let error {
				print("Error decoding user model in UserDefaults: \(error)")
			}
			return nil
		} set {
			do {
				let data = try JSONEncoder().encode(newValue)
				UserDefaults().set(data, forKey: "nativeLanguage")
			} catch let error  {
				print("Error encoding user model in UserDefaults: \(error)")
			}
		}
	}
	
	static var learnLanguage: Language? {
		get {
			do {
				if let data = UserDefaults.standard.data(forKey: "learnLanguage") {
					let user = try JSONDecoder().decode(Language.self, from: data)
					return user
				}
			} catch let error {
				print("Error decoding user model in UserDefaults: \(error)")
			}
			return nil
		} set {
			do {
				let data = try JSONEncoder().encode(newValue)
				UserDefaults().set(data, forKey: "learnLanguage")
			} catch let error  {
				print("Error encoding user model in UserDefaults: \(error)")
			}
		}
	}
	
	static var isNotFirstLaunchOfModulesPage: Bool {
		get {
			UserDefaults().bool(forKey: "isFirstLaunchOfModulesPage")
		}
		set {
			UserDefaults().setValue(newValue, forKey: "isFirstLaunchOfModulesPage")
		}
	}
}


