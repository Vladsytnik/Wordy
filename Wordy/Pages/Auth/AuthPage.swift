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
	
	@EnvironmentObject var themeManager: ThemeManager
	@StateObject private var viewModel = AuthViewModel()
	@EnvironmentObject var router: Router
	@State var animate = false
	@State var isFocused = false
	@State var loginWithEmail = false
    
    @Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				themeManager.currentTheme.authBackgroundImage
					.resizable()
					.edgesIgnoringSafeArea(.all)
//                    .onTapGesture {
//                        UIApplication().endEditing()
//                    }
				
				themeManager.currentTheme.authBackgroundImage
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
						.foregroundColor(themeManager.currentTheme.mainText)
						.opacity(animate ? 1 : 0)
						.font(.system(size: 36, weight: .bold))
						.multilineTextAlignment(.center)
						.offset(y: animate ? 0 : -20)
						.padding(EdgeInsets(top: 32, leading: 0, bottom: 8, trailing: 0))
						.animation(.spring().delay(0.3), value: animate)
					Text("Изучай слова с комфортом \nи минималистичным дизайном".localize())
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.9))
						.multilineTextAlignment(.center)
						.opacity(animate ? 1 : 0)
						.offset(y: animate ? 0 : -20)
						.animation(.spring().delay(0.5), value: animate)
					
					if loginWithEmail {
						Spacer()
						
						VStack {
                            AuthTextField(placeholder: "Логин",
										  text: $viewModel.email,
										  isFocused: $isFocused,
                                          isEmail: true)
                            AuthTextField(placeholder: "Пароль",
										  text: $viewModel.password,
										  isFocused: $isFocused,
                                          isEmail: false)
						}
						.textFieldStyle(.roundedBorder)
						.padding()
						
						Spacer()
						
						ButtonStack(geometry: geometry)
							.environmentObject(viewModel)
						
						Button {
							loginWithEmail.toggle()
						} label: {
							Text("Войти через AppleID".localize())
						}
						.font(.system(size: 14))
						.foregroundColor(themeManager.currentTheme.mainText)
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
							Text("Войти через почту".localize())
						}
						.font(.system(size: 14))
						.foregroundColor(themeManager.currentTheme.mainText)
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
	
	@EnvironmentObject var themeManager: ThemeManager
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
					Text("Авторизоваться".localize())
						.fontWeight(.bold)
						.padding(EdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 32))
				}
				.background(themeManager.currentTheme.accent)
				.foregroundColor(themeManager.currentTheme.mainText)
				.cornerRadius(12)
				
				Button {
					endEditing()
					viewModel.register()
				} label: {
					Text("Зарегистрироваться".localize())
				}
				.font(.system(size: 14))
				.foregroundColor(themeManager.currentTheme.mainText)
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
	
    @Environment(\.colorScheme) var colorScheme
	var placeholder: String
	@Binding var text: String
	@Binding var isFocused: Bool
	private let cornerRadius: CGFloat = 12
	@FocusState var textFieldIsFocused: Bool
    let isEmail: Bool
	
	var body: some View {
        TextField(placeholder.localize(), text: $text)
			.offset(x: -16)
			.textFieldStyle(.plain)
			.padding()
			.focused($textFieldIsFocused)
			.background {
				RoundedRectangle(cornerRadius: cornerRadius)
					.border(width: 0.5, edges: [.bottom], color: colorScheme == .dark ? .white : .black)
					.foregroundColor(.clear)
			}
			.onChange(of: textFieldIsFocused) { newValue in
				isFocused = newValue
			}
            .if(isEmail) { v in
                v.keyboardType(.emailAddress)
            }
	}
}

