//
//  Router.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI

class Router: ObservableObject {
	
	@Published var userIsLoggedIn = UserDefaultsManager.isLoggedIn {
		didSet {
			UserDefaultsManager.isLoggedIn = userIsLoggedIn
		}
	}
	
	@Published var showActivityView = false
}
