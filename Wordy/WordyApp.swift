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
	
	init() {
		FirebaseApp.configure()
	}
	
	var body: some Scene {
		WindowGroup {
			StartView()
				.environmentObject(Router())
		}
	}
}
