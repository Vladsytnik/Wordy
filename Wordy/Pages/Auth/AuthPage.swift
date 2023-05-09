//
//  AuthPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct AuthPage: View {
	
	@StateObject private var viewModel = AuthViewModel()
	@EnvironmentObject var router: Router
	@State var animate = false
	@State var isFocused = false
	@State var loginWithEmail = false
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Image(asset: Asset.Images.authBG)
					.resizable()
					.edgesIgnoringSafeArea(.all)
				
				Image(asset: Asset.Images.authBG)
					.resizable()
					.offset(y: 10)
					.edgesIgnoringSafeArea(.top)
					.edgesIgnoringSafeArea(.leading)
					.edgesIgnoringSafeArea(.trailing)
					.opacity(isFocused ? 1 : 0)
					.animation(.default.delay(0.1), value: isFocused)
				
				VStack {
					Spacer()
					
					Text("Wordy.app")
						.foregroundColor(.white)
						.opacity(animate ? 1 : 0)
						.font(.system(size: 36, weight: .bold))
						.multilineTextAlignment(.center)
						.offset(y: animate ? 0 : -20)
						.padding(EdgeInsets(top: 32, leading: 0, bottom: 8, trailing: 0))
						.animation(.spring().delay(0.3), value: animate)
					Text("Изучай слова с комфортом \nи минималистичным дизайном")
						.foregroundColor(.white.opacity(0.9))
						.multilineTextAlignment(.center)
						.opacity(animate ? 1 : 0)
						.offset(y: animate ? 0 : -20)
						.animation(.spring().delay(0.5), value: animate)
					
					if loginWithEmail {
						Spacer()
						
						VStack {
							AuthTextField(placeholder: "Логин", text: $viewModel.email, isFocused: $isFocused)
							AuthTextField(placeholder: "Пароль", text: $viewModel.password, isFocused: $isFocused)
						}
						.textFieldStyle(.roundedBorder)
						.padding()
						
						Spacer()
						
						ButtonStack(geometry: geometry)
							.environmentObject(viewModel)
						
						Button {
							loginWithEmail.toggle()
						} label: {
							Text("Войти через AppleID")
						}
						.font(.system(size: 14))
						.foregroundColor(.white)
						.padding()
					}
					
					Spacer()
					
					if !loginWithEmail {
						SignInWithApple()
							.frame(width: 280, height: 60)
							.onTapGesture(perform: showAppleLogin)
					}
					
					if !loginWithEmail {
						Button {
							loginWithEmail.toggle()
						} label: {
							Text("Войти через почту")
						}
						.font(.system(size: 14))
						.foregroundColor(.white)
						.padding()
					}
				}
				.activity($viewModel.showActivity)
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
		.onAppear {
			animate.toggle()
		}
	}
	
	private func showAppleLogin() {
		viewModel.loginWithApple()
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
			VStack(spacing: 0) {
				Button {
					endEditing()
					viewModel.signIn()
				} label: {
					Text("Авторизоваться")
						.fontWeight(.bold)
						.padding(EdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 32))
				}
				.background(Color(asset: Asset.Colors.lightPurple))
				.foregroundColor(.white)
				.cornerRadius(12)
				
				Button {
					endEditing()
					viewModel.register()
				} label: {
					Text("Зарегистрироваться")
				}
				.font(.system(size: 14))
				.foregroundColor(.white)
				.padding()
			}
		}
		.disabled(!(viewModel.email.count > 2 && viewModel.password.count > 2))
		.padding()
	}
	
	func endEditing() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}

struct AuthTextField: View {
	
	var placeholder: String
	@Binding var text: String
	@Binding var isFocused: Bool
	private let cornerRadius: CGFloat = 12
	@FocusState var textFieldIsFocused: Bool
	
	var body: some View {
		TextField(placeholder, text: $text)
			.offset(x: -16)
			.textFieldStyle(.plain)
			.padding()
			.focused($textFieldIsFocused)
			.background {
				RoundedRectangle(cornerRadius: cornerRadius)
				//					.stroke(lineWidth: 0.5)
					.border(width: 0.5, edges: [.bottom], color: .white)
				//					.foregroundColor(Color(asset: Asset.Colors.lightPurple))
					.foregroundColor(.clear)
			}
			.onChange(of: textFieldIsFocused) { newValue in
				isFocused = newValue
			}
	}
}

