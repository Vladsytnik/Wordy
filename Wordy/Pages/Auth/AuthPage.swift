//
//  AuthPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI
import FirebaseAuth

struct AuthPage: View {
	
	@StateObject private var viewModel = AuthViewModel()
	@EnvironmentObject var router: Router
	
	var body: some View {
		Color.clear
			.background {
				GeometryReader { geometry in
					VStack {
						Spacer()
						VStack {
							TextField("Логин", text: $viewModel.email)
							TextField("Пароль", text: $viewModel.password)
						}
						.textFieldStyle(.roundedBorder)
						.padding()
						Spacer()
						ButtonStack(geometry: geometry)
							.environmentObject(viewModel)
					}
				}
			}
			.alert(isPresented: $viewModel.showAlert) {
				.init(title: Text(viewModel.alertText))
			}
			.onChange(of: viewModel.showNextPage) { newValue in
				withAnimation {
					router.userIsLoggedIn = true
				}
			}
			.onChange(of: viewModel.hideActivityView) { _ in
				if viewModel.hideActivityView {
					router.showActivityView = false
				}
			}
	}
}

struct AuthPage_Previews: PreviewProvider {
    static var previews: some View {
        AuthPage()
    }
}

struct ButtonStack: View {
	
	@EnvironmentObject var router: Router
	@EnvironmentObject var viewModel: AuthViewModel
	let geometry: GeometryProxy
	
	var body: some View {
		VStack(alignment: .center) {
			VStack {
				Button {
					endEditing()
					router.showActivityView = true
					viewModel.signIn()
				} label: {
					Text("Авторизоваться")
						.padding(EdgeInsets(top: 8, leading: 32, bottom: 8, trailing: 32))
				}
				.background(Color.blue)
				.foregroundColor(.white)
				.cornerRadius(12)
				Button {
					endEditing()
					router.showActivityView = true
					viewModel.register()
				} label: {
					Text("Зарегистрироваться")
				}
				.font(.system(size: 14))
				.foregroundColor(.blue)
			}
		}
		.disabled(!(viewModel.email.count > 2 && viewModel.password.count > 2))
		.padding()
	}
	
	func endEditing() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
