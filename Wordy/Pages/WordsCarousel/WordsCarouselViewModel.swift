//
//  WordsCarouselViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 08.02.2023.
//

import Foundation
import SwiftUI

class WordsCarouselViewModel: ObservableObject {
	
	var index = 0
	@Published var selectedWordIndex = 0
	@Published var modules: [Module] = []
	@Published var showAlert = false
	@Published var showLearnPage = false
	
	var alert = (title: "Упс! Произошла ошибка...", description: "")
	
	var thisModule: Module {
		modules[index]
	}
	var phrases: [Phrase] {
		thisModule.phrases
	}
	var selectedPhrase: Phrase {
		phrases[selectedWordIndex]
	}
	
	func didTapShowLearnPage() {
		if thisModule.phrases.count < 4 {
			let wordsCountDifference = 4 - thisModule.phrases.count
			alert.title = "Для изучения слов необходимо минимум \n4 фразы"
			alert.description = "\nОсталось добавить еще \(getCorrectWord(value: wordsCountDifference))!"
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
}
