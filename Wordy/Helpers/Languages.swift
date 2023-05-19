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
		}
	}
}
