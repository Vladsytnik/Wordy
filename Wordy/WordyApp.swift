//
//  WordyApp.swift
//  Wordy
//
//  Created by Vlad Sytnik on 10.12.2022.
//

import SwiftUI
import Firebase

@main
struct WordyApp: App {
	
	@StateObject var router = Router()
	@StateObject var themeManager = ThemeManager()
	
	init() {
		FirebaseApp.configure()
	}
	
	var body: some Scene {
		WindowGroup {
			StartView()
				.environmentObject(router)
				.environmentObject(themeManager)
		}
	}
}
