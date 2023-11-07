//
//  ThemeManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 18.09.2023.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
	
	private var currentThemeName: String! = Themes.availableThemes.first!.id
	@Published private(set) var currentTheme = Themes.availableThemes.first!
	
	var cancelable = Set<AnyCancellable>()
	
	init() {
		currentThemeName = UserDefaultsManager.themeName ?? Themes.availableThemes.first!.id
		let index = getCurrentThemeIndex()
		currentTheme = Themes.availableThemes[index]
		
//		$currentTheme
//			.sink{ self.setNewTheme(with: $0.id) }
//			.store(in: &cancelable)
	}
    
    init(_ index: Int) {
        currentTheme = Themes.availableThemes[index]
    }
	
//	func currentTheme() -> ColorTheme {
//		Themes.availableThemes.first { $0.id == currentThemeName } ?? Themes.availableThemes.first!
//	}
	
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
		let newThemeIndex = Themes.availableThemes
			.firstIndex(where: { $0.id == name }) ?? 0
		let newTheme = Themes.availableThemes[newThemeIndex]
		withAnimation {
			currentTheme = newTheme
		}
	}
	
	func setNewTheme(with index: Int) {
		let newName = allThemes()[index].id
		UserDefaultsManager.themeName = newName
		currentThemeName = newName
		let newTheme = Themes.availableThemes[index]
		withAnimation {
			currentTheme = newTheme
		}
	}
}
