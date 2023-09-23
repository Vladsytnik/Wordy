//
//  ColorTheme.swift
//  Wordy
//
//  Created by Vlad Sytnik on 18.09.2023.
//

import SwiftUI

protocol ThemeProtocol {
	var id: String { get }
}

struct ColorTheme: ThemeProtocol {
	var id: String
	let accent: Color
	let main: Color
	let darkMain: Color
	let mainText: Color
	let findedWordsHighlited: Color
	let brightForBtnsText: Color
	let moduleCreatingBtn: Color
	let mainGray: Color
	let purchaseBtn: Color
	let learnModuleBtnText: Color
	let searchTextFieldBG: Color
	let searchTextFieldText: Color
	let moduleCardRoundedAreaColor: Color
	let nonActiveCategory: Color
	
	let answer1: Color
	let answer2: Color
	let answer3: Color
	let answer4: Color
	
	let mainBackgroundImage: Image
	let carouselCardBackgroundImage: Image
	let authBackgroundImage: Image
	let learnPageBackgroundImage: Image
}
