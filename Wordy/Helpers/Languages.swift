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
		}
	}
	
	func getTitle() -> String {
		switch self {
		case .ru:
			return "Русский"
		case .eng:
			return "English"
		case .it:
			return "Italian"
		case .ro:
			return "Română"
		case .tur:
			return "Türkçe"
		case .ispan:
			return "Español"
		}
	}
	
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
		}
	}
}
