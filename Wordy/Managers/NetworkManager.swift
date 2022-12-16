//
//  NetworkManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 15.12.2022.
//

import FirebaseAuth

//enum NetworkError: Error {
//	case signIn(text: ErrorText)
//	
//	enum ErrorText: String {
//		case unownError = "К сожалению, при авторизации что-то пошло не так"
//	}
//}

class NetworkManager {
	
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
}
