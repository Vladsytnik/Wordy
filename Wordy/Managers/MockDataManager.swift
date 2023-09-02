//
//  MochDataManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 31.08.2023.
//

import Foundation

class MockDataManager {

	var modules: [Module] {
		[
			Module(name: "Barbie", emoji: "👩🏼‍❤️‍👨🏼", id: "1", date: Date(), phrases: [
				Phrase(nativeText: "Test native",
					   translatedText: "Test translated",
					   id: "",
					   example: "Test example",
					   date: Date())
			]),
			Module(name: "Breaking Bad", emoji: "👻", id: "2", date: Date(), phrases: []),
			Module(name: "Star Wars", emoji: "🚀", id: "3", date: Date(), phrases: []),
			Module(name: "Harry Potter", emoji: "❤️‍🔥", id: "4", date: Date(), phrases: []),
			Module(name: "Avatar", emoji: "👾", id: "5", date: Date(), phrases: []),
			Module(name: "Friends", emoji: "🕺🏻", id: "6", date: Date(), phrases: [])
		]
	}
	
	var groups: [Group] {
		[
			Group(name: "My favorite modules 🤍", id: "1", modulesID: ["1"], date: Date())
		]
	}
}
