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
	
	var body: some View {
		Button {
			self.presentationMode.wrappedValue.dismiss()
			Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
				withAnimation { self.logOut() }
			}
		} label: {
			Text("Выйти")
		}
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
