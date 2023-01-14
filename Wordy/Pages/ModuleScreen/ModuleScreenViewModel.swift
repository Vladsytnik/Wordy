//
//  ModuleScreenViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import Foundation

class ModuleScreenViewModel: ObservableObject {
	
	var index = 0
	@Published var modules: [Module] = []
	
	var phrases: [Phrase] {
		modules[index].phrases
	}
	
	var phraseCount: Int {
		phrases.count
	}
	
	var module: Module {
		modules[index]
	}
	
	@Published var words: [String] = []
	@Published var showActionSheet = false
	
	func fetchWords() {
		
	}
}
