//
//  ModuleScreenViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import SwiftUI

class ModuleScreenViewModel: ObservableObject {
	
	var index = 0
	
	@Published var modules: [Module] = []
	@Published var filteredModules: [Module] = []
	@Published var showAlert = false
	@Published var words: [String] = []
	@Published var showActionSheet = false
	@Published var showWordsCarousel = false
	@Published var thisModuleSuccessfullyDeleted = false
	@Published var showActivity = false
	@Published var showErrorAlert = false
	
	var selectedWordIndex = 0
	var alert = (title: "Упс! Произошла ошибка...", description: "")
	
	var phrases: [Phrase] {
		filteredModules[index].phrases.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
	}
	
	var phraseCount: Int {
		phrases.count
	}
	
	var module: Module {
		filteredModules[index]
	}
	
	func didTapDeleteModule() {
		withAnimation {
			showAlert.toggle()
		}
	}
	
	func didTapWord(with index: Int) {
		selectedWordIndex = index
		showWordsCarousel.toggle()
	}
	
	func nowReallyNeedToDeleteModule() {
		showActivity = true
		NetworkManager.deleteModule(with: module.id) { [weak self] in
			guard let self = self else { return }
			self.showActivity = false
			self.thisModuleSuccessfullyDeleted = true
		} errorBlock: { [weak self] errorText in
			guard let self = self else { return }
			self.alert.description = errorText
			self.showActivity = false
			self.showErrorAlert = true
		}

	}
}
