//
//  PhraseEditViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.04.2023.
//

import Foundation

class PhraseEditViewModel: ObservableObject {
	
	@Published var modules: [Module] = []
	@Published var filteredModules: [Module] = []
	@Published var phraseIndex = 0
	@Published var modulesIndex = 0
	@Published var searchedText = ""
	
	@Published var isActivityProccess = false
	
	@Published var examplePhrase = ""
	@Published var nativePhrase = ""
	@Published var translatedPhrase = ""
	
	@Published var textFieldOneIsActive = true
	@Published var textFieldTwoIsActive = false
	@Published var textFieldThreeIsActive = false
	
	@Published var nativePhraseIsEmpty = false
	@Published var translatedPhraseIsEmpty = false
	@Published var examplePhraseIsEmpty = false
	
	@Published var closeKeyboards = false
	var alert = (title: "Упс! Произошла ошибка...", description: "")
	@Published var showAlert = false
	
	func didTapTextField(index: Int) {
		textFieldOneIsActive = index == 0
		textFieldTwoIsActive = index == 1
		textFieldThreeIsActive = index == 2
	}
	
	func saveChanges(success: @escaping () -> Void) {
		
	}
}
