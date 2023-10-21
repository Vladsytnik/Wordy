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


//enum NetworkError: Error {
//	case signIn(text: ErrorText)
//	
//	enum ErrorText: String {
//		case unownError = "К сожалению, при авторизации что-то пошло не так"
//	}
//}

class NetworkManager {
	
	static var ref = Database.database(url: "https://wordy-a720d-default-rtdb.europe-west1.firebasedatabase.app/").reference()
//	static let db = Firestore.firestore()
	static var currentUserID: String? { Auth.auth().currentUser?.uid }
	
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
			
			print("error in sendToken -> success")
		}
		
//		let localDate = String().generateCurrentDateMarker()
//		let date = String().generateCurrentDateMarkerInUTC0()
		let dateToUtc0 = String().generateDateMarkerInUTC0(withHour: 21, and: 00)
		
		guard let dateToUtc0 else {
			print("error in sendToken -> dateToUtc0")
			return
		}
		
		ref.child("users").child(currentUserID).child("notifications").childByAutoId().updateChildValues([
			"notificationDateTime": dateToUtc0,
			"title" : "Test Title",
			"description" : "Test Description"
		]) { error, ref in
			guard error == nil else {
				print("error in sendToken -> updateChildValues (notifications): \(error)")
				return
			}
			
			print("error in sendToken -> success")
		}
	}
    
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
        let additionalLanguage =  UserDefaultsManager.learnLanguage != .ru ? "russian" : "english"
        
        
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
	
	static func createModule(name: String, 
                             emoji: String,
                             phrases: [Phrase]? = nil,
                             success: @escaping (String) -> Void,
                             errorBlock: @escaping (String) -> Void ) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in createModule -> currentUserID")
			return
		}
		
		let date = String().generateCurrentDateMarker()
		
		var phrasesDict: [String: [String: String]] = [:]
		if let phrases {
			for phrase in phrases {
				let newPhrase = [
					Constants.nativeText: phrase.nativeText,
					Constants.translatedText: phrase.translatedText,
					Constants.date: String().generateCurrentDateMarker(),
					Constants.example: phrase.example ?? ""
				]
				let url = URL(string: ref.childByAutoId().url)
				if let lastPathComp = url?.lastPathComponent {
					phrasesDict[lastPathComp] = newPhrase
				}
			}
		}

		ref.child("users").child(currentUserID).child("modules").childByAutoId().updateChildValues(["name" : name, "emoji" : emoji, "date": date, "phrases": phrasesDict]) { error, ref in
			guard error == nil else {
				errorBlock("error in createModule -> updateChildValues")
				return
			}
			
			success("success")
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
			ref.child("users").child(currentUserID).child("modules").child(moduleID).removeValue { error, snap in
				if let error = error {
					DispatchQueue.main.async {
						errorBlock("error in deleteModule -> getData { error, snap in }" + error.localizedDescription)
						//						errorBlock("")
					}
					return
				}
				
				success()
//				if let snapshot = snap {
//					guard let modules = Module.parse(from: snapshot) else {
//						DispatchQueue.main.async {
//							errorBlock("error in getModules -> parse module")
//						}
//						return
//					}
//
//					DispatchQueue.main.async {
//						success()
//					}
//				}
			}
		}
	}
	
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
						//						errorBlock("")
					}
					return
				}
				
				success()
			}
		}
	}
	
	static func deleteGroup(with groupIndex: String, success: @escaping () -> Void, errorBlock: @escaping (String) -> Void) {
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
				
				success()
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
			
			success()
		}
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
			
			success()
		}
	}
	

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
				
				success("success")
			}
		} else {
			ref.child("users").child(currentUserID).child("groups").childByAutoId().updateChildValues(["name": name, "date": date]) { error, ref in
				guard error == nil else {
					errorBlock("error in createGroup -> updateChildValues")
					return
				}
				
				success("success")
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
				
				success("success")
			}
		} else {
			ref.child("users").child(currentUserID).child("groups").child(group.id).updateChildValues(["name": group.name, "modulesID": []]) { error, ref in
				guard error == nil else {
					errorBlock("error in createGroup -> updateChildValues")
					return
				}
				
				success("success")
			}
		}
	}
	
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
	
	static func translate(from text: String) async throws -> String {
		let session = URLSession.shared
//		session.invalidateAndCancel()
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
			"Authorization" : "Api-Key AQVN0OEuE0aqTVasJb1JxIBXZpsvwCUx2xiZCSk7"
		]
		
		let body = [
			"sourceLanguageCode" : "\(learnLang.getLangCodeForYandexApy())",
			"targetLanguageCode" : "\(nativeLang.getLangCodeForYandexApy())",
			"format" : "PLAIN_TEXT",
			"texts" : ["\(text)"],
			"speller" : false,
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
