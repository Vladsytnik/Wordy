//
//  Phrase.swift
//  Wordy
//
//  Created by Vlad Sytnik on 14.01.2023.
//

import Foundation

struct Phrase: Equatable, Codable {
	let nativeText: String
	let translatedText: String
	let id: String
	
	var example: String?
	
	var date: Date?
}

extension Phrase {
	func getAnswer(answerType: BasicLanguageType) -> String {
		answerType == .translated ? translatedText : nativeText
	}
	
	func getQuestion(answerType: BasicLanguageType) -> String {
		answerType == .native ? translatedText : nativeText
	}
}
