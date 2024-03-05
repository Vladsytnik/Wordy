//
//  WordCardViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 14.01.2023.
//

import Foundation

class WordCardViewModel: ObservableObject {
	
	@Published var newAddedExample: String = ""
	@Published var isAddingExample = false
	
}
