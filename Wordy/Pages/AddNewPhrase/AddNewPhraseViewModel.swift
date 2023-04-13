//
//  AddNewPhraseViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 08.01.2023.
//

import SwiftUI
import Combine

class AddNewPhraseViewModel: ObservableObject {
	
	var index = 0
	@Published var modules: [Module] = []
	@Published var filteredModules: [Module] = []
	
	@Published var nativePhrase = ""
	@Published var translatedPhrase = ""
	@Published var searchedText = ""
	@Published var examplePhrase = ""
	
	@Published var textFieldOneIsActive = true
	@Published var textFieldTwoIsActive = false
	@Published var textFieldThreeIsActive = false
	
	@Published var swipeOffsetValue: CGFloat = 0
	
	@Published var isActivityProccess = false
	@Published var showAlert = false
	
	@Published var nativePhraseIsEmpty = false
	@Published var translatedPhraseIsEmpty = false
	@Published var examplePhraseIsEmpty = false
	
	var alert = (title: "Упс! Произошла ошибка...", description: "")
	
	var module: Module {
		filteredModules[index]
	}
	
	@Published var closeKeyboards = false
	
	func didTapTextField(index: Int) {
		textFieldOneIsActive = index == 0
		textFieldTwoIsActive = index == 1
		textFieldTwoIsActive = index == 2
	}
	
	func addWordToCurrentModule(success: @escaping () -> Void) {
		guard !nativePhrase.isEmpty && !translatedPhrase.isEmpty else {
			shakeTextField()
			return
		}
		
		changeActivityState(toProccess: true)
		
		var existingPhrases = module.getPhrasesAsDictionary()
		existingPhrases.append([
			Constants.nativeText: nativePhrase,
			Constants.translatedText: translatedPhrase,
			Constants.date: String().generateCurrentDateMarker(),
			Constants.example: examplePhrase
		])
		
		let queue = DispatchQueue(label: "sytnik.wordy.addWordTo")
		
		queue.async {
			NetworkManager.update(phrases: existingPhrases, from: self.module.id) { [weak self] in
				guard let self = self else { return }
				
				NetworkManager.getModules { modules in
					self.changeActivityState(toProccess: false)
//					self.filteredModules = modules.filter{ $0.name.contains("\(self.searchedText)") }
					self.modules = modules
					success()
				} errorBlock: { errorText in
					self.changeActivityState(toProccess: false)
					self.alert.description = errorText
					self.showAlertNow()
				}

				
			} errorBlock: { [weak self] errorText in
				guard let self else { return }
				self.changeActivityState(toProccess: false)
				self.alert.description = errorText
				self.showAlertNow()
				return
			}
		}
	}
	
	private func changeActivityState(toProccess: Bool) {
		withAnimation {
			if toProccess {
				self.isActivityProccess = true
			} else {
				self.isActivityProccess = false
			}
		}
	}
	
	private func showAlertNow() {
		DispatchQueue.main.async {
			withAnimation {
				self.showAlert = true
			}
		}
	}
	
	private func shakeTextField() {
		let group = DispatchGroup()
		
		let workItem = DispatchWorkItem {
			withAnimation(.default.repeatCount(4, autoreverses: true).speed(6)) {
				self.nativePhraseIsEmpty = self.nativePhrase.isEmpty
				self.translatedPhraseIsEmpty = self.translatedPhrase.isEmpty
			}
			group.leave()
		}
		
		group.enter()
		DispatchQueue.main.async(execute: workItem)
		
		group.notify(queue: .main) {
			self.nativePhraseIsEmpty = false
			self.translatedPhraseIsEmpty = false
		}
	}
}
