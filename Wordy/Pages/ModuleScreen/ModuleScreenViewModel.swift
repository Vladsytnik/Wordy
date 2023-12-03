//
//  ModuleScreenViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import SwiftUI
import AVKit
import ApphudSDK
import FirebaseAuth

let maxCountOfStartingLearnMode = 3

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
	@Published var showErrorAboutPhraseCount = false
	@Published var isShowPaywall = false
	
	@Published var showEditPhrasePage = false
	@Published var phraseIndexForEdit = 0
	
	let synthesizer = AVSpeechSynthesizer()
	
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
	
	func getShareUrl() -> URL {
		guard let userID = Auth.auth().currentUser?.uid else {
			return URL(string: "https://4475302.redirect.appmetrica.yandex.com/")!
		}
		return URL(string: "https://4475302.redirect.appmetrica.yandex.com/\(userID)/\(module.id)")!
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
	
	func didTapDeletePhrase(with index: Int) {
		let phrase = phrases[index]
		self.showActivity = true
		NetworkManager.deletePhrase(
			with: phrase.id,
			moduleID: module.id) {
				NetworkManager.getModules { modules in
					self.showActivity = false
					self.modules = modules
				} errorBlock: { errorText in
					self.showActivity = false
					self.alert.description = errorText
					self.showActivity = false
					self.showErrorAlert = true
				}
			} errorBlock: { errorText in
				self.alert.description = errorText
				self.showActivity = false
				self.showErrorAlert = true
			}
	}
	
	func didTapPhraseCountAlert() {
		if module.phrases.count < 4 {
			let wordsCountDifference = 4 - module.phrases.count
			alert.title = "Для изучения слов необходимо минимум \n4 фразы"
			if Locale.current.languageCode == Language.ru.getLangCode() {
				alert.description = "\nОсталось добавить еще \(getCorrectWord(value: wordsCountDifference))!"
			} else {
				alert.description = "\nAdd a few more words"
			}
			withAnimation {
				self.showErrorAboutPhraseCount = true
			}
		}
	}
	
	func checkSubscriptionAndAccessability(isAllow: ((Bool) -> Void)) {
		let countOfStartingLearnMode =  UserDefaultsManager.countOfStartingLearnModes[module.id] ?? 0
//		isAllow(UserDefaultsManager.userHasSubscription
//				|| countOfStartingLearnMode < maxCountOfStartingLearnMode)
		let subscriptionManager = SubscriptionManager()
		let test = subscriptionManager.userHasSubscription()
//		let test2 = subscriptionManager.hasActiveSubscription
		isAllow(subscriptionManager.userHasSubscription()
				|| countOfStartingLearnMode < maxCountOfStartingLearnMode)
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
	
	func didTapAddExample(index: Int) {
		phraseIndexForEdit = index
		print(index)
		showEditPhrasePage.toggle()
	}
	
	func didTapSpeach(index: Int) {
		let phrase = phrases[index]
		let wordForSpeach = phrase.getAnswer(answerType: .native)
        let langForSpeach = UserDefaultsManager.learnLanguage?.getLangCode() ?? "en-US"

		synthesizer.stopSpeaking(at: .immediate)
		
		let utterance = AVSpeechUtterance(string: "\(wordForSpeach)")
		utterance.voice = AVSpeechSynthesisVoice(language: langForSpeach)
        utterance.rate = 0.4
		
		synthesizer.speak(utterance)
	}
	
	func showPaywall() {
		isShowPaywall.toggle()
	}
    
    func userDidntSeeLearnBtnYet() -> Bool {
        !UserDefaultsManager.isUserSawLearnButton
    }
    
    func userDidntSeeCreatePhrase() -> Bool {
        !UserDefaultsManager.isUserSawCreateNewPhrase
    }
}
