//
//  WordsCarouselViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 08.02.2023.
//

import Foundation
import SwiftUI
import AVKit

class WordsCarouselViewModel: ObservableObject {
	
	@Published var selectedWordIndex = 0
	@Published var showAlert = false
	@Published var showLearnPage = false
	@Published var showActivity = false
	@Published var isShowPaywall = false
    
    @Published var deletePhrase = false
    @Published var lastTappedPhraseIndexForDelete = 0
    
	
	let synthesizer = AVSpeechSynthesizer()
	
	var alert = (title: "Упс! Произошла ошибка...".localize(), description: "")
	
    var selectedPhrase: Phrase?
	
    func didTapShowLearnPage(module: Module) {
		if module.phrases.count < 4 {
			let wordsCountDifference = 4 - module.phrases.count
            alert.title = "Для изучения слов необходимо минимум \n4 фразы".localize()
			if Locale.current.languageCode == Language.ru.getLangCode() {
                alert.description = "\nОсталось добавить еще".localize() + " \(getCorrectWord(value: wordsCountDifference))!"
			} else {
                alert.description = "\nAdd a few more words".localize()
			}
			withAnimation {
				self.showAlert = true
			}
		}
	}
	
	func getCorrectWord(value: Int) -> String {
		if value == 1 {
			return "одну"
		} else if value == 2 {
			return "две"
		} else if value == 3 {
			return "три"
		} else {
			return "четыре"
		}
	}
	
    func didTapDeletePhrase(_ phrase: Phrase, module: Module) {
		self.showActivity = true
        self.deletePhrase = false
		NetworkManager.deletePhrase(
			with: phrase.id,
			moduleID: module.id
		) {
//				NetworkManager.getModules { modules in
					self.showActivity = false
//					self.modules = modules
//				} errorBlock: { errorText in
//					self.showActivity = false
//					self.alert.description = errorText
//					self.showActivity = false
//					self.showAlert = true
//				}
			} errorBlock: { errorText in
				self.alert.description = errorText
				self.showActivity = false
				self.showAlert = true
			}
	}
	
	func didTapSpeach(phrase: Phrase) {
		let wordForSpeach = phrase.getAnswer(answerType: .native)
		let langForSpeach = UserDefaultsManager.learnLanguage?.getLangCode() ?? "en-US"
		
		synthesizer.stopSpeaking(at: .immediate)
		
		let utterance = AVSpeechUtterance(string: "\(wordForSpeach)")
		utterance.voice = AVSpeechSynthesisVoice(language: langForSpeach)
		
		synthesizer.speak(utterance)
	}
	
    func checkSubscriptionAndAccessability(module: Module, isAllow: ((Bool) -> Void)) {
		let countOfStartingLearnMode = UserDefaultsManager.countOfStartingLearnModes[module.id] ?? 0
		isAllow(SubscriptionManager().userHasSubscription()
				|| countOfStartingLearnMode < maxCountOfStartingLearnMode)
	}
	
	func showPaywall() {
		isShowPaywall.toggle()
	}
}
