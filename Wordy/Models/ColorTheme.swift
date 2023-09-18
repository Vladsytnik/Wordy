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
	let mainText: Color
	let findedWordsHighlited: Color
	let brightForBtnsText: Color
	let moduleCreatingBtn: Color
	let mainGray: Color
	let caruselCard: Color
	let purchaseBtn: Color
	
	let mainBackgroundImage: Image
	let carouselCardBackgroundImage: Image
	let authBackgroundImage: Image
	let learnPageBackgroundImage: Image
}
