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
	
	var themeManager = ThemeManager()
	@Published var module: Module = .init()
	@Published var currentCorrectAnswer: Phrase = .init(nativeText: "", translatedText: "", id: "")
	@Published var needRedraw = false
	
	@Published var answersCount = 4
	
	@Published var currentQuestion = ""
	@Published var currentAnswers = ["", "", "", ""]
	//	@Published var currentPageType: LearnPageType = .random()
	@Published var currentPageType: LearnPageType = .inputable
	
	@Published var inputText = ""
	
	private var cancellables = Set<AnyCancellable>()
	
	private var phrases: [Phrase] = []
	var answersLanguageType: BasicLanguageType = .native
	
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
	
	@Published var showDifferenceInFailure = false
	@Published var originalAttributedPhrase: AttributedString = .init(stringLiteral: "Test")
	@Published var answeredAttributedPhrase: AttributedString = .init(stringLiteral: "Test")
	
	@Published var currentUserAnswer = ""
	
	var flowCanContinue: (() -> Void)?
	
	private var sucessGenerator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .soft)
	private var failedGenerator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .heavy)
	
	func start() {
		print("Start")
		showDifferenceInFailure = false
		currentPageType = .inputable
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
		
		currentUserAnswer = answer
		let correctAnswer = currentCorrectAnswer.getAnswer(answerType: answersLanguageType)
		var phrasesAreEqualed = answer == correctAnswer
		if currentPageType == .inputable {
			phrasesAreEqualed = comparePhrases(answer, correctAnswer)
		}
		
		if !phrasesAreEqualed && currentPageType == .inputable {
			answeredAttributedPhrase = highlightDifferences2(original: correctAnswer, answer: answer)
//			differenceText = AttributedString(stringLiteral: "Правильный ответ: ")
//			differenceText.append(highlightDifferences(original: correctAnswer, answer: answer))
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
		
		if !isCorrect && currentPageType == .inputable {
			self.showDifferenceInFailure = true
			self.flowCanContinue = {
				self.showDifferenceInFailure = false
				self.resetDataAndRedrawUI(isCorrect: isCorrect)
			}
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
				self.showDifferenceInFailure = false
				self.resetDataAndRedrawUI(isCorrect: isCorrect)
			}
		}
	}
	
	private func resetDataAndRedrawUI(isCorrect: Bool) {
		self.inputTextAnsweredType = .notSelected
		if !isCorrect {
			self.phrases.append(self.currentCorrectAnswer)
		}
		self.inputText = ""
		self.indexOfCorrectButton = -1
		self.textFieldPLaceholder = "Введите ваш ответ"
		self.currentCorrectAnswer = .init(nativeText: "", translatedText: "", id: "")
		self.buttonSelected = Array(repeating: false, count: 4)
		
		if self.phrases.count > 0 {
			self.needRedraw = true
			self.needRedraw = false
		} else {
			self.showCongratulationAndClose()
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
	
	private func comparePhrases(_ phrase1: String, _ phrase2: String, maxDistance: Int = 0) -> Bool {
		
		var firstString = phrase1
		var secondString = phrase2
		let trimWhiteSpacesAndNewLines = true
		let ignoreCase = true
		
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
		inputTextAnsweredType = .notSelected
		showDifferenceInFailure = false
		isAppeared = false
		inputText = ""
		currentCorrectAnswer = .init(nativeText: "", translatedText: "", id: "")
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
	
	func highlightDifferences2(original: String, answer response: String, attr: NSMutableAttributedString? = nil ) -> AttributedString {
		var result = attr == nil ? NSMutableAttributedString() : attr!
		originalAttributedPhrase = AttributedString(stringLiteral: original)
		
		// Устанавливаем атрибуты
		let regularAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: themeManager.currentTheme.mainText
		]
		
		let highlightAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.red
		]
		
		// Максимальная длина
		let originalWords = original.components(separatedBy: " ")
		let responseWords = response.components(separatedBy: " ")
		
		let maxCount = max(originalWords.count, responseWords.count)
		
		if responseWords.count == originalWords.count {
			for index in 0..<maxCount {
				var originalWord = ""
				var responseWord = ""
				
				if index < originalWords.count {
					originalWord = originalWords[index]
				}
				
				if index < responseWords.count {
					responseWord = responseWords[index]
				}
				
				var isMainPartOfWordIsTheSame = true
				
				for charIndex in 0..<max(maxCount, originalWord.count, responseWord.count) {
					var attributes = regularAttributes
					
					if charIndex < originalWord.count, charIndex < responseWord.count {
						let originalIndex = originalWord.index(originalWord.startIndex, offsetBy: charIndex)
						let responseIndex = responseWord.index(responseWord.startIndex, offsetBy: charIndex)
						
						let originalChar = originalWord[originalIndex]
						let responseChar = responseWord[responseIndex]
						
						if originalChar.lowercased() != responseChar.lowercased()
						//						|| responseWord.count > originalWord.count
						{
							attributes = highlightAttributes
						}
						
						if originalChar.lowercased() != responseChar.lowercased() {
							isMainPartOfWordIsTheSame = false
						}
						
						let attributedChar = NSAttributedString(string: String(responseChar), attributes: attributes)
						result.append(attributedChar)
					} else if charIndex < responseWord.count {
						let originalIndex = responseWord.index(responseWord.startIndex, offsetBy: charIndex)
						let originalChar = responseWord[originalIndex]
						
						let attributedChar = NSAttributedString(string: String(originalChar), attributes: highlightAttributes)
						result.append(attributedChar)
					} else if charIndex < originalWord.count {
						// эта часть добавляет в конец слова часть ответа
						
						if isMainPartOfWordIsTheSame {
							// если в ответ входит полностью слово, но еще есть после него что-то
							// то мы выделяем лишь оставшуюся часть
							let responseIndex = originalWord.index(originalWord.startIndex, offsetBy: charIndex)
							let responseChar = originalWord[responseIndex]
							
							let attributedChar = NSAttributedString(string: String(responseChar), attributes: highlightAttributes)
							result.append(attributedChar)
						} else {
							// инчае мы выделяем красным все слово
							//							let responseIndex = originalWord.index(originalWord.index(originalWord.startIndex, offsetBy: charIndex), offsetBy: originalWord.count - 1 - charIndex)
							//							let responseChar = originalWord[responseIndex]
							//							let attributedChar = NSAttributedString(string: String(responseChar), attributes: highlightAttributes)
							//							result.append(attributedChar)
							
							//							let newResult = result
							//							for charIndex2 in 0..<originalWord.count {
							//								let originalIndex = originalWord.index(originalWord.startIndex, offsetBy: charIndex2)
							//								let originalChar = originalWord[originalIndex]
							//								let attributedChar = NSAttributedString(string: String(originalChar), attributes: highlightAttributes)
							//								newResult.append(attributedChar)
							//							}
							//							result = newResult
						}
					}
				}
				
				// Add a space between words
				if index != maxCount - 1 {
					let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
					result.append(attributedSpace)
				}
			}
		} else if originalWords.count < responseWords.count {
			// если в ответе меньше слов чем должно быть
			//			var newResult = NSMutableAttributedString()
			var notLastDifference = false
			var diffWords: [String] = findMissingWords(response, original)
			
			//			var index = 0
			//			for word in originalWords {
			//				if index < responseWords.count, responseWords[index] != word {
			//					diffWords.append(word)
			//				} else if index < responseWords.count, responseWords[index] == word {
			//					index += 1
			//				}
			//			}
			
			for word in responseWords {
				if diffWords.contains(where: { $0 == word }) {
					let attributed = NSAttributedString(string: word, attributes: highlightAttributes)
					result.append(attributed)
					let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
					result.append(attributedSpace)
				} else {
					let attributed = NSAttributedString(string: word)
					result.append(attributed)
					let attributedSpace = NSAttributedString(string: " ")
					result.append(attributedSpace)
				}
			}
			
			//			for (responseWord, origWord) in zip(responseWords, originalWords) {
			//				if responseWord != origWord {
			//					let attributed = NSAttributedString(string: responseWord, attributes: highlightAttributes)
			//					result.append(attributed)
			//					notLastDifference = true
			//				} else {
			//					let attributed = NSAttributedString(string: responseWord)
			//					result.append(attributed)
			//				}
			//				let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
			//				result.append(attributedSpace)
			//			}
			//
			//			if !notLastDifference {
			//				let attributed = NSAttributedString(string: originalWords.last ?? "", attributes: highlightAttributes)
			//				result.append(attributed)
			//			}
		} else {
			// если в ответе больше слов, чем должно быть, то просто выделяем красным лишние слова в ответе
			
			var answeredAttributedResult = NSMutableAttributedString()
			let diffWords: [String] = findMissingWords(response, original)
			
			for word in responseWords {
				if diffWords.contains(where: { getDistance($0, word) > 3 }) {
					// если слово отличается больше чем на 3 буквы, то
					// выделяем его полностью красным
					let attributed = NSAttributedString(string: word, attributes: highlightAttributes)
					answeredAttributedResult.append(attributed)
					let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
					answeredAttributedResult.append(attributedSpace)
				} else {
					let attributed = NSAttributedString(string: word)
					answeredAttributedResult.append(attributed)
					let attributedSpace = NSAttributedString(string: " ")
					answeredAttributedResult.append(attributedSpace)
				}
			}
			
			self.answeredAttributedPhrase = AttributedString(answeredAttributedResult)
			
			// аттрибутируем ориг фразу
			
			for index in 0..<originalWords.count {
				var originalWord = ""
				originalWord = originalWords[index]
				
				for charIndex in 0..<originalWord.count {
					let originalIndex = originalWord.index(originalWord.startIndex, offsetBy: charIndex)
					let originalChar = originalWord[originalIndex]
					//					let attributedChar = NSAttributedString(string: String(originalChar), attributes: highlightAttributes)
					let attributedChar = NSAttributedString(string: String(originalChar))
					result.append(attributedChar)
				}
			}
		}
		
		return AttributedString(result)
	}
	
	func highlightWords(original: String, response: String) -> NSMutableAttributedString {
		// Создаем NSMutableAttributedString
		let result = NSMutableAttributedString()
		
		// Устанавливаем атрибуты
		let regularAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.black,
			.font: UIFont.systemFont(ofSize: 14)
		]
		
		let highlightAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.red,
			.font: UIFont.systemFont(ofSize: 14)
		]
		
		// Максимальная длина
		let maxCount = max(original.count, response.count)
		
		for index in 0..<maxCount {
			var attributes = regularAttributes
			
			if index < original.count, index < response.count {
				let originalIndex = original.index(original.startIndex, offsetBy: index)
				let responseIndex = response.index(response.startIndex, offsetBy: index)
				
				let originalChar = original[originalIndex]
				let responseChar = response[responseIndex]
				
				// Если символы не совпадают, выделяем его
				if originalChar != responseChar {
					attributes = highlightAttributes
				}
				
				let attributedChar = NSAttributedString(string: String(originalChar), attributes: attributes)
				result.append(attributedChar)
			} else if index < original.count {
				// Если символ есть только в оригинальной строке
				let originalIndex = original.index(original.startIndex, offsetBy: index)
				let originalChar = original[originalIndex]
				
				let attributedChar = NSAttributedString(string: String(originalChar), attributes: highlightAttributes)
				result.append(attributedChar)
			} else if index < response.count {
				// Если символ есть только в строке ответа пользователя
				let responseIndex = response.index(response.startIndex, offsetBy: index)
				let responseChar = response[responseIndex]
				
				let attributedChar = NSAttributedString(string: String(responseChar), attributes: highlightAttributes)
				result.append(attributedChar)
			}
		}
		
		return result
	}

	
	func highlightDifferences(original: String, answer response: String) -> AttributedString {
		var result = NSMutableAttributedString()
		answeredAttributedPhrase = AttributedString(stringLiteral: response)
		
		// Устанавливаем атрибуты
		let regularAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: themeManager.currentTheme.mainText
		]
		
		let highlightAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.red
		]
		
		// Максимальная длина
		let originalWords = original.components(separatedBy: " ")
		let responseWords = response.components(separatedBy: " ")
		
		let maxCount = max(originalWords.count, responseWords.count)
		
		if responseWords.count == originalWords.count {
			for index in 0..<maxCount {
				var originalWord = ""
				var responseWord = ""
				
				if index < originalWords.count {
					originalWord = originalWords[index]
				}
				
				if index < responseWords.count {
					responseWord = responseWords[index]
				}
				
				var isMainPartOfWordIsTheSame = true
				
				for charIndex in 0..<max(maxCount, originalWord.count, responseWord.count) {
					var attributes = regularAttributes
					
					if charIndex < originalWord.count, charIndex < responseWord.count {
						let originalIndex = originalWord.index(originalWord.startIndex, offsetBy: charIndex)
						let responseIndex = responseWord.index(responseWord.startIndex, offsetBy: charIndex)
						
						let originalChar = originalWord[originalIndex]
						let responseChar = responseWord[responseIndex]
						
						if originalChar.lowercased() != responseChar.lowercased()
						//						|| responseWord.count > originalWord.count
						{
							attributes = highlightAttributes
						}
						
						if originalChar.lowercased() != responseChar.lowercased() {
							isMainPartOfWordIsTheSame = false
						}
						
						let attributedChar = NSAttributedString(string: String(originalChar), attributes: attributes)
						result.append(attributedChar)
					} else if charIndex < originalWord.count {
						let originalIndex = originalWord.index(originalWord.startIndex, offsetBy: charIndex)
						let originalChar = originalWord[originalIndex]
						
						let attributedChar = NSAttributedString(string: String(originalChar), attributes: highlightAttributes)
						result.append(attributedChar)
					} else if charIndex < responseWord.count {
						// эта часть добавляет в конец слова часть ответа
						
						if isMainPartOfWordIsTheSame {
							// если в ответ входит полностью слово, но еще есть после него что-то
							// то мы выделяем лишь оставшуюся часть
							let responseIndex = responseWord.index(responseWord.startIndex, offsetBy: charIndex)
							let responseChar = responseWord[responseIndex]
							
							let attributedChar = NSAttributedString(string: String(responseChar), attributes: highlightAttributes)
							result.append(attributedChar)
						} else {
							// инчае мы выделяем красным все слово
//							let responseIndex = originalWord.index(originalWord.index(originalWord.startIndex, offsetBy: charIndex), offsetBy: originalWord.count - 1 - charIndex)
//							let responseChar = originalWord[responseIndex]
//							let attributedChar = NSAttributedString(string: String(responseChar), attributes: highlightAttributes)
//							result.append(attributedChar)
							
//							let newResult = result
//							for charIndex2 in 0..<originalWord.count {
//								let originalIndex = originalWord.index(originalWord.startIndex, offsetBy: charIndex2)
//								let originalChar = originalWord[originalIndex]
//								let attributedChar = NSAttributedString(string: String(originalChar), attributes: highlightAttributes)
//								newResult.append(attributedChar)
//							}
//							result = newResult
						}
					}
				}
				
				// Add a space between words
				if index != maxCount - 1 {
					let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
					result.append(attributedSpace)
				}
			}
		} else if responseWords.count < originalWords.count {
			// если в ответе меньше слов чем должно быть
//			var newResult = NSMutableAttributedString()
			var notLastDifference = false
			var diffWords: [String] = findMissingWords(original, response)
			
//			var index = 0
//			for word in originalWords {
//				if index < responseWords.count, responseWords[index] != word {
//					diffWords.append(word)
//				} else if index < responseWords.count, responseWords[index] == word {
//					index += 1
//				}
//			}
			
			for word in originalWords {
				if diffWords.contains(where: { $0 == word }) {
					let attributed = NSAttributedString(string: word, attributes: highlightAttributes)
					result.append(attributed)
					let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
					result.append(attributedSpace)
				} else {
					let attributed = NSAttributedString(string: word)
					result.append(attributed)
					let attributedSpace = NSAttributedString(string: " ")
					result.append(attributedSpace)
				}
			}
			
//			for (responseWord, origWord) in zip(responseWords, originalWords) {
//				if responseWord != origWord {
//					let attributed = NSAttributedString(string: responseWord, attributes: highlightAttributes)
//					result.append(attributed)
//					notLastDifference = true
//				} else {
//					let attributed = NSAttributedString(string: responseWord)
//					result.append(attributed)
//				}
//				let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
//				result.append(attributedSpace)
//			}
//
//			if !notLastDifference {
//				let attributed = NSAttributedString(string: originalWords.last ?? "", attributes: highlightAttributes)
//				result.append(attributed)
//			}
		} else {
			// если в ответе больше слов, чем должно быть, то просто выделяем красным лишние слова в ответе
			
			var answeredAttributedResult = NSMutableAttributedString()
			let diffWords: [String] = findMissingWords(response, original)
			
			for word in responseWords {
				if diffWords.contains(where: { $0 == word }) {
					let attributed = NSAttributedString(string: word, attributes: highlightAttributes)
					answeredAttributedResult.append(attributed)
					let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
					answeredAttributedResult.append(attributedSpace)
				} else {
					let attributed = NSAttributedString(string: word)
					answeredAttributedResult.append(attributed)
					let attributedSpace = NSAttributedString(string: " ")
					answeredAttributedResult.append(attributedSpace)
				}
			}
			
			self.answeredAttributedPhrase = AttributedString(answeredAttributedResult)
			
			// аттрибутируем ориг фразу
			
			for index in 0..<originalWords.count {
				var originalWord = ""
				originalWord = originalWords[index]

				for charIndex in 0..<originalWord.count {
					let originalIndex = originalWord.index(originalWord.startIndex, offsetBy: charIndex)
					let originalChar = originalWord[originalIndex]
//					let attributedChar = NSAttributedString(string: String(originalChar), attributes: highlightAttributes)
					let attributedChar = NSAttributedString(string: String(originalChar))
					result.append(attributedChar)
				}
			}
		}
		
		return AttributedString(result)

		
		/*
		let result = NSMutableAttributedString()
		
		let regularAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: themeManager.currentTheme.mainText
		]
		
		let highlightAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.red,
			.font: UIFont.systemFont(ofSize: 14)
		]
		
		let originalWords = original.components(separatedBy: " ")
		let responseWords = response.components(separatedBy: " ")
		
		let maxCount = max(originalWords.count, responseWords.count)
		
		for index in 0..<maxCount {
			var originalWord = ""
			var responseWord = ""
			
			if index < originalWords.count {
				originalWord = originalWords[index]
			}
			
			if index < responseWords.count {
				responseWord = responseWords[index]
			}
			
			if originalWord == responseWord {
				let attributedWord = NSAttributedString(string: originalWord, attributes: regularAttributes)
				result.append(attributedWord)
			} else {
				let attributedWord = NSAttributedString(string: originalWord, attributes: highlightAttributes)
				result.append(attributedWord)
			}
			
			if index != maxCount - 1 {
				let attributedSpace = NSAttributedString(string: " ", attributes: regularAttributes)
				result.append(attributedSpace)
			}
		}
		
		return AttributedString(result)
*/
	}
	
	func findMissingWords(_ firstString: String, _ secondString: String) -> [String] {
		// Преобразуйте вторую строку в нижний регистр и разделите ее на слова
		let secondWordsLowercased = secondString.lowercased()
		let secondWords = secondWordsLowercased.components(separatedBy: CharacterSet.alphanumerics.inverted)
			.filter { !$0.isEmpty }
		
		// Разделите первую строку на слова
		let firstWords = firstString.components(separatedBy: CharacterSet.alphanumerics.inverted)
			.filter { !$0.isEmpty }
		
		// Создайте множества для быстрого поиска
		let secondWordsSet = Set(secondWords)
		
		// Найдите слова, которые есть в первой строке (с учетом регистра), но отсутствуют во второй
		let missingWords = firstWords.filter { word in
			let wordLowercased = word.lowercased()
			return !secondWordsSet.contains(wordLowercased)
		}
		
		return missingWords
	}
	
	private func getDistance(_ phrase1: String, _ phrase2: String) -> Int {
		
		var firstString = phrase1
		var secondString = phrase2
		let trimWhiteSpacesAndNewLines = true
		let ignoreCase = true
		
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
			return validDistance
		}
		
		assertionFailure()
		return Int.max
	}
}
