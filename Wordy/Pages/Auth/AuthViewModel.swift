//
//  AuthViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI

class AuthViewModel: ObservableObject {
	
	@Published var email = ""
	@Published var password = ""
	
	@Published var showAlert = false
	@Published var showNextPage = false
	
	var alertText = ""
	
//	@StateObject var router = Router.shared
	@EnvironmentObject var router: Router
	
	func signIn() {
		NetworkManager.signIn(email: email, password: password) { [weak self] resultText in
			self?.showNextPage = true
			self?.alertText = resultText
			self?.showAlert.toggle()
		} errorBlock: { [weak self] errorText in
			self?.alertText = errorText
			self?.showAlert.toggle()
		}
	}
	
	func register() {
		NetworkManager.register(email: email, password: password) { [weak self] resultText in
			self?.showNextPage = true
			self?.alertText = resultText
			self?.showAlert.toggle()
		} errorBlock: { [weak self] errorText in
			self?.alertText = errorText
			self?.showAlert.toggle()
		}
	}
}
