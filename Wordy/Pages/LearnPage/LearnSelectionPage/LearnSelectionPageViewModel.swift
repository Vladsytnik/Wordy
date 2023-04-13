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
		guard phrases.count > 0 else {
			needClosePage.toggle()
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
		buttonSelected[index].toggle()
	}
	
	private func getRandomQuestion() {
		guard module.phrases.count >= 4 else { return }
		guard phrases.count > 0 else {
			needClosePage.toggle()
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
		
		let correctAnswer = currentCorrectAnswer.getAnswer(answerType: answersLanguageType)
		let shuffledFullAnswers = (answersWithoutCorrect + [correctAnswer]).shuffled()
		indexOfCorrectButton = shuffledFullAnswers.firstIndex(where: { $0.lowercased() == correctAnswer.lowercased() } ) ?? -1
		currentAnswers = shuffledFullAnswers
	}
	
	private func userHasAnsweredCorrect(_ isCorrect: Bool) {
		if isCorrect {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				self.inputText = ""
				self.indexOfCorrectButton = -1
				self.currentCorrectAnswer = .init(nativeText: "", translatedText: "")
				self.buttonSelected = Array(repeating: false, count: 4)
				self.needRedraw = true
				self.needRedraw = false
			}
		}
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
		let trimmedPhrase1 = phrase1.trimmingCharacters(in: .whitespacesAndNewlines)
		let trimmedPhrase2 = phrase2.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if trimmedPhrase1.caseInsensitiveCompare(trimmedPhrase2) == .orderedSame {
			return true
		}
		
		let count1 = trimmedPhrase1.count
		let count2 = trimmedPhrase2.count
		let maxCount = max(count1, count2)
		let minCount = min(count1, count2)
		
		if maxCount - minCount > 1 {
			return false
		}
		
		// Алгоритм Левенштейна
		var matrix = Array(repeating: Array(repeating: 0, count: minCount + 1), count: maxCount + 1)
		
		for i in 0..<maxCount {
			for j in 0..<minCount {
				if i == 0 {
					matrix[i][j] = j
				} else if j == 0 {
					matrix[i][j] = i
				} else if trimmedPhrase1[trimmedPhrase1.index(trimmedPhrase1.startIndex, offsetBy: i - 1)] == trimmedPhrase2[trimmedPhrase2.index(trimmedPhrase2.startIndex, offsetBy: j - 1)] {
					matrix[i][j] = matrix[i - 1][j - 1]
				} else {
					matrix[i][j] = 1 + min(matrix[i][j - 1], matrix[i - 1][j], matrix[i - 1][j - 1])
				}
			}
		}
		
		return matrix[maxCount][minCount] <= 1
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
	}
}
