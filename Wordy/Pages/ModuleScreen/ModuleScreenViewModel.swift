//
//  ModuleScreenViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import Foundation

class ModuleScreenViewModel: ObservableObject {
	
	@Published var module = Module()
	@Published var words: [String] = []
	@Published var showActionSheet = false
	
	func fetchWords() {
		
	}
}
