//
//  Languages.swift
//  Wordy
//
//  Created by Vlad Sytnik on 17.05.2023.
//

import Foundation

enum Language: String, CaseIterable, Codable {
	case ru
	case eng
	case it
	case ro
	case tur
	case ispan
    
    case german
    case france
    case chinese
    case japanese
    case hindi
	
	static func getAll() -> [Language] {
		Self.allCases
	}
	
	func getIcon() -> String {
		switch self {
		case .ru:
			return "🇷🇺"
		case .eng:
			return "🇬🇧"
		case .it:
			return "🇮🇹"
		case .ro:
			return "🇷🇴"
		case .tur:
			return "🇹🇷"
		case .ispan:
			return "🇪🇸"
        case .german:
            return "🇩🇪"
        case .france:
            return "🇫🇷"
        case .chinese:
            return "🇨🇳"
        case .japanese:
            return "🇯🇵"
        case .hindi:
            return "🇮🇳"
        }
	}
	
	func getTitle() -> String {
        var result = ""
        
		switch self {
		case .ru:
            result = "Russian"
		case .eng:
            result = "English"
		case .it:
            result = "Italiano"
		case .ro:
            result = "Romanian"
		case .tur:
            result = "Turkish"
		case .ispan:
            result = "Spanish"
        case .german:
            result = "German"
        case .france:
            result = "French"
        case .chinese:
            result = "Chinese"
        case .japanese:
            result = "Japanese"
        case .hindi:
            result = "Hindi"
        }
        
        return result.localize()
	}
	
    // для озвучивания фраз
    // https://www.loc.gov/standards/iso639-2/php/English_list.php
	func getLangCode() -> String {
		switch self {
		case .ru:
			return "ru-RU"
		case .eng:
			return "en-US"
		case .it:
			return "it-IT"
		case .ro:
			return "ro-RO"
		case .tur:
			return "tr-TR"
		case .ispan:
			return "es-ES"
        case .german:
            return "de"
        case .france:
            return "fr"
        case .chinese:
            return "zh"
        case .japanese:
            return "ja"
        case .hindi:
            return "hi"
        }
	}
	
	func getLangCodeForYandexApy() -> String {
		switch self {
		case .ru:
			return "ru"
		case .eng:
			return "en"
		case .it:
			return "it"
		case .ro:
			return "ro"
		case .tur:
			return "tr"
		case .ispan:
			return "es"
        case .german:
            return "de"
        case .france:
            return "fr"
        case .chinese:
            return "zh"
        case .japanese:
            return "ja"
        case .hindi:
            return "hi"
        }
	}
    
    func getLangCodeForGeneratingExamples() -> String {
        switch self {
        case .eng:
            return "english"
        case .it:
            return "italian"
        case .tur:
            return "turkish"
        case .ispan:
            return "spanish"
        case .ru:
            return "russian"
        case .ro:
            return "romanian"
        case .german:
            return "german"
        case .france:
            return "french"
        case .chinese:
            return "chinese"
        case .japanese:
            return "japanese"
        case .hindi:
            return "hindi"
        }
    }
    
//    func getAdditionalLangCodeForGeneratingExamples() -> String {
//        switch self {
//        case .eng:
//            return "russian"
//        case .it:
//            return "english"
//        case .tur:
//            return "turkish"
//        case .ispan:
//            return "spanish"
//        case .ru:
//            return "russian"
//        case .ro:
//            return "romanian"
//        }
//    }
}
