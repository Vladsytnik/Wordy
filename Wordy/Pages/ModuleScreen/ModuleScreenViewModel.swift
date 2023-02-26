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
	@Published var showAlert = false
	@Published var words: [String] = []
	@Published var showActionSheet = false
	@Published var showWordsCarousel = false
	
	var selectedWordIndex = 0
	
	var phrases: [Phrase] {
		modules[index].phrases.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
	}
	
	var phraseCount: Int {
		phrases.count
	}
	
	var module: Module {
		modules[index]
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
}
