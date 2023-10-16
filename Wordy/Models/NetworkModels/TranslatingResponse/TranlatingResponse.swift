//
//  TranlatingResponse.swift
//  Wordy
//
//  Created by Vlad Sytnik on 15.09.2023.
//

import Foundation

struct TranslatedResponse: Codable {
	let translations: [Translation]
}

struct Translation: Codable {
	let text: String
}
