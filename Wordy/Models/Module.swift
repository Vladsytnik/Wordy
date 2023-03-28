//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 27.12.2022.
//

import Foundation
import FirebaseDatabase

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
				Constants.date: String().generateDate(from: phrase.date) as Any
			])
		}
		
		return dictArray
	}
	
	static func parse(from snapshot: DataSnapshot) -> [Module]? {
		guard let data = (snapshot.value as? [String: [String: Any]]) else {
			return nil
		}
		guard let dbModuleKeys = (snapshot.value as? [String: Any])?.keys else {
			return nil
		}
		
		var modules: [Module] = []
		
		for moduleID in dbModuleKeys {
			var module = Module(name: (data[moduleID]?["name"] as? String) ?? "nil",
								emoji: (data[moduleID]?["emoji"] as? String) ?? "📄",
								id: moduleID)
			
			let date = Date().generateDate(from: data[moduleID]?["date"] as? String)
			module.date = date
			
			if let phrasesData = data[moduleID]?["phrases"] as? [Any] {
				for phrases in phrasesData {
					if let phraseDict = phrases as? [String: Any] {
						
						if let nativeTxt = phraseDict[Constants.nativeText] as? String,
						   let trasnlatedTxt = phraseDict[Constants.translatedText] as? String {
							
							var phrase = Phrase(nativeText: nativeTxt, translatedText: trasnlatedTxt)
							if let date = phraseDict[Constants.date] as? String {
								phrase.date = Date().generateDate(from: date)
							}
							module.phrases.append(phrase)
							
						}
						
					}
				}
			}
			
			modules.append(module)
		}
		
		return modules
	}
}
