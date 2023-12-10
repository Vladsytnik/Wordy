//
//  OnboardingViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 11.05.2023.
//

import Foundation
import Combine
import SwiftUI

enum OnboardingScreenType {
	case languageSelection
	case onboardingOne
	case onboardingTwo
}

class SelectLanguageViewModel: ObservableObject {
	
	@Published var screenType = OnboardingScreenType.languageSelection
	@Published var nativeSelectedLanguage: Language?
	@Published var learnSelectedLanguage: Language?
	@Published var userCanContinue = false
	@Published var shakeContinueBtn = false
	@Published var showOnboardingPage = false
	@EnvironmentObject var router: Router
	
	@Published var showAlert = false
	var alert = (title: "Упс! Произошла ошибка...", description: "")
	
	private var cancellable = Set<AnyCancellable>()

	
	init() {
		nativeSelectedLanguage = UserDefaultsManager.nativeLanguage
		learnSelectedLanguage = UserDefaultsManager.learnLanguage
		checkNativeLanguageOnRepeat()
		checkLearnLanguageOnRepeat()
		checkThatLangWasSelected()
	}
	
	func goNext() {
		if userCanContinue {
			// показываем экран онбординг с видео (как пользоваться)
			UserDefaultsManager.nativeLanguage = nativeSelectedLanguage
			UserDefaultsManager.learnLanguage = learnSelectedLanguage
			switch screenType {
			case .languageSelection:
				withAnimation{
//					screenType = .onboardingOne
					showOnboardingPage = true
//					router.userIsAlreadyLaunched = true
				}
			case .onboardingOne:
				break
			case .onboardingTwo:
				break
			}
		} else {
            alert.title = "Вам нужно выбрать два языка".localize()
            alert.description = "Для продолжения, вам необходимо выбрать ваш родной язык и тот, который вы хотите изучать".localize()
			withAnimation {
				showAlert.toggle()
			}
		}
	}
	
	private func checkNativeLanguageOnRepeat() {
		$nativeSelectedLanguage
			.removeDuplicates()
			.sink{ nativeLang in
				guard nativeLang?.rawValue == self.learnSelectedLanguage?.rawValue else  { return }
				self.learnSelectedLanguage = nil
				self.userCanContinue = false
			}
			.store(in: &cancellable)
		$nativeSelectedLanguage
			.removeDuplicates()
			.sink{ nativeLang in
				let isNotTheSame = nativeLang?.rawValue != self.learnSelectedLanguage?.rawValue
				&& self.learnSelectedLanguage != nil
				self.userCanContinue = isNotTheSame
			}
			.store(in: &cancellable)
	}
	
	
	private func checkLearnLanguageOnRepeat() {
		$learnSelectedLanguage
			.removeDuplicates()
			.sink{ learnedLang in
				guard learnedLang?.rawValue == self.nativeSelectedLanguage?.rawValue else  { return }
				self.nativeSelectedLanguage = nil
				self.userCanContinue = false
			}
			.store(in: &cancellable)
		$learnSelectedLanguage
			.removeDuplicates()
			.sink{ learnedLang in
				let isNotTheSame = learnedLang?.rawValue != self.nativeSelectedLanguage?.rawValue
				&& self.nativeSelectedLanguage != nil
				self.userCanContinue = isNotTheSame
			}
			.store(in: &cancellable)
	}
	
	private func checkThatLangWasSelected() {
		$nativeSelectedLanguage
			.zip($learnSelectedLanguage)
			.sink { (val1, val2) in
				if val1 != nil && val2 != nil && val1 != val2 {
					self.shakeBtn()
				}
			}
			.store(in: &cancellable)
		$userCanContinue
			.sink { isTrue in
				if isTrue {
//					self.shakeBtn()
				}
			}
			.store(in: &cancellable)
	}
	
	private func shakeBtn() {
		let group = DispatchGroup()
		
		let workItem = DispatchWorkItem {
			withAnimation(.default.repeatCount(3, autoreverses: true).speed(6)) {
				self.shakeContinueBtn = true
			}
			group.leave()
		}
		
		group.enter()
		DispatchQueue.main.async(execute: workItem)
		
		group.notify(queue: .main) {
			self.shakeContinueBtn = false
		}
	}
}
