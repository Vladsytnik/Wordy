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
	
	static var userHasTestSubscription: Bool {
		get {
			UserDefaults().bool(forKey: "userHasTestSubscription")
		}
		set {
			UserDefaults().setValue(newValue, forKey: "userHasTestSubscription")
		}
	}
	
	static var countOfStartingLearnModes: [String: Int] {
		get {
			(UserDefaults().dictionary(forKey: "countOfStartingLearnMode") as? [String: Int]) ?? [:]
		}
		set {
			UserDefaults().setValue(newValue, forKey: "countOfStartingLearnMode")
		}
	}
    
    static var countOfTranslatesInModules: [String: Int] {
        get {
            (UserDefaults().dictionary(forKey: "countOfTranslatesInModules") as? [String: Int]) ?? [:]
        }
        set {
            UserDefaults().setValue(newValue, forKey: "countOfTranslatesInModules")
        }
    }
    
    static var countOfGeneratingExamplesInModules: [String: Int] {
        get {
            (UserDefaults().dictionary(forKey: "countOfGeneratingExamplesInModules") as? [String: Int]) ?? [:]
        }
        set {
            UserDefaults().setValue(newValue, forKey: "countOfGeneratingExamplesInModules")
        }
    }
    
    static var isNewPhraseScreenLaunched: Bool {
        get {
            UserDefaults().bool(forKey: "isNewPhraseScreenLaunched")
        }
        set {
            UserDefaults().setValue(newValue, forKey: "isNewPhraseScreenLaunched")
        }
    }
    
    static var userAlreaySawAddExampleBtn: Bool {
        get {
            UserDefaults().bool(forKey: "userDidntSeeAddExampleBtn")
        }
        set {
            UserDefaults().setValue(newValue, forKey: "userDidntSeeAddExampleBtn")
        }
    }
    
    static var userAlreaySawExample: Bool {
        get {
            UserDefaults().bool(forKey: "userAlreaySawExample")
        }
        set {
            UserDefaults().setValue(newValue, forKey: "userAlreaySawExample")
        }
    }
    
    static var userAlreaySawTranslate: Bool {
        get {
            UserDefaults().bool(forKey: "userAlreaySawTranslate")
        }
        set {
            UserDefaults().setValue(newValue, forKey: "userAlreaySawTranslate")
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
	
	static var themeName: String? {
		get {
			UserDefaults().string(forKey: "themeName")
		}
		set {
			UserDefaults().setValue(newValue, forKey: "themeName")
		}
	}
	
	static var userID: String? {
		get {
			UserDefaults().string(forKey: "userID")
		}
		set {
			UserDefaults().setValue(newValue, forKey: "userID")
		}
	}
    
    static var isUserSawLearnButton: Bool {
        get {
            UserDefaults().bool(forKey: "userDidntSeeLearnBtnYet")
        }
        set {
            UserDefaults().setValue(newValue, forKey: "userDidntSeeLearnBtnYet")
        }
    }
    
    static var isUserSawCreateNewModule: Bool {
        get {
            UserDefaults().bool(forKey: "isUserSawCreateNewModule")
        }
        set {
            UserDefaults().setValue(newValue, forKey: "isUserSawCreateNewModule")
        }
    }
    
    static var isUserSawCreateNewPhrase: Bool {
        get {
            UserDefaults().bool(forKey: "isUserSawCreateNewPhrase")
        }
        set {
            UserDefaults().setValue(newValue, forKey: "isUserSawCreateNewPhrase")
        }
    }
}


