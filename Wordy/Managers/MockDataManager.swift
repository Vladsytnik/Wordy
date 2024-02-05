//
//  MochDataManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 31.08.2023.
//

import Foundation

class MockDataManager {
    
    let langCode = UserDefaultsManager.learnLanguage?.getLangCodeForYandexApy() ?? ""

	var modules: [Module] {
		[
            Module(name: "Музыка".localize(forLang: langCode), emoji: "🎧", id: "1", date: Date(), phrases: [
				Phrase(nativeText: "Test native",
					   translatedText: "Test translated",
					   id: "",
					   example: "Test example",
					   date: Date())
			]),
			Module(name: "Развлечения".localize(forLang: langCode), emoji: "👻", id: "2", date: Date(), phrases: [
                Phrase(nativeText: "Праздник".localize(forLang: langCode),
                       translatedText: "",
                       id: "",
                       example: "",
                       date: Date()),
                Phrase(nativeText: "Спектакль".localize(forLang: langCode),
                       translatedText: "",
                       id: "",
                       example: "",
                       date: Date())
            ]),
            Module(name: "Путешествия".localize(forLang: langCode), emoji: UserDefaultsManager.learnLanguage?.getIcon() ?? "✈️", id: "3", date: Date(), phrases: [
                Phrase(nativeText: "Test native",
                       translatedText: "Test translated",
                       id: "",
                       example: "Test example",
                       date: Date())
            ]),
			Module(name: "Еда".localize(forLang: langCode), emoji: "🍟", id: "4", date: Date(), phrases: []),
			Module(name: "Фильм Avatar".localize(forLang: langCode), emoji: "🍿", id: "5", date: Date(), phrases: []),
			Module(name: "Кино".localize(forLang: langCode), emoji: "🎬", id: "6", date: Date(), phrases: [])
		]
	}
	
	var groups: [Group] {
		[
            Group(name: "Любимые модули 🤍".localize(), id: "1", modulesID: ["1"], date: Date())
		]
	}
}
