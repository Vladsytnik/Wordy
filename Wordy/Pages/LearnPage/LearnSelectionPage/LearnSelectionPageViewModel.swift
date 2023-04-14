//
//  LearnSelectionPageViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.04.2023.
//

import Foundation
import Combine
import SwiftUI

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

enum InputAnswerType {
	case notSelected
	case uncorrect
	case correct
}

class LearnSelectionPageViewModel: ObservableObject {
	
	@Published var module: Module = .init()
	@Published var currentCorrectAnswer: Phrase = .init(nativeText: "", translatedText: "")
	@Published var needRedraw = false
	
	@Published var answersCount = 4
	
	@Published var currentQuestion = ""
	@Published var currentAnswers = ["", "", "", ""]
	//	@Published var currentPageType: LearnPageType = .random()
	@Published var currentPageType: LearnPageType = .selectable
	
	@Published var inputText = ""
	
	private var cancellables = Set<AnyCancellable>()
	
	private var phrases: [Phrase] = []
	private var answersLanguageType: BasicLanguageType = .native
	
	@Published var textFieldIsFirstResponder = true
	@Published var isAppeared = false
	@Published var needClosePage = false
	@Published var buttonSelected: [Bool] = [false, false, false, false]
	@Published var indexOfCorrectButton = -1
	@Published var needOpenTextField = false
	@Published var inputTextAnsweredType: InputAnswerType = .notSelected
	
	@Published var showSuccessAnimation = false
	@Published var learningIsFinished = false
	
	@Published var textFieldPLaceholder = "Введите ваш ответ"
	
	private var sucessGenerator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .soft)
	private var failedGenerator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .heavy)
	
	func start() {
		print("Start")
		currentPageType = .selectable
		buttonSelected = Array(repeating: false, count: 4)
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
		guard isNotSelectedAnyButtonYet() else {
			return
		}
		
		let correctAnswer = currentCorrectAnswer.getAnswer(answerType: answersLanguageType)
		var phrasesAreEqualed = answer == correctAnswer
		if currentPageType == .inputable {
			phrasesAreEqualed = comparePhrases(answer, correctAnswer)
		}
		userHasAnsweredCorrect(phrasesAreEqualed)
		print("user tap \(answer), is correct: \(phrasesAreEqualed)")
	}
	
	func didTapButton(index: Int) {
		guard isNotSelectedAnyButtonYet() else {
			return
		}
		buttonSelected[index].toggle()
	}
	
	func userDoesntKnow() {
		textFieldPLaceholder = currentCorrectAnswer.getAnswer(answerType: answersLanguageType)
	}
	
	private func getRandomQuestion() {
		print("Phrases count: \(phrases.count)")
		guard module.phrases.count >= 4 else { return }
		
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
		
		let correctAnswer = currentCorrectAnswer.getAnswer(answerType: answersLanguageType)
		let shuffledFullAnswers = (answersWithoutCorrect + [correctAnswer]).shuffled()
		indexOfCorrectButton = shuffledFullAnswers.firstIndex(where: { $0.lowercased() == correctAnswer.lowercased() } ) ?? -1
		currentAnswers = shuffledFullAnswers
	}
	
	private func userHasAnsweredCorrect(_ isCorrect: Bool) {
		if isCorrect {
			sucessGenerator?.impactOccurred()
			showSuccessAnimation = true
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.showSuccessAnimation = false
			}
		} else {
			failedGenerator?.impactOccurred()
		}
		
		inputTextAnsweredType = isCorrect ? .correct : .uncorrect
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
			self.inputTextAnsweredType = .notSelected
			if !isCorrect {
				self.phrases.append(self.currentCorrectAnswer)
			}
			self.inputText = ""
			self.indexOfCorrectButton = -1
			self.textFieldPLaceholder = "Введите ваш ответ"
			self.currentCorrectAnswer = .init(nativeText: "", translatedText: "")
			self.buttonSelected = Array(repeating: false, count: 4)
			
			if self.phrases.count > 0 {
				self.needRedraw = true
				self.needRedraw = false
			} else {
				self.showCongratulationAndClose()
			}
		}
	}
	
	private func showCongratulationAndClose() {
		Vibration.success.vibrate()
		learningIsFinished = true
	}
	
	private func updateUI() {
		getRandomQuestion()
		getAnswers()
		currentPageType = .random()
		if currentPageType == .inputable {
			needOpenTextField.toggle()
		}
	}
	
	private func comparePhrases(_ phrase1: String, _ phrase2: String) -> Bool {
		
		var firstString = phrase1
		var secondString = phrase2
		let trimWhiteSpacesAndNewLines = true
		let ignoreCase = true
		let maxDistance = 1
		
		if ignoreCase {
			firstString = firstString.lowercased()
			secondString = secondString.lowercased()
		}
		
		if trimWhiteSpacesAndNewLines {
			firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
			secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
		}
		
		let empty = [Int](repeating: 0, count: secondString.count)
		var last = [Int](0...secondString.count)
		
		for (i, tLett) in firstString.enumerated() {
			var cur = [i + 1] + empty
			for (j, sLett) in secondString.enumerated() {
				cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
			}
			
			last = cur
		}
		
		if let validDistance = last.last {
			return validDistance <= maxDistance
		}
		
		assertionFailure()
		return true
	}
	
	func clearAllProperties() {
		isAppeared = false
		inputText = ""
		currentCorrectAnswer = .init(nativeText: "", translatedText: "")
		needRedraw = false
		phrases = module.phrases
		buttonSelected = Array(repeating: false, count: 4)
		currentAnswers = Array(repeating: "nil", count: 4)
		currentQuestion = "nil"
		indexOfCorrectButton = -1
		cancellables.forEach { $0.cancel() }
		learningIsFinished = false
	}
	
	private func isNotSelectedAnyButtonYet() -> Bool {
		!buttonSelected.reduce(false, { $0 || $1 })
	}
}
