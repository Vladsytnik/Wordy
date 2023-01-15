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
	static let currentUserID = Auth.auth().currentUser?.uid
	
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
	
	static func signIn(email: String, password: String, success: @escaping (String) -> Void, errorBlock: @escaping (String) -> Void) {
		Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
			checkAnswer(
				authResult: authResult,
				error: error,
				success: success,
				errorBlock: errorBlock
			)
		}
	}
	
	static func checkAnswer(authResult: AuthDataResult?, error: Error?, success: @escaping (String) -> Void, errorBlock: @escaping (String) -> Void ) {
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
	
	static func createModule(name: String, emoji: String, success: @escaping (String) -> Void, errorBlock: @escaping (String) -> Void ) {
		guard let currentUserID = currentUserID else {
			errorBlock("error in createModule -> currentUserID")
			return
		}
		
		let date = String().generateCurrentDateMarker()

		ref.child("users").child(currentUserID).child("modules").childByAutoId().updateChildValues(["name" : name, "emoji" : emoji, "date": date]) { error, ref in
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
		
		var modules: [Module] = []
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
					
//					modules.forEach {
//						print($0.date)
//					}
					
					DispatchQueue.main.async {
						success(modules.sorted(by: { $0.date ?? Date() > $1.date ?? Date() }))
					}
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
			
			success()
		}
		
	}
}
