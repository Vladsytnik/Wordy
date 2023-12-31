//
//  Settings.swift
//  Wordy
//
//  Created by Vlad Sytnik on 18.12.2022.
//

import SwiftUI
import Firebase
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import Combine

struct Settings: View {
	
	@EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
	@EnvironmentObject var router: Router
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@State private var multiSelection = Set<Int>()
	@State var showDeleteAccountAlert = false
	@State var showDeleteAccountError = false
	@State var showAcivity = false
	@State var isTestPro = false
	
	@State var isThemeSelecting = false
	@State var currentNonce: String = ""
    let settingsDelegate = SettingsDelegate()
	
	let offset: Double = 76
	let themeCirclesWidth: Double = 45
	let themeStrokeWidth: Double = 44
	
	@State var currentThemeIndex = 0
    var generator2: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .soft)
	
    let rowsTitles = [
		"Редактирование групп",
		"Выйти"
	]
    
    @State private var cancelable = Set<AnyCancellable>()
	
	let cellHeight: CGFloat = 60
    @State var isShowPaywall = false
	
	var body: some View {
		ZStack {
			BackgroundView()
			ScrollView {
				Rectangle()
					.foregroundColor(.clear)
					.frame(height: 32)
				VStack {
					NavigationLink {
						GroupsEditingPage()
					} label: {
						EditFolderRow(cellHeight: cellHeight) {
							print("Редактировать группы")
						}
					}
					
					ZStack {
						ZStack {
//							RoundedRectangle(cornerRadius: isThemeSelecting ? 12 : 12)
//								.stroke()
//								.frame(height: cellHeight)
//								.foregroundColor(Color(asset: Asset.Colors.moduleCardBG))
							ScrollView(.horizontal, showsIndicators: false) {
								HStack(spacing: 8) {
									ForEach(0..<themeManager.allThemes().count) { index in
                                        ZStack {
                                            LinearGradient(colors: [
                                                themeManager.allThemes()[index].gradientStart ?? themeManager.allThemes()[index].accent,
                                                
                                                themeManager.allThemes()[index].gradientEnd ?? themeManager.allThemes()[index].main,
                                                
                                                themeManager.allThemes()[index].gradientEnd ?? themeManager.allThemes()[index].main
                                            ],
                                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                                            .cornerRadius(themeCirclesWidth / 2)
                                            .frame(width: themeCirclesWidth,
                                                   height: themeCirclesWidth)
//                                            .opacity(themeManager.allThemes()[index].isFree ? 1 : 0.7)
                                            .overlay {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: themeCirclesWidth / 2)
                                                        .stroke(lineWidth: currentThemeIndex == index ? 0.5 : 0)
                                                        .frame(width: themeStrokeWidth, height:themeStrokeWidth)
                                                        .foregroundColor(.white)
                                                        .animation(.easeIn(duration: 0.2), value: currentThemeIndex)
                                                    
//                                                    if currentThemeIndex == index {
//                                                        Rectangle()
//                                                            .frame(width: 40, height: 2)
//                                                            .foregroundColor(themeManager.currentTheme.main)
//                                                            .offset(y: themeCirclesWidth + 8)
//                                                    }
                                                    //                                                Image(systemName: "checkmark")
                                                    //                                                    .foregroundColor(.white)
                                                    //                                                    .opacity(currentThemeIndex == index ? 1 : 0)
                                                }
                                            }
                                            .padding(EdgeInsets(top: 0, leading: index == 0 ? 16 : 0, bottom: 0, trailing: 0))
                                            .opacity(isThemeSelecting ? 1 : 0)
                                            .animation(isThemeSelecting ? .spring().delay(0.03 * Double(index)) : .spring(), value: isThemeSelecting)
                                            .animation(.spring(), value: currentThemeIndex)
                                            .onTapGesture {
                                                guard themeManager.allThemes()[index].isFree
                                                        || (!themeManager.allThemes()[index].isFree
                                                             && subscriptionManager.userHasSubscription())
                                                else {
                                                    isShowPaywall = true
                                                    return
                                                }
                                                
                                                generator2?.impactOccurred()
                                                currentThemeIndex = index
                                                themeManager.setNewTheme(with: index)
                                            }
                                            
                                            // Selected Indicator
                                            
                                            if currentThemeIndex == index {
                                                let height: CGFloat = 3
                                                Circle()
                                                    .frame(width: height, height: height)
                                                    .foregroundColor(.white)
//                                                    .offset(y: (themeCirclesWidth / 2) + 0)
                                                    .padding(EdgeInsets(top: 0, leading: index == 0 ? 16 : 0, bottom: 0, trailing: 0))
                                            }
                                            
                                            if !themeManager.allThemes()[index].isFree
                                                && !subscriptionManager.userHasSubscription()
                                            {
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                        }
									}
									Spacer()
								}
								.zIndex(2)
							}
						}
						.opacity(isThemeSelecting ? 1 : 0)
						.animation(.spring(), value: isThemeSelecting)
						.padding(EdgeInsets(top: 0, leading: isThemeSelecting ? 0 : 16, bottom: 8, trailing: isThemeSelecting ? 0 : 16))
						.animation(.spring(), value: isThemeSelecting)
						
						GeneralSettingsRow(cellHeight: cellHeight,
                                           cellText: "Оформление".localize(),
										   cellImageName: "swatchpalette",
										   isOpenable: true,
										   isOpened: $isThemeSelecting, didTapOnRow: {})
						.offset(y: isThemeSelecting ? offset : 0)
					}
					.padding(EdgeInsets(top: 0, leading: 0, bottom: isThemeSelecting ? offset : 0, trailing: 0))
					.animation(.spring(), value: isThemeSelecting)

//						ZStack {
//							RoundedRectangle(cornerRadius: 12)
//								.frame(height: isThemeSelecting ? cellHeight + 10 : 0)
//								.foregroundColor(Color(asset: Asset.Colors.answer4))
//							HStack(spacing: 0) {
//								Text("cellText".localize())
//									.font(.system(size: 16, weight: .regular))
//									.foregroundColor(themeManager.currentTheme.mainText)
//								Spacer()
//							}
//						}
//						.opacity(isThemeSelecting ? 1 : 0)
//						.animation(.spring(), value: isThemeSelecting)
//						.padding(EdgeInsets(top: -40, leading: 16, bottom: 8, trailing: 16))
//						.zIndex(2)
					
					
					NavigationLink {
						SelectLanguagePage(isFromSettings: true)
							.navigationTitle("Язык")
					} label: {
						GeneralSettingsRow(cellHeight: cellHeight,
										   cellText: "Сменить язык",
										   cellImageName: "character.bubble",
										   isOpenable: false,
										   isOpened: $isThemeSelecting)
					}
                    
                    NavigationLink {
                        TimeIntervalView()
                    } label: {
                        GeneralSettingsRow(cellHeight: cellHeight,
                                           cellText: "Уведомления",
                                           cellImageName: "bell",
                                           isOpenable: false,
                                           isOpened: .constant(false))
                    }
					
					LogOutRow(cellHeight: cellHeight) {
						self.presentationMode.wrappedValue.dismiss()
						Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
							withAnimation { self.logOut() }
						}
					}
					
					Toggle(isOn: $isTestPro) {
                        Text("Test PRO Subscription".localize())
							.foregroundColor(themeManager.currentTheme.mainText)
					}
					.padding()
					
					Button {
						withAnimation {
							showDeleteAccountAlert.toggle()
						}
					} label: {
                        Text("Удалить аккаунт".localize())
							.foregroundColor(.gray)
					}
					.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    
                    if subscriptionManager.userHasSubscription() {
                        Text("Wordy Pro".localize())
                            .bold()
                            .foregroundColor(themeManager.currentTheme.accent)
//                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
//                            .background {
//                                RoundedRectangle(cornerRadius: 16)
//                                    .foregroundColor(themeManager.currentTheme.accent)
//                            }
                            .padding()
                    }
				}
			}
			.showAlert(title: "Wordy.app",
					   description: "\nВы уверены, что хотите\n удалить аккаунт? \n\nЭто действие нельзя \nбудет отменить.",
					   isPresented: $showDeleteAccountAlert,
					   titleWithoutAction: NSLocalizedString("Отменить", comment: ""),
					   titleForAction: "Удалить аккаунт",
					   withoutButtons: false)
			{
				deleteAccount()
			}
			.showAlert(title: "Wordy.app",
					   description: "\n Возникла проблема \nпри удалении аккаунта.",
					   isPresented: $showDeleteAccountError)
			{
				deleteAccount()
			}
			.activity($showAcivity)
		}
		.navigationBarTitle("Настройки".localize())
		.onAppear{
			isTestPro = UserDefaultsManager.userHasTestSubscription
			currentThemeIndex = themeManager.getCurrentThemeIndex()
		}
		.onChange(of: isTestPro) { newValue in
			UserDefaultsManager.userHasTestSubscription = newValue
            NetworkManager.updateSubscriptionInfo(isTestPro: newValue)
		}
        .onAppear {
            subscriptionManager.printSubscriptionInfo()
        }
        .sheet(isPresented: $isShowPaywall, content: {
            Paywall(isOpened: $isShowPaywall)
        })
	}

	// MARK: - Helpers
	
	private func deleteAccount() {
		Task {
			NetworkManager.deleteAccount { isSuccess in
				showAcivity = false
				if isSuccess {
					showDeleteAccountAlert.toggle()
					self.logOut()
				} else {
					showDeleteAccountError.toggle()
				}
			}
			router.userIsLoggedIn = false
			UserDefaultsManager.userID = nil
//			await deleteCurrentUser()
		}
	}
	
	private func isLastRow(_ i: Int) -> Bool {
		i == rowsTitles.count - 1
	}
	
	private func logOut() {
		do {
			try Auth.auth().signOut()
//			Task {
//				try await Auth.auth().currentUser?.delete()
//				router.userIsLoggedIn = false
//			}
		} catch  {
			print("Ошибка при выходе из аккаунта")
		}
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
	
	private func deleteCurrentUser() async {
		do {
			let nonce = randomNonceString()
			currentNonce = nonce
			settingsDelegate.currentNonce = nonce
			settingsDelegate.isSignedOut = {
				
			}
			let appleIDProvider = ASAuthorizationAppleIDProvider()
			let request = appleIDProvider.createRequest()
			request.requestedScopes = [.fullName, .email]
			request.nonce = sha256(nonce)
			
			let authorizationController = ASAuthorizationController(authorizationRequests: [request])
			authorizationController.delegate = settingsDelegate
			authorizationController.presentationContextProvider = settingsDelegate
			authorizationController.performRequests()
			
			do {
				guard let authCodeString = UserDefaultsManager.userID else { return }
				try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
				showAcivity = true
				try await Auth.auth().currentUser?.delete()
				
			} catch {
				print(error)
			}
		} catch {
			// In the unlikely case that nonce generation fails, show error view.
			print("Error on sign out:", error)
		}
	}
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
			.environmentObject(Router())
			.environmentObject(ThemeManager())
            .environmentObject(SubscriptionManager())
    }
}

// MARK: - General settings row

struct GeneralSettingsRow: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	let cellHeight: CGFloat
	let cellText: String
	let cellImageName: String
	var isOpenable = false
	@Binding var isOpened: Bool
	var didTapOnRow: (() -> Void)?
	
	var body: some View {
		if didTapOnRow != nil {
			ZStack {
				RoundedRectangle(cornerRadius: 12)
					.frame(height: cellHeight)
					.foregroundColor(themeManager.currentTheme.main)
				HStack(spacing: 0) {
					Image(systemName: cellImageName)
						.foregroundColor(themeManager.currentTheme.mainText)
						.padding()
                    Text(cellText.localize())
						.font(.system(size: 16, weight: .regular))
						.foregroundColor(themeManager.currentTheme.mainText)
					Spacer()
					if isOpenable {
						Image(systemName: "control")
						//						.scaleEffect(0.3)
						//						.foregroundColor(Color(asset: Asset.Colors.lightPurple))
							.foregroundColor(themeManager.currentTheme.mainText)
							.padding()
							.rotationEffect(.degrees(isOpened ? 0 : 90))
							.animation(.spring(), value: isOpened)
					}
				}
			}
			.onTapGesture {
				if isOpenable {
					withAnimation {
						isOpened.toggle()
					}
				} else {
					didTapOnRow?()
				}
			}
			.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
		} else {
			ZStack {
				RoundedRectangle(cornerRadius: 12)
					.frame(height: cellHeight)
					.foregroundColor(themeManager.currentTheme.main)
				HStack(spacing: 0) {
					Image(systemName: cellImageName)
						.foregroundColor(themeManager.currentTheme.mainText)
						.padding()
                    Text(cellText.localize())
						.font(.system(size: 16, weight: .regular))
						.foregroundColor(themeManager.currentTheme.mainText)
					Spacer()
					if isOpenable {
						Image(systemName: "control")
						//						.scaleEffect(0.3)
						//						.foregroundColor(Color(asset: Asset.Colors.lightPurple))
							.foregroundColor(themeManager.currentTheme.mainText)
							.padding()
							.rotationEffect(.degrees(isOpened ? 0 : 90))
							.animation(.spring(), value: isOpened)
                    } else {
                        Image(systemName: "control")
                        //                        .scaleEffect(0.3)
                        //                        .foregroundColor(Color(asset: Asset.Colors.lightPurple))
                            .foregroundColor(themeManager.currentTheme.mainText)
                            .padding()
                            .rotationEffect(.degrees(90))
                    }
				}
			}
			.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
		}
	}
}

// MARK: - Edit row

struct EditFolderRow: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	let cellHeight: CGFloat
	let didTapOnRow: (() -> Void)
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.frame(height: cellHeight)
				.foregroundColor(themeManager.currentTheme.main)
			HStack(spacing: 0) {
				Image(systemName: "folder")
					.foregroundColor(themeManager.currentTheme.mainText)
					.padding()
				Text("Редактировать группы".localize())
					.font(.system(size: 16, weight: .regular))
					.foregroundColor(themeManager.currentTheme.mainText)
				Spacer()
                Image(systemName: "control")
                    .foregroundColor(themeManager.currentTheme.mainText)
                    .rotationEffect(.degrees(90))
                    .padding()
			}
		}
		.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
	}
}

// MARK: - Log out row

struct LogOutRow: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	let cellHeight: CGFloat
	let didTapOnRow: (() -> Void)
	
	var body: some View {
		Button {
			didTapOnRow()
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 12)
					.frame(height: cellHeight)
					.foregroundColor(themeManager.currentTheme.main)
				HStack(spacing: 0) {
					Image(systemName: "rectangle.portrait.and.arrow.forward")
						.foregroundColor(themeManager.currentTheme.mainText)
						.padding()
					Text("Выйти".localize())
						.font(.system(size: 16, weight: .medium))
						.foregroundColor(.red)
					Spacer()
				}
			}
		}
		.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
	}
}
