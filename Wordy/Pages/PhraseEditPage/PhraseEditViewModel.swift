//
//  PhraseEditViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.04.2023.
//

import SwiftUI

class PhraseEditViewModel: ObservableObject {
	
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
    var alert = (title: "Упс! Произошла ошибка...".localize(), description: "")
	@Published var showAlert = false
	
	func didTapTextField(index: Int) {
		textFieldOneIsActive = index == 0
		textFieldTwoIsActive = index == 1
		textFieldThreeIsActive = index == 2
	}
	
    func saveChanges(phrase: Phrase, module: Module, success: @escaping () -> Void) {
		guard !nativePhrase.isEmpty && !translatedPhrase.isEmpty else {
			shakeTextField()
			return
		}
		
		changeActivityState(toProccess: true)
		
		let dateFormatter = DateFormatter().getDateFormatter()
		let stringDate = dateFormatter.string(from: phrase.date ?? Date())
		
		let newPhrase: [String: Any] = [
			Constants.nativeText: nativePhrase,
			Constants.translatedText: translatedPhrase,
			Constants.date: stringDate,
			Constants.example: examplePhrase
		]
		
		let queue = DispatchQueue(label: "sytnik.wordy.updatePhrase")
		
		queue.async { [weak self] in
			guard let self = self else { return }
			NetworkManager.updatePhrase(
				newPhrase,
				with: phrase.id,
				from: module.id
			) { [weak self] in
				guard let self = self else { return }
//				NetworkManager.getModules { modules in
					self.changeActivityState(toProccess: false)
				//	self.modules = modules.filter{ $0.name.contains("\(self.searchedText)") }
//					self.modules = modules
					success()
//				} errorBlock: { errorText in
//					self.changeActivityState(toProccess: false)
//					self.alert.description = errorText
//					self.showAlertNow()
//				}
			} errorBlock: { [weak self] errorText in
				guard let self else { return }
				self.changeActivityState(toProccess: false)
				self.alert.description = errorText
				self.showAlertNow()
				return
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
	
	private func changeActivityState(toProccess: Bool) {
		withAnimation {
			if toProccess {
				self.isActivityProccess = true
			} else {
				self.isActivityProccess = false
			}
		}
	}
}
