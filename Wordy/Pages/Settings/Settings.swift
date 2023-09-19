//
//  Settings.swift
//  Wordy
//
//  Created by Vlad Sytnik on 18.12.2022.
//

import SwiftUI
import Firebase

struct Settings: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	@EnvironmentObject var router: Router
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@State private var multiSelection = Set<Int>()
	@State var showDeleteAccountAlert = false
	@State var showDeleteAccountError = false
	@State var showAcivity = false
	@State var isPro = false
	
	@State var isThemeSelecting = false
	
	let offset: Double = 76
	let themeCirclesWidth: Double = 45
	let themeStrokeWidth: Double = 44
	
	@State var currentThemeIndex = 0
	private var generator2: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .soft)
	
	private let rowsTitles = [
		"Редактирование групп",
		"Выйти"
	]
	
	let cellHeight: CGFloat = 60
	
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
										
//										ZStack {
//											RoundedRectangle(cornerRadius: 16)
//												.foregroundColor(themeManager.allThemes()[index].accent)
//												.frame(width: 32, height: 32)
//												.padding(EdgeInsets(top: 0, leading: index == 0 ? 16 : 0, bottom: 0, trailing: 0))
//												.opacity(isThemeSelecting ? 1 : 0)
//												.animation(isThemeSelecting ? .spring().delay(0.03 * Double(index)) : .spring(), value: isThemeSelecting)
//
//											RoundedRectangle(cornerRadius: 16)
//												.foregroundColor(themeManager.allThemes()[index].main)
//												.frame(width: 32, height: 32)
//												.padding(EdgeInsets(top: 0, leading: index == 0 ? 16 : 0, bottom: 0, trailing: 0))
//												.opacity(isThemeSelecting ? 1 : 0)
//												.animation(isThemeSelecting ? .spring().delay(0.03 * Double(index)) : .spring(), value: isThemeSelecting)
//												.mask {
//													Rectangle()
//														.frame(width: 50, height: 50)
//														.offset(x: -18)
//														.rotationEffect(.degrees(isThemeSelecting ? 45 : 0))
//														.animation(isThemeSelecting ? .spring().delay(0.03 * Double(index)) : .spring(), value: isThemeSelecting)
//												}
//										}
										
										LinearGradient(colors: [themeManager.allThemes()[index].accent,
																themeManager.allThemes()[index].main,
																themeManager.allThemes()[index].main],
													   startPoint: .topLeading, endPoint: .bottomTrailing)
										.cornerRadius(themeCirclesWidth / 2)
										.frame(width: themeCirclesWidth,
											   height: themeCirclesWidth)
										.overlay {
											RoundedRectangle(cornerRadius: themeCirclesWidth / 2)
												.stroke(lineWidth: currentThemeIndex == index ? 0.5 : 0)
												.frame(width: themeStrokeWidth, height:themeStrokeWidth)
												.foregroundColor(.white)
												.animation(.easeIn(duration: 0.2), value: currentThemeIndex)
										}
										.padding(EdgeInsets(top: 0, leading: index == 0 ? 16 : 0, bottom: 0, trailing: 0))
										.opacity(isThemeSelecting ? 1 : 0)
										.animation(isThemeSelecting ? .spring().delay(0.03 * Double(index)) : .spring(), value: isThemeSelecting)
										.onTapGesture {
											generator2?.impactOccurred()
											currentThemeIndex = index
											themeManager.setNewTheme(with: index)
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
										   cellText: "Оформление",
										   cellImageName: "swatchpalette",
										   isOpenable: true,
										   isOpened: $isThemeSelecting)
						.offset(y: isThemeSelecting ? offset : 0)
					}
					.padding(EdgeInsets(top: 0, leading: 0, bottom: isThemeSelecting ? offset : 0, trailing: 0))
					.animation(.spring(), value: isThemeSelecting)

//						ZStack {
//							RoundedRectangle(cornerRadius: 12)
//								.frame(height: isThemeSelecting ? cellHeight + 10 : 0)
//								.foregroundColor(Color(asset: Asset.Colors.answer4))
//							HStack(spacing: 0) {
//								Text(LocalizedStringKey("cellText"))
//									.font(.system(size: 16, weight: .regular))
//									.foregroundColor(.white)
//								Spacer()
//							}
//						}
//						.opacity(isThemeSelecting ? 1 : 0)
//						.animation(.spring(), value: isThemeSelecting)
//						.padding(EdgeInsets(top: -40, leading: 16, bottom: 8, trailing: 16))
//						.zIndex(2)
					
					LogOutRow(cellHeight: cellHeight) {
						self.presentationMode.wrappedValue.dismiss()
						Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
							withAnimation { self.logOut() }
						}
					}
					
					Toggle(isOn: $isPro) {
						Text("PRO Subscription")
							.foregroundColor(.white)
					}
					.padding()
					
					Button {
						withAnimation {
							showDeleteAccountAlert.toggle()
						}
					} label: {
						Text("Удалить аккаунт")
							.foregroundColor(.gray)
					}
					.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
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
		.navigationBarTitle(LocalizedStringKey("Настройки"))
		.onAppear{
			isPro = UserDefaultsManager.userHasSubscription
			currentThemeIndex = themeManager.getCurrentThemeIndex()
		}
		.onChange(of: isPro) { newValue in
			UserDefaultsManager.userHasSubscription = newValue
		}
	}

	// MARK: - Helpers
	
	private func deleteAccount() {
		showAcivity = true
		NetworkManager.deleteAccount { isSuccess in
			showAcivity = false
			if isSuccess {
				showDeleteAccountAlert.toggle()
				self.logOut()
			} else {
				showDeleteAccountError.toggle()
			}
		}
	}
	
	private func isLastRow(_ i: Int) -> Bool {
		i == rowsTitles.count - 1
	}
	
	private func logOut() {
		do {
			try Auth.auth().signOut()
			router.userIsLoggedIn = false
		} catch  {
			print("Ошибка при выходе из аккаунта")
		}
	}
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
			.environmentObject(Router())
			.environmentObject(ThemeManager())
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
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.frame(height: cellHeight)
				.foregroundColor(themeManager.currentTheme.main)
			HStack(spacing: 0) {
				Image(systemName: cellImageName)
					.foregroundColor(.white)
					.padding()
				Text(LocalizedStringKey(cellText))
					.font(.system(size: 16, weight: .regular))
					.foregroundColor(.white)
				Spacer()
				if isOpenable {
					Image(systemName: "control")
//						.scaleEffect(0.3)
//						.foregroundColor(Color(asset: Asset.Colors.lightPurple))
						.foregroundColor(.white)
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
					.foregroundColor(.white)
					.padding()
				Text(LocalizedStringKey("Редактировать группы"))
					.font(.system(size: 16, weight: .regular))
					.foregroundColor(.white)
				Spacer()
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
						.foregroundColor(.white)
						.padding()
					Text(LocalizedStringKey("Выйти"))
						.font(.system(size: 16, weight: .medium))
						.foregroundColor(.red)
					Spacer()
				}
			}
		}
		.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
	}
}
