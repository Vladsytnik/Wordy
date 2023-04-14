//
//  WordCardViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 14.01.2023.
//

import Foundation

class WordCardViewModel: ObservableObject {
	
	@Published var modules: [Module] = []
	@Published var newAddedExample: String = ""
	@Published var isAddingExample = false
	
	var index = 0
	var phrase = Phrase(nativeText: "", translatedText: "")
	
	var thisModule: Module {
		modules[index]
	}
	
}
