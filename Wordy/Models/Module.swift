//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 27.12.2022.
//

import Foundation

struct Module: Equatable {
	var name: String = ""
	var emoji: String = ""
	var id: String = ""
	var date: Date?
	
	var phrases: [Phrase] = []
}

extension Module {
	func getPhrasesAsDictionary() -> [[String: Any]] {
		var dictArray: [[String: Any]] = [[:]]
		
		for phrase in phrases {
			dictArray.append([
				Constants.nativeText : phrase.nativeText,
				Constants.translatedText : phrase.translatedText,
				Constants.date: phrase.date as Any
			])
//			dict[phrase.nativeText] = phrase.translatedText
		}
		
		return dictArray
	}
}
