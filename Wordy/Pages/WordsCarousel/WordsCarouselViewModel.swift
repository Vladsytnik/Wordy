//
//  WordsCarouselViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 08.02.2023.
//

import Foundation

class WordsCarouselViewModel: ObservableObject {
	
	var index = 0
	@Published var selectedWordIndex = 0
	@Published var modules: [Module] = []
	
	var thisModule: Module {
		modules[index]
	}
	var phrases: [Phrase] {
		thisModule.phrases
	}
	var selectedPhrase: Phrase {
		phrases[selectedWordIndex]
	}
}
