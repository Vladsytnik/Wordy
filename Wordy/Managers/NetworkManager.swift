//
//  NetworkManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 15.12.2022.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseDatabase


enum NetworkError: Error {
//	case signIn(text: ErrorText)
//	
//	enum ErrorText: String {
//		case unownError = "К сожалению, при авторизации что-то пошло не так"
//	}
    
    case turnedOff(String)
}

protocol NetworkDelegate: AnyObject {
    func networkError(_ error: NetworkError)
}

class NetworkManager {
	
	static var ref = Database.database(url: "https://wordy-a720d-default-rtdb.europe-west1.firebasedatabase.app/").reference()
//	static let db = Firestore.firestore()
	static var currentUserID: String? { Auth.auth().currentUser?.uid }
    static weak var networkDelegate: NetworkDelegate?
    
    static private let dataManager = DataManager.shared
    
    // MARK: - Support
    
    static func sendSupportRequest(withData data: [String: String]) async throws {
        guard let currentUserID = currentUserID else {
            print("error in updateNotificationsInfo -> currentUserID")
            return
        }
        
        if NetworkConnectionManager.shared.isConnectedToNetwork() {
            print("Internet connection test: интернет есть")
        } else {
            print("Internet connection test: интернета нет")
            networkDelegate?.networkError(.turnedOff("\nУпс, отсутствует подключение к интернету..."))
            return
        }
        
        var newData = data
        newData["user_id"] = currentUserID
        
        var isTest = false
        
        #if DEBUG
            isTest = true
        #endif
        
        let jsonData = try JSONEncoder().encode(newData)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            // Отправляем JSON в Firebase
            if isTest {
                let _ = try await ref.child("support_request_test").childByAutoId().updateChildValues(["data": newData])
            } else {
                let _ = try await ref.child("support_request").childByAutoId().updateChildValues(["data": newData])
            }
        } else {
            print("error in sendSupportRequest -> jsonString")
        }
        
    }
	
    
    // MARK: - Subscription
    
    static func updateSubscriptionInfo(withDate date: Date, isTestPro: Bool = false) {
        guard let currentUserID = currentUserID else {
            print("error in updateSubscriptionInfo -> currentUserID")
            return
        }
        
        Task {
            var dateStr = ""
            
            let dateFormatter = DateFormatter().getDateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateStr = dateFormatter.string(from: date)
            
            if isTestPro {
                if let futureDate = Calendar.current.date(byAdding: .year, value: 10, to: Date()) {
                    let dateFormatter = DateFormatter().getDateFormatter()
                    dateFormatter.timeZone = TimeZone(identifier: "UTC")
                    dateStr = dateFormatter.string(from: futureDate)
                }
            }
            
            if dateStr.count > 0 {
                let _ = try await ref.child("users").child(currentUserID).updateChildValues(["subscriptionExpireDate": dateStr])
            }
        }
    }
    
    static func getSubscriptionExpireDateFromServer() async throws -> Date? {
        guard let currentUserID = currentUserID else {
            print("error in sendToken -> currentUserID")
            return nil
        }
        
        let snapshot = try await ref.child("users").child(currentUserID).child("subscriptionExpireDate").getData()
        if let jsonString = snapshot.value as? String,
            let data = jsonString.data(using: .utf8)
        {
            do {
                guard let expireDate = String(data: data, encoding: .utf8) else { return nil }
                let df = DateFormatter().getDateFormatter()
                df.timeZone = TimeZone(identifier: "UTC")
                let date = df.date(from: expireDate)
                return date
            } catch(let error) {
                print("error in getSubscriptionExpireDateFromServer -> currentUserID: \(error)")
            }
        } else {
            print("error in getSubscriptionExpireDateFromServer -> snapshot.value is not exist or not is needed type")
        }
        
        return nil
    }
    
    // MARK: - Notifications
    
    enum NotificationsError: Error {
        case resetAllNotificationsUrl
        case responseCode
        case userId
    }
    
    // переименовать в updateNotification
    static func updateModulesNotificationState(with notification: Notification) async throws {
        guard let currentUserID = currentUserID else {
            print("error in resetAllNotifications -> currentUserID")
            throw NotificationsError.userId
        }
        
        let session = URLSession.shared
        
        guard let url = URL(string: "https://functions.yandexcloud.net/d4ebkcngmtrh7cr3b3nr") else {
            print("error in url [resetAllNotifications method]")
            throw NotificationsError.resetAllNotificationsUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST";
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/json"
        ]
        
        let moduleIds = notification.selectedModulesIds
        
        let body = [
            "userId" : currentUserID,
            "moduleIds" : moduleIds
        ] as [String : Any]
        
        let httpBody = try JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        request.httpBody = httpBody
        let (data, response) = try await session.data(for: request)
        
        print(response)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("NetworkManager -> createExamples status code is not 200: \(response)")
            throw NotificationsError.responseCode
        }
    }
    
    static func updateNotificationsInfo(notification: Notification) async throws {
        guard let currentUserID = currentUserID else {
            print("error in updateNotificationsInfo -> currentUserID")
            return
        }
        
        if NetworkConnectionManager.shared.isConnectedToNetwork() {
            print("Internet connection test: интернет есть")
        } else {
            print("Internet connection test: интернета нет")
            networkDelegate?.networkError(.turnedOff("\nУпс, отсутствует подключение к интернету..."))
            return
        }
        
        let jsonData = try JSONEncoder().encode(notification)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            // Отправляем JSON в Firebase
            let _ = try await ref.child("users").child(currentUserID).updateChildValues(["notifications": jsonString])
            try await updateModulesNotificationState(with: notification)
            DataManager.shared.updateModulesStates(from: notification)
        } else {
            print("error in updateNotificationsInfo -> jsonString")
        }
        
    }
    
    static func getNotificationsInfo() async throws -> Notification? {
        guard let currentUserID = currentUserID else {
            print("error in sendToken -> currentUserID")
            return nil
        }
        
        // Отправляем JSON в Firebase
        let snapshot = try await ref.child("users").child(currentUserID).child("notifications").getData()
        if let jsonString = snapshot.value as? String, 
            let data = jsonString.data(using: .utf8)
        {
            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed])
                let notification = try JSONDecoder().decode(Notification.self, from: data)
                return notification
            } catch {
                print("error in getNotificationsInfo -> currentUserID: \(error)")
            }
        } else {
            print("error in getNotificationsInfo -> snapshot.value is not exist or not is needed type")
        }
        
        return nil
    }
	
    // Device token for notifications
    static func sendToken(_ token: String) async {
        guard let currentUserID = currentUserID else {
            print("error in sendToken -> currentUserID")
            return
        }
        
        ref.child("users").child(currentUserID).updateChildValues(["token": token]) { error, ref in
            guard error == nil else {
                print("error in sendToken -> updateChildValues: \(error)")
                return
            }
            
            print("sendToken -> success")
        }
	}
    
    // MARK: - Authorization
	
	static func signIn(email: String, password: String, 
                       success: @escaping (String) -> Void,
                       errorBlock: @escaping (String) -> Void) {
		Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
			checkAnswer(
				authResult: authResult,
				error: error,
				success: success,
				errorBlock: errorBlock
			)
		}
	}
	
	static func checkAnswer(authResult: AuthDataResult?, 
                            error: Error?, 
                            success: @escaping (String) -> Void,
                            errorBlock: @escaping (String) -> Void ) {
		guard error == nil else {
			print("Network error:", error.debugDescription)
			if error.debugDescription.decodeCode() == -1 {
				errorBlock("К сожалению, при авторизации что-то пошло не так")
			} else {
				errorBlock("При авторизации произошла ошибка: " + error.debugDescription.decodeDescription())
			}
			return
		}
		
		switch authResult {
		case .none:
			errorBlock(authResult?.debugDescription ?? "nil2")
			break
		case .some(_):
			success("success")
			break
		}
	}
    
    static func register(email: String, password: String, success: @escaping (String) -> Void, errorBlock: @escaping (String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            checkAnswer(
                authResult: authResult,
                error: error,
                success: success,
                errorBlock: errorBlock
            )
        }
    }
    
    // MARK: - Modules
    
    static func deleteModules(_ modules: [Module]) async throws {
        
        enum Err: Error {
            case CurrentUserId
        }
        
        guard let currentUserID = currentUserID else {
            print("error in updateNotificationsInfo -> currentUserID")
            throw Err.CurrentUserId
        }
        
        let modulesIds = modules.map { $0.id }
        
        for moduleId in modulesIds {
            print("async await debug: перед удалением")
            try await ref.child("users").child(currentUserID).child("modules").child(moduleId).removeValue()
            print("async await debug: дождались удаления")
        }
    }
    
    static func updateModuleWith(id: String, emoji: String, name: String) async throws -> Bool {
        guard let currentUserID = currentUserID else {
            print("error in updateNotificationsInfo -> currentUserID")
            return false
        }
        
        if NetworkConnectionManager.shared.isConnectedToNetwork() {
            print("Internet connection test: интернет есть")
        } else {
            print("Internet connection test: интернета нет")
            networkDelegate?.networkError(.turnedOff("\nУпс, отсутствует подключение к интернету..."))
            return false
        }
        
        let _ = try await ref.child("users").child(currentUserID).child("modules").child(id).child("emoji").setValue(emoji)
        let ref = try await ref.child("users").child(currentUserID).child("modules").child(id).child("name").setValue(name)
        
        if let moduleId = findModuleIdFromRef(ref) {
            // это чтобы преобразовать closures в async await
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<Bool, Error>) in
                getModule(with: moduleId, fromUser: currentUserID) { changedModule in
                    dataManager.replaceModule(changedModule)
                    continuation.resume(returning: true)
                } errorBlock: { errorText in
                    let error = NSError(domain: errorText, code: -1)
                    continuation.resume(throwing: error)
                }
            })
        } else {
            return false
        }
    
    }
    
    static private func findModuleIdFromRef(_ ref: DatabaseReference) -> String? {
        let url = URL(string: ref.url)
        let components = url?.pathComponents
        guard let components else { return nil }
        
        for (i, component) in components.enumerated() {
            if component == "modules" 
                && (i + 1) < components.count {
                return components[i + 1]
            }
        }
        
        return nil
    }
    
    static func setTeacherModeToModule(id: String) async throws -> Bool {
        guard let currentUserID = currentUserID else {
            print("error in updateNotificationsInfo -> currentUserID")
            return false
        }
        
        if NetworkConnectionManager.shared.isConnectedToNetwork() {
            print("Internet connection test: интернет есть")
        } else {
            print("Internet connection test: интернета нет")
            networkDelegate?.networkError(.turnedOff("\nУпс, отсутствует подключение к интернету..."))
            return false
        }
        
        let _ = try await ref.child("users").child(currentUserID).child("modules").child(id).child("isSharedByTeacher").setValue(true)
    
        return true
    }
    
    static func setNotificationToModule(id: String, isTurnedOn: Bool) async throws -> Bool {
        guard let currentUserID = currentUserID else {
            print("error in updateNotificationsInfo -> currentUserID")
            return false
        }
        
        if NetworkConnectionManager.shared.isConnectedToNetwork() {
            print("Internet connection test: интернет есть")
        } else {
            print("Internet connection test: интернета нет")
            networkDelegate?.networkError(.turnedOff("\nУпс, отсутствует подключение к интернету..."))
            return false
        }
        
        let _ = try await ref.child("users").child(currentUserID).child("modules").child(id).child("isNotificationTurnedOn").setValue(isTurnedOn)
    
        return true
    }
	
	static func createModule(name: String,
                             emoji: String,
                             phrases: [Phrase]? = nil,
                             acceptedAsStudent: Bool = false,
                             isBlockedFreeFeatures: Bool = false,
                             success: @escaping (Module) -> Void,
                             errorBlock: @escaping (String) -> Void ) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in createModule -> currentUserID")
			return
		}
		
		let date = String().generateCurrentDateMarker()
		
		var phrasesDict: [String: [String: String]] = [:]
		if let phrases {
            for (i, phrase) in phrases.enumerated() {
				let newPhrase = [
					Constants.nativeText: phrase.nativeText,
					Constants.translatedText: phrase.translatedText,
					Constants.date: String().generateCurrentDateMarker(withSecondOffset: i)
				]
				let url = URL(string: ref.childByAutoId().url)
				if let lastPathComp = url?.lastPathComponent {
					phrasesDict[lastPathComp] = newPhrase
				}
			}
		}

		ref.child("users").child(currentUserID).child("modules").childByAutoId().updateChildValues([
            "name" : name,
            "emoji" : emoji,
            "acceptedAsStudent" : acceptedAsStudent,
            "date": date,
            "phrases": phrasesDict
        ]) { error, ref in
			guard error == nil else {
				errorBlock("error in createModule -> updateChildValues")
				return
			}
			
            let moduleId = findModuleIdFromRef(ref)
            
            if let moduleId {
                NetworkManager.getModule(with: moduleId, fromUser: currentUserID) { module in
                    success(module)
                } errorBlock: { errorText in
                    errorBlock(errorText)
                }

            } else {
                errorBlock("error in createModule -> moduleId")
            }
//
//			success("success")
		}
	}
	
	static func getModules(success: @escaping ([Module]) -> Void, errorBlock: @escaping (String) -> Void) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in getModules -> currentUserID")
			return
		}
		
		let queue = DispatchQueue(label: "sytnik.wordy.getModules")
		queue.async {
			ref.child("users").child(currentUserID).child("modules").getData { error, snap in
				if let error = error {
					DispatchQueue.main.async {
						errorBlock("error in getModules -> getData { error, snap in }" + error.localizedDescription)
//						errorBlock("")
					}
					return
				}
				
				if let snapshot = snap {
					guard let modules = Module.parse(from: snapshot) else {
						DispatchQueue.main.async {
							errorBlock("error in getModules -> parse module")
						}
						return
					}
					
					DispatchQueue.main.async {
						success(modules.sorted(by: { $0.date ?? Date() > $1.date ?? Date() }))
					}
				}
			}
		}
	}
	
	static func getModule(with moduleID: String, fromUser userID: String, success: @escaping (Module) -> Void, errorBlock: @escaping (String) -> Void) {
		let currentUserID = userID
		
		let queue = DispatchQueue(label: "sytnik.wordy.getModules")
		queue.async {
			ref.child("users").child(currentUserID).child("modules").child(moduleID).getData { error, snap in
				if let error = error {
					DispatchQueue.main.async {
						errorBlock("error in getModule(with moduleID.. -> getData { error, snap in }" + error.localizedDescription)
						//						errorBlock("")
					}
					return
				}
				
				if let snapshot = snap {
					guard let module = Module.parseSingle(from: snapshot, moduleID: moduleID) else {
						DispatchQueue.main.async {
							errorBlock("error in getModule(with moduleID.. -> parse module")
						}
						return
					}
					
					DispatchQueue.main.async {
						success(module)
					}
				}
			}
		}
	}
	
	static func deleteModule(with moduleID: String, success: @escaping () -> Void, errorBlock: @escaping (String) -> Void) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in getModules -> currentUserID")
			return
		}
		
		let queue = DispatchQueue(label: "sytnik.wordy.deleteModule")
		queue.async {
			ref.child("users").child(currentUserID).child("modules").child(moduleID).removeValue { error, ref in
				if let error = error {
					DispatchQueue.main.async {
						errorBlock("error in deleteModule -> getData { error, snap in }" + error.localizedDescription)
						//						errorBlock("")
					}
					return
				}
                
                dataManager.deleteModule(withId: moduleID)
                success()
            }
		}
	}
    
    // MARK: - Phrases
    
    static func deletePhrase(with phraseIndex: String, moduleID: String, success: @escaping () -> Void, errorBlock: @escaping (String) -> Void) {
        guard let currentUserID = currentUserID else {
            errorBlock("error in getModules -> currentUserID")
            return
        }
        
        let queue = DispatchQueue(label: "sytnik.wordy.deletePhrase")
        queue.async {
            ref.child("users").child(currentUserID).child("modules").child(moduleID).child("phrases").child(phraseIndex).removeValue { error, snap in
                if let error = error {
                    DispatchQueue.main.async {
                        errorBlock("error in deleteModule -> getData { error, snap in }" + error.localizedDescription)
                        //                        errorBlock("")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    dataManager.deletePhrase(withId: phraseIndex, inModuleWithId: moduleID)
                    success()
                }
            }
        }
    }
	
	static func update(phrases: [[String: Any]], from moduleID: String, success: @escaping () -> Void, errorBlock: @escaping (String) -> Void) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in add(phrase: [String: String] -> currentUserID")
			return
		}
		
		ref.child("users").child(currentUserID).child("modules").child(moduleID).updateChildValues(["phrases" : phrases]) { error, ref in
			guard error == nil else {
				errorBlock("error in add(phrase: [String: String] -> updateChildValues")
				return
			}
            
            let moduleId = findModuleIdFromRef(ref)
            let phraseId = findPhraseIdFromRef(ref)
            
            if let moduleId {
                getModule(with: moduleId, fromUser: currentUserID) { module in
                    dataManager.replaceModule(module)
                    success()
                    return
                } errorBlock: { errorText in
                    errorBlock("error in addNewPhrase(phrase: [String: String] -> getModule \(errorText)")
                    return
                }
            }
			
			success()
		}
	}
	
	static func addNewPhrase(_ phrase: [String: Any], to moduleID: String, success: @escaping () -> Void, errorBlock: @escaping (String) -> Void) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in add(phrase: [String: String] -> currentUserID")
			return
		}
		
		ref.child("users").child(currentUserID).child("modules").child(moduleID).child("phrases").childByAutoId().updateChildValues([
			"date" : phrase[Constants.date],
			"example" : phrase[Constants.example],
			"nativePhrase": phrase[Constants.nativeText],
			"translatedPhrase": phrase[Constants.translatedText]
		]) { error, ref in
			guard error == nil else {
				errorBlock("error in add(phrase: [String: String] -> updateChildValues")
				return
			}
            
            let moduleId = findModuleIdFromRef(ref)
            let phraseId = findPhraseIdFromRef(ref)
            
            if let moduleId {
                getModule(with: moduleId, fromUser: currentUserID) { module in
                    dataManager.replaceModule(module)
                    success()
                    return
                } errorBlock: { errorText in
                    errorBlock("error in addNewPhrase(phrase: [String: String] -> getModule \(errorText)")
                    return
                }
            }
		}
	}
    
    static private func findPhraseIdFromRef(_ ref: DatabaseReference) -> String? {
        let url = URL(string: ref.url)
        let components = url?.pathComponents
        guard let components else { return nil }
        
        for (i, component) in components.enumerated() {
            if component == "phrases"
                && (i + 1) < components.count {
                return components[i + 1]
            }
        }
        
        return nil
    }
    
    static private func findGroupIdFromRef(_ ref: DatabaseReference) -> String? {
        let url = URL(string: ref.url)
        let components = url?.pathComponents
        guard let components else { return nil }
        
        for (i, component) in components.enumerated() {
            if component == "groups"
                && (i + 1) < components.count {
                return components[i + 1]
            }
        }
        
        return nil
    }
	
	static func updatePhrase(_ phrase: [String: Any], with phraseIndex: String, from moduleID: String, success: @escaping () -> Void, errorBlock: @escaping (String) -> Void) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in add(phrase: [String: String] -> currentUserID")
			return
		}
		
		ref.child("users").child(currentUserID).child("modules").child(moduleID).child("phrases").child(phraseIndex).updateChildValues(phrase) { error, ref in
			guard error == nil else {
				errorBlock("error in updatePhrase(_ phrase: [String: Any] -> updateChildValues")
				return
			}
			
            let moduleId = findModuleIdFromRef(ref)
            let phraseId = findPhraseIdFromRef(ref)
            
            if let moduleId {
                getModule(with: moduleId, fromUser: currentUserID) { module in
                    dataManager.replaceModule(module)
                    success()
                    return
                } errorBlock: { errorText in
                    errorBlock("error in addNewPhrase(phrase: [String: String] -> getModule \(errorText)")
                    return
                }
            }
		}
	}
    
    // MARK: - Groups

	static func createGroup(name: String, modules: [Module]? = nil, success: @escaping (String) -> Void, errorBlock: @escaping (String) -> Void ) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in createGroup -> currentUserID")
			return
		}
		
		let date = String().generateCurrentDateMarker()
		
		if let modules = modules, modules.count > 0 {
			let modulesID = modules.map{ $0.id }
			ref.child("users").child(currentUserID).child("groups").childByAutoId().updateChildValues(["name": name, "date": date, "modulesID": modulesID]) { error, ref in
				guard error == nil else {
					errorBlock("error in createGroup -> updateChildValues")
					return
				}
				
                let df = DateFormatter().getDateFormatter()
                let strDateToDate = df.date(from: date)
                let groupId = findGroupIdFromRef(ref)
                if let groupId {
                    let newGroup = Group(name: name, id: groupId, modulesID: modulesID, date: strDateToDate)
                    dataManager.replaceGroup(with: newGroup, withNilDate: true)
                    success("success")
                } else {
                    errorBlock("error in createGroup -> groupId")
                }
			}
		} else {
			ref.child("users").child(currentUserID).child("groups").childByAutoId().updateChildValues(["name": name, "date": date]) { error, ref in
				guard error == nil else {
					errorBlock("error in createGroup -> updateChildValues")
					return
				}
				
                let df = DateFormatter().getDateFormatter()
                let strDateToDate = df.date(from: date)
                let groupId = findGroupIdFromRef(ref)
                if let groupId {
                    let newGroup = Group(name: name, id: groupId, modulesID: [], date: strDateToDate)
                    dataManager.replaceGroup(with: newGroup, withNilDate: true)
                    success("success")
                } else {
                    errorBlock("error in createGroup -> groupId")
                }
			}
		}
	}
	
	static func getGroups(success: @escaping ([Group]) -> Void, errorBlock: @escaping (String) -> Void) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in getGroups -> currentUserID")
			return
		}
		
		let queue = DispatchQueue(label: "sytnik.wordy.getModules")
		queue.async {
			ref.child("users").child(currentUserID).child("groups").getData { error, snap in
				if let error = error {
					DispatchQueue.main.async {
						errorBlock("error in getGroups -> getData { error, snap in }" + error.localizedDescription)
						//						errorBlock("")
					}
					return
				}
				
				if let snapshot = snap {
					guard let groups = Group.parse(from: snapshot) else {
						DispatchQueue.main.async {
							errorBlock("error in getGroups -> parse groups")
						}
						return
					}
					
					DispatchQueue.main.async {
						success(groups.sorted(by: { $0.date ?? Date() > $1.date ?? Date() }))
					}
				}
			}
		}
	}
	
    // TODO: поправить
	static func changeGroup(_ group: Group, modules: [Module]? = nil, success: @escaping (String) -> Void, errorBlock: @escaping (String) -> Void ) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in createGroup -> currentUserID")
			return
		}
		
		let date = String().generateCurrentDateMarker()
		
		if let modules = modules, modules.count > 0 {
			let modulesID = modules.map{ $0.id }
			ref.child("users").child(currentUserID).child("groups").child(group.id).updateChildValues(["name": group.name, "modulesID": modulesID]) { error, ref in
				guard error == nil else {
					errorBlock("error in createGroup -> updateChildValues")
					return
				}
				
                var changedGroup = group
                changedGroup.modulesID = modulesID
                dataManager.replaceGroup(with: changedGroup)
                
				success("success")
			}
		} else {
			ref.child("users").child(currentUserID).child("groups").child(group.id).updateChildValues(["name": group.name, "modulesID": []]) { error, ref in
				guard error == nil else {
					errorBlock("error in createGroup -> updateChildValues")
					return
				}
				
                var changedGroup = group
                changedGroup.modulesID = []
                dataManager.replaceGroup(with: changedGroup)
                
				success("success")
			}
		}
	}
    
    static func deleteGroup(with groupIndex: String, withoutUpdate: Bool = false, success: @escaping () -> Void, errorBlock: @escaping (String) -> Void) {
        guard let currentUserID = currentUserID else {
            errorBlock("error in getModules -> currentUserID")
            return
        }
        
        let queue = DispatchQueue(label: "sytnik.wordy.deletePhrase")
        queue.async {
            ref.child("users").child(currentUserID).child("groups").child(groupIndex).removeValue { error, snap in
                if let error = error {
                    DispatchQueue.main.async {
                        errorBlock("error in deleteGroup -> getData { error, snap in }" + error.localizedDescription)
                    }
                    return
                }
                
                if !withoutUpdate {
                    dataManager.deleteGroup(groupIndex)
                }
                success()
            }
        }
    }
    
    // MARK: - Account
	
	static func deleteAccount(callback: @escaping (Bool) -> Void) {
		guard let currentUserID = currentUserID else {
			print("error in deleteAccount -> currentUserID")
			callback(false)
			return
		}
		ref.child("users").child(currentUserID).removeValue { error, ref in
			if let error {
				callback(false)
				return
			}
			callback(true)
		}
	}
    
    // MARK: - External API
    
    static func createExamples(with phrase: String) async throws -> [String] {
        let session = URLSession.shared
        
        guard let url = URL(string: "https://functions.yandexcloud.net/d4esp8oervpdc0ps5pfo?integration=raw") else {
            print("error in url [createExamples method]")
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST";
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/json"
        ]
        
        let sourceLanguage = UserDefaultsManager.learnLanguage?.getLangCodeForGeneratingExamples() ?? "english"
        let additionalLanguage =  UserDefaultsManager.learnLanguage == .eng ? "russian" : "english" // это не используется по сути, тут все правильно
        
        
        let body = [
            "queryStringParameters" : [
                "phrase" : "\(phrase)",
                "sourceLanguage" : "\(sourceLanguage)",
                "additionalLanguage" : "\(additionalLanguage)",
                
            ],
        ] as [String : Any]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Возникла ошибка при сериализации в NetworkManager -> createExamples")
            return []
        }
        
        request.httpBody = httpBody
        let (data, response) = try await session.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("NetworkManager -> createExamples status code is not 200: \(response)")
            return []
        }
        
        let exampleResponse = try JSONDecoder().decode(ExampleCreatingResponse.self, from: data)
        
        let examples = exampleResponse.body.examples.map{ $0.source }
//        else {
//            print("Не удалось декодировать ответ в NetworkManager -> createExamples")
//            return []
//        }
        
        print("createExamples: ", examples)
        
        
        return examples
    }
	
	static func translate(from text: String) async throws -> String {
		let session = URLSession.shared
		guard let url = URL(string: "https://translate.api.cloud.yandex.net/translate/v2/translate") else {
			print("error in url [translate method]")
			return ""
		}
		guard let learnLang = UserDefaultsManager.learnLanguage else {
			print("error in url [translate method] - learn lang")
			return ""
		}
		guard let nativeLang = UserDefaultsManager.nativeLanguage else {
			print("error in url [translate method] - native lang")
			return ""
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST";
		request.allHTTPHeaderFields = [
			"Content-Type" : "application/json",
            "Authorization" : ApiKeys.YandexKey.value()
		]
		
		let body = [
			"sourceLanguageCode" : "\(learnLang.getLangCodeForYandexApy())",
			"targetLanguageCode" : "\(nativeLang.getLangCodeForYandexApy())",
			"format" : "PLAIN_TEXT",
			"texts" : ["\(text)"],
			"speller" : true,
		] as [String : Any]
		
		guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
			print("Возникла ошибка при сериализации в NetworkManager -> translate")
			return ""
		}
		request.httpBody = httpBody
		let (data, response) = try await session.data(for: request)
		
		guard (response as? HTTPURLResponse)?.statusCode == 200 else {
			print("NetworkManager -> translate status code is not 200: \(response)")
			return ""
		}
		
		let transaltions = try JSONDecoder().decode(TranslatedResponse.self, from: data)
		
		guard let result = transaltions.translations.first?.text else {
			print("Не удалось декодировать ответ в NetworkManager -> translate")
			return ""
		}
		
		print("TRANSLATED: ", transaltions.translations.first!.text)
		return result
	}
}
