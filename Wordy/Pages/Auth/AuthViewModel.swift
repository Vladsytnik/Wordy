//
//  AuthViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI
import Foundation
import CryptoKit
import AuthenticationServices
import FirebaseAuth


class AuthViewModel: NSObject, ObservableObject {
	
	@Published var email = ""
	@Published var password = ""
	
	@Published var showAlert = false
	@Published var showNextPage = false
//	@Published var hideActivityView = false
	@Published var showActivity = false
	
	// Unhashed nonce.
	fileprivate var currentNonce: String?
	
	var alertText = ""
	
//	@StateObject var router = Router.shared
	@EnvironmentObject var router: Router
	
	func signIn() {
		showActivity = true
		NetworkManager.signIn(email: email, password: password) { [weak self] resultText in
			guard let self = self else { return }
			self.hideActivity()
			self.showNextPage = true
			self.alertText = resultText
			self.showAlert.toggle()
		} errorBlock: { [weak self] errorText in
			guard let self = self else { return }
			self.hideActivity()
			self.alertText = errorText
			self.showAlert.toggle()
		}
	}
	
	func register() {
		showActivity = true
		NetworkManager.register(email: email, password: password) { [weak self] resultText in
			guard let self = self else { return }
			self.hideActivity()
			self.showNextPage = true
			self.alertText = resultText
			self.showAlert.toggle()
		} errorBlock: { [weak self] errorText in
			guard let self = self else { return }
			self.hideActivity()
			self.alertText = errorText
			self.showAlert.toggle()
		}
	}
	
	private func hideActivity() {
		DispatchQueue.main.async {
			self.showActivity = false
		}
	}
	
	func loginWithApple() {
		showActivity = true
		startSignInWithAppleFlow()
	}
}

// MARK: - Authentication fow

extension AuthViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
	
	func startSignInWithAppleFlow() {
		let nonce = randomNonceString()
		currentNonce = nonce
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		request.nonce = sha256(nonce)
		
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
	}
	
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return UIApplication.shared.windows[0]
	}
	
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
			guard let nonce = currentNonce else {
				fatalError("Invalid state: A login callback was received, but no login request was sent.")
			}
			guard let appleIDToken = appleIDCredential.identityToken else {
				print("Unable to fetch identity token")
				return
			}
			guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
				print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
				return
			}
			
			// for logout
			UserDefaultsManager.userID = idTokenString
			
			// Initialize a Firebase credential, including the user's full name.
			let credential = OAuthProvider.credential(withProviderID: "apple.com",
													  idToken: idTokenString,
													  rawNonce: nonce)
			// Sign in with Firebase.
			Auth.auth().signIn(with: credential) { (authResult, error) in
				if let error {
					// Error. If error.code == .MissingOrInvalidNonce, make sure
					// you're sending the SHA256-hashed nonce as a hex string with
					// your request to Apple.
					let errorText = error.localizedDescription
					print(errorText)
					self.hideActivity()
					self.alertText = "Sign in with Apple errored: \(errorText)"
					self.showAlert.toggle()
					return
				}
				
				let oAuthToken = (authResult?.credential as? OAuthCredential)?.accessToken
				print("oAuthToken access: ", oAuthToken)
				let oAuthToken2 = (authResult?.credential as? OAuthCredential)?.idToken
				print("oAuthToken ID: ", oAuthToken2)
				// User is signed in to Firebase with Apple.
				// ...
				self.hideActivity()
				self.showNextPage = true
			}
		}
	}
	
	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		// Handle error.
		print("Sign in with Apple errored: \(error)")
		self.hideActivity()
		self.alertText = "Sign in with Apple errored"
		self.showAlert.toggle()
	}
	
	private func randomNonceString(length: Int = 32) -> String {
		precondition(length > 0)
		var randomBytes = [UInt8](repeating: 0, count: length)
		let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
		if errorCode != errSecSuccess {
			fatalError(
				"Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
			)
		}
		
		let charset: [Character] =
		Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
		
		let nonce = randomBytes.map { byte in
			// Pick a random character from the set, wrapping around if needed.
			charset[Int(byte) % charset.count]
		}
		
		return String(nonce)
	}
	
	private func sha256(_ input: String) -> String {
		let inputData = Data(input.utf8)
		let hashedData = SHA256.hash(data: inputData)
		let hashString = hashedData.compactMap {
			String(format: "%02x", $0)
		}.joined()
		
		return hashString
	}
}
