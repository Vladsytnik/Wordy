//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 27.12.2022.
//

import Foundation
import FirebaseDatabase

struct Module: Equatable, Codable {
	var name: String = ""
	var emoji: String = ""
	var id: String = ""
	var date: Date?
	
	var phrases: [Phrase] = []
    var isSharedByTeacher = false
    var acceptedAsStudent = false
    var isBlockedFreeFeatures = false
}

extension Module {
	func getPhrasesAsDictionary() -> [[String: Any]] {
		var dictArray: [[String: Any]] = [[:]]
		
		for phrase in phrases {
			var tempDict: [String: Any] = [:]
			tempDict = [
				Constants.nativeText : phrase.nativeText,
				Constants.translatedText : phrase.translatedText,
				Constants.date: String().generateDate(from: phrase.date) as Any
			]
			if let example = phrase.example {
				tempDict[Constants.example] = example
			}
			dictArray.append(tempDict)
		}
		
		return dictArray
	}
	
	static func parse(from snapshot: DataSnapshot) -> [Module]? {
		newParse(from: snapshot)
		guard let data = (snapshot.value as? [String: [String: Any]]) else {
			return []
		}
		guard let dbModuleKeys = (snapshot.value as? [String: Any])?.keys else {
			return []
		}
		
		var modules: [Module] = []
		
		for moduleID in dbModuleKeys {
			var module = Module(name: (data[moduleID]?["name"] as? String) ?? "nil",
								emoji: (data[moduleID]?["emoji"] as? String) ?? "📄",
								id: moduleID,
                                isSharedByTeacher: (data[moduleID]?["isSharedByTeacher"] as? Bool) ?? false,
                                acceptedAsStudent: (data[moduleID]?["acceptedAsStudent"] as? Bool) ?? false,
                                isBlockedFreeFeatures: (data[moduleID]?["isBlockedFreeFeatures"] as? Bool) ?? false)
			
			let date = Date().generateDate(from: data[moduleID]?["date"] as? String)
			module.date = date
			
			if let phrasesData = data[moduleID]?["phrases"] as? [String: Any] {
				for (i, (phraseIdentifier, phrases)) in phrasesData.enumerated() {
					if let phraseDict = phrases as? [String: Any] {
						
						if let nativeTxt = phraseDict[Constants.nativeText] as? String,
						   let trasnlatedTxt = phraseDict[Constants.translatedText] as? String {
							
							var phrase = Phrase(nativeText: nativeTxt,
												translatedText: trasnlatedTxt,
												id: phraseIdentifier)
							if let date = phraseDict[Constants.date] as? String {
								phrase.date = Date().generateDate(from: date)
							}
							if let example = phraseDict[Constants.example] as? String {
								phrase.example = example
							}
							
							module.phrases.append(phrase)
						}
						
					}
				}
			}
            
            print("Testik2: \(module.name)")
            module.phrases.forEach { phrase in
                print("Testik2: date = \(phrase.date)")
            }
            print("Testik2: --")
            
            module.phrases.sort(by: { ($0.date ?? Date()) > ($1.date ?? Date()) })
			modules.append(module)
		}
		
		return modules
	}
	
	static func parseSingle(from snapshot: DataSnapshot, moduleID: String) -> Module? {
		newParse(from: snapshot)
		guard let data = (snapshot.value as? [String: Any]) else {
			return nil
		}

		var module = Module(name: (data["name"] as? String) ?? "nil",
							emoji: (data["emoji"] as? String) ?? "📄",
							id: moduleID,
                            isSharedByTeacher: (data["isSharedByTeacher"] as? Bool) ?? false,
                            acceptedAsStudent: (data["acceptedAsStudent"] as? Bool) ?? false,
                            isBlockedFreeFeatures:  (data["isBlockedFreeFeatures"] as? Bool) ?? false)
		
		let date = Date().generateDate(from: data["date"] as? String)
		module.date = date
		
		if let phrasesData = data["phrases"] as? [String: Any] {
			for (i, (phraseIdentifier, phrases)) in phrasesData.enumerated() {
				if let phraseDict = phrases as? [String: Any] {
					
					if let nativeTxt = phraseDict[Constants.nativeText] as? String,
					   let trasnlatedTxt = phraseDict[Constants.translatedText] as? String {
						
						var phrase = Phrase(nativeText: nativeTxt,
											translatedText: trasnlatedTxt,
											id: phraseIdentifier)
						if let date = phraseDict[Constants.date] as? String {
							phrase.date = Date().generateDate(from: date)
						}
						if let example = phraseDict[Constants.example] as? String {
							phrase.example = example
						}
						
						module.phrases.append(phrase)
					}
					
				}
			}
		}
		
        module.phrases.sort(by: AppConstants.phrasesSortingValue)
		return module
	}
	
	static func newParse(from snapshot: DataSnapshot) {
		guard let data = snapshot.value as? Data else { return }
		do {
			if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
				// Теперь у вас есть словарь jsonDictionary, содержащий данные из Firebase
				// Вы можете работать с данными, как с обычным словарем Swift
			} else {
				// Ошибка: Данные из Firebase не могут быть преобразованы в словарь
			}
		} catch {
			// Ошибка при декодировании JSON
			print("Ошибка декодирования JSON: \(error.localizedDescription)")
		}
	}
}
