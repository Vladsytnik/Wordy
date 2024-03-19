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

let maxCountOfStartingLearnMode = AppValues.shared.learningModeCountForFree

class ModuleScreenViewModel: ObservableObject {
	
	@Published var showAlert = false
	@Published var words: [String] = []
	@Published var showActionSheet = false
	@Published var showWordsCarousel = false
	@Published var thisModuleSuccessfullyDeleted = false
	@Published var showActivity = false
	@Published var showDeletingErrorAlert = false
    @Published var showOkAlert = false
	@Published var showErrorAboutPhraseCount = false
	@Published var isShowPaywall = false
	
	@Published var showEditPhrasePage = false
	@Published var phraseIndexForEdit = 0
	
	let synthesizer = AVSpeechSynthesizer()
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
	
	var selectedWordIndex = 0
	var alert = (title: "Упс! Произошла ошибка...".localize(), description: "")
	
//    @Published var module: Module = .init()
	
    func getShareUrl(module: Module) -> URL {
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
    
    func setToModuleTeacherMode(module: Module, successCallback: (() -> Void)?) {
        guard subscriptionManager.isUserHasSubscription else {
            return
        }
        
        Task { @MainActor in
            do {
               let isSuccess = try await NetworkManager.setTeacherModeToModule(id: module.id)
                if isSuccess {
                    successCallback?()
                } 
//                else {
//                    alert.description = "Попробуйте еще раз"
//                    withAnimation {
//                        self.showOkAlert = true
//                    }
//                }
//                self.showActivity = false
            } catch (let error) {
                print("Error in ModuleScreenViewModel -> setToModuleTeacherMode: \(error.localizedDescription)")
//                self.showActivity = false
            }
        }
    }
	
	func didTapWord(with index: Int) {
		selectedWordIndex = index
		showWordsCarousel.toggle()
	}
	
	func nowReallyNeedToDeleteModule(module: Module) {
		showActivity = true
		NetworkManager.deleteModule(with: module.id) { [weak self] in
			guard let self = self else { return }
			self.showActivity = false
			self.thisModuleSuccessfullyDeleted = true
		} errorBlock: { [weak self] errorText in
			guard let self = self else { return }
			self.alert.description = errorText
			self.showActivity = false
			self.showDeletingErrorAlert = true
		}

	}
	
    func didTapDeletePhrase(module: Module, phrase: Phrase) {
		self.showActivity = true
		NetworkManager.deletePhrase(
			with: phrase.id,
			moduleID: module.id) {
//				NetworkManager.getModules { modules in
					self.showActivity = false
//					self.modules = modules
//				} errorBlock: { errorText in
//					self.showActivity = false
//					self.alert.description = errorText
//					self.showActivity = false
//					self.showDeletingErrorAlert = true
//				}
			} errorBlock: { errorText in
				self.alert.description = errorText
				self.showActivity = false
				self.showDeletingErrorAlert = true
			}
	}
	
	func didTapPhraseCountAlert(module: Module) {
		if module.phrases.count < 4 {
			let wordsCountDifference = 4 - module.phrases.count
            alert.title = "Для изучения слов необходимо минимум \n4 фразы".localize()
			if Locale.current.languageCode == Language.ru.getLangCode() {
                alert.description = "\nОсталось добавить еще".localize() + " \(getCorrectWord(value: wordsCountDifference))!"
			} else {
                alert.description = "\nAdd a few more words".localize()
			}
			withAnimation {
				self.showErrorAboutPhraseCount = true
			}
		}
	}
	
	func checkSubscriptionAndAccessability(module: Module, isAllow: ((Bool) -> Void)) {
		let countOfStartingLearnMode =  UserDefaultsManager.countOfStartingLearnModes[module.id] ?? 0
		isAllow(subscriptionManager.isUserHasSubscription
				|| (countOfStartingLearnMode < maxCountOfStartingLearnMode
                    && !module.isBlockedFreeFeatures)
                || module.acceptedAsStudent)
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
	
    func didTapSpeach(phrase: Phrase) {
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
