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
				}
			}
		}
		.navigationBarTitle(LocalizedStringKey("Настройки"))
	}

	// MARK: - Helpers
	
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
