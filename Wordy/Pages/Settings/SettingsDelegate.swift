//
//  SettingsDelegate.swift
//  Wordy
//
//  Created by Vlad Sytnik on 27.09.2023.
//

import SwiftUI
import AuthenticationServices
import Firebase
import FirebaseAuth
import FirebaseCore

class SettingsDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
	
	var currentNonce: String?
	var isSignedOut: (() -> Void)?
	
	func authorizationController(controller: ASAuthorizationController,
								 didCompleteWithAuthorization authorization: ASAuthorization) {
		guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
		else {
			print("Unable to retrieve AppleIDCredential")
			return
		}
		
		guard let _ = currentNonce else {
			fatalError("Invalid state: A login callback was received, but no login request was sent.")
		}
		
		guard let appleAuthCode = appleIDCredential.authorizationCode else {
			print("Unable to fetch authorization code")
			return
		}
		
		guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
			print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
			return
		}
		
		Task {
			do {
				try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
				isSignedOut?()
			} catch {
				print(error)
			}
		}
	}
	
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return UIApplication.shared.windows[0]
	}
}
