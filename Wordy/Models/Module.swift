//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 27.12.2022.
//

import Foundation

struct Module {
	var name: String = ""
	var emoji: String = ""
	var id: String = ""
	var date: Date?
	
	var phrases: [String: String] = [:]
}
