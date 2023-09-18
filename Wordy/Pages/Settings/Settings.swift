//
//  Settings.swift
//  Wordy
//
//  Created by Vlad Sytnik on 18.12.2022.
//

import SwiftUI
import Firebase

struct Settings: View {
	
	@EnvironmentObject var router: Router
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@State private var multiSelection = Set<Int>()
	@State var showDeleteAccountAlert = false
	@State var showDeleteAccountError = false
	@State var showAcivity = false
	@State var isPro = false
	
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
    }
}

// MARK: - Edit row

struct EditFolderRow: View {
	
	let cellHeight: CGFloat
	let didTapOnRow: (() -> Void)
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 12)
				.frame(height: cellHeight)
				.foregroundColor(Color(asset: Asset.Colors.moduleCardBG))
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
	
	let cellHeight: CGFloat
	let didTapOnRow: (() -> Void)
	
	var body: some View {
		Button {
			didTapOnRow()
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 12)
					.frame(height: cellHeight)
					.foregroundColor(Color(asset: Asset.Colors.moduleCardBG))
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
