//
//  ThemeManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 18.09.2023.
//

import SwiftUI

class ThemeManager: ObservableObject {
	
	private var currentThemeName: String! = Themes.availableThemes.first!.id
	
	init() {
		currentThemeName = UserDefaultsManager.themeName ?? Themes.availableThemes.first!.id
	}
	
	func currentTheme() -> ColorTheme {
		Themes.availableThemes.first { $0.id == currentThemeName } ?? Themes.availableThemes.first!
	}
	
	func allThemes() -> [ColorTheme] {
		Themes.availableThemes
	}
	
	func getCurrentThemeIndex() -> Int {
		Themes.availableThemes
			.firstIndex(where: { $0.id == currentThemeName }) ?? 0
	}
	
	func setNewTheme(with name: String) {
		UserDefaultsManager.themeName = name
		currentThemeName = name
	}
	
	func setNewTheme(with index: Int) {
		let newName = allThemes()[index].id
		UserDefaultsManager.themeName = newName
		currentThemeName = newName
	}
}
