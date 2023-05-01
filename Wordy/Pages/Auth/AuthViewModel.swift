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
//	@Published var hideActivityView = false
	@Published var showActivity = false
	
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
}
