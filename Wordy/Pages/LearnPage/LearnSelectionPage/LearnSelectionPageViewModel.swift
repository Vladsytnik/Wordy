//
//  LearnSelectionPageViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.04.2023.
//

import Foundation
import Combine

enum BasicLanguageType {
	case native
	case translated
}

enum LearnPageType: CaseIterable {
	case selectable
	case inputable
	
	static func random() -> Self {
		LearnPageType.allCases.randomElement() ?? .inputable
	}
}

class LearnSelectionPageViewModel: ObservableObject {
	
	@Published var module: Module = .init()
	@Published var currentCorrectAnswer: Phrase = .init(nativeText: "", translatedText: "")
	@Published var needRedraw = false
	
	@Published var answersCount = 4
	
	@Published var currentQuestion = ""
	@Published var currentAnswers = ["", "", "", ""]
//	@Published var currentPageType: LearnPageType = .random()
	@Published var currentPageType: LearnPageType = .inputable
	
	@Published var inputText = ""
	
	private var cancellables = Set<AnyCancellable>()
	
	private var phrases: [Phrase] = []
	private var answersLanguageType: BasicLanguageType = .native
	
	@Published var textFieldIsFirstResponder = true
	@Published var isAppeared = false
	@Published var needClosePage = false
	
	func start() {
		print("Start")
		currentPageType = .random()
		currentAnswers = Array(repeating: "nil", count: 4)
		currentQuestion = "nil"
		phrases = module.phrases
		
		getRandomQuestion()
		getAnswers()
		
		AnyPublisher($needRedraw)
			.sink { value in
				if value {
					self.updateUI()
				}
			}
			.store(in: &cancellables)
	}
	
	func userDidSelectAnswer(answer: String) {
		let correctAnswer = currentCorrectAnswer.getAnswer(answerType: answersLanguageType)
		userHasAnsweredCorrect(answer == correctAnswer)
		print("user tap \(answer), is correct: \(answer == correctAnswer)")
	}
	
	private func getRandomQuestion() {
		guard module.phrases.count >= 4 else { return }
		guard phrases.count > 0 else {
			print("Все слова прошли")
			return
		}
		var shuffledPhrases = phrases.shuffled()
		let removed = shuffledPhrases.removeFirst()
		phrases = shuffledPhrases
		currentCorrectAnswer = removed
		currentQuestion = removed.getQuestion(answerType: answersLanguageType)
	}
	
	private func getAnswers() {
		guard module.phrases.count >= 4 else {
			return
		}
		
		let tempArray = module.phrases.filter{
			$0.getAnswer(answerType: answersLanguageType) != currentCorrectAnswer.getAnswer(answerType: answersLanguageType)
		}
		let answersWithoutCorrect = [
			tempArray[0],
			tempArray[1],
			tempArray[2]
		].map{ $0.getAnswer(answerType: answersLanguageType) }
		
		print("Массив без правильного ответа: \(answersWithoutCorrect)")
		print("Правильный ответ: \(currentCorrectAnswer.nativeText)")
		let correctAnswer = currentCorrectAnswer.getAnswer(answerType: answersLanguageType)
		let shuffledFullAnswers = (answersWithoutCorrect + [correctAnswer]).shuffled()
		
		currentAnswers = shuffledFullAnswers
		print("Массив с правильным ответом: \(currentAnswers)")
	}
	
	private func userHasAnsweredCorrect(_ isCorrect: Bool) {
		if isCorrect {
			needRedraw = true
			inputText = ""
		}
	}
	
	private func updateUI() {
		getRandomQuestion()
		getAnswers()
		currentPageType = .random()
		needRedraw = false
	}
}
