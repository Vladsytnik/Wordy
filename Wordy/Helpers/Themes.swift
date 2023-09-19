//
//  Themes.swift
//  Wordy
//
//  Created by Vlad Sytnik on 18.09.2023.
//

import SwiftUI


struct Themes {
	static let availableThemes: [ColorTheme] = [
		ColorTheme(id: "MainColor",
				   accent: Color(asset: Asset.Colors.accent), //
				   main: Color(asset: Asset.Colors.main), //
				   darkMain: Color(asset: Asset.Colors.darkMain),
				   mainText: .white,
				   findedWordsHighlited: Color(asset: Asset.Colors.findedWordHighlite), //
				   brightForBtnsText: Color(asset: Asset.Colors.brightBtnText), //
				   moduleCreatingBtn: Color(asset: Asset.Colors.addModuleButtonBG), //
				   mainGray: Color(asset: Asset.Colors.createModuleButton), //
				   purchaseBtn: Color(asset: Asset.Colors.purchaseBtn),
				   learnModuleBtnText: Color(asset: Asset.Colors.learnModuleBtnText),
				   searchTextFieldBG: Color(asset: Asset.Colors.searchTFBackground),
				   answer1: Color(asset: Asset.Colors.answer1),
				   answer2: Color(asset: Asset.Colors.answer2),
				   answer3: Color(asset: Asset.Colors.answer3),
				   answer4: Color(asset: Asset.Colors.answer4),
				   
				   mainBackgroundImage: Image(asset: Asset.Images.gradientBG),
				   carouselCardBackgroundImage: Image(asset: Asset.Images.carouselBG),
				   authBackgroundImage: Image(asset: Asset.Images.authBG),
				   learnPageBackgroundImage: Image(asset: Asset.Images.learnPageBG)),
		ColorTheme(id: "RedColor",
				   accent: Color(asset: Asset.Colors2.accent2), //
				   main: Color(asset: Asset.Colors2.main2), //
				   darkMain: Color(asset: Asset.Colors2.darkMain2),
				   mainText: .white,
				   findedWordsHighlited: Color(asset: Asset.Colors2.findedWordHighlite2), //
				   brightForBtnsText: Color(asset: Asset.Colors2.brightBtnText2), //
				   moduleCreatingBtn: Color(asset: Asset.Colors2.addModuleButtonBG2), //
				   mainGray: Color(asset: Asset.Colors2.createModuleButton2), //
				   purchaseBtn: Color(asset: Asset.Colors2.purchaseBtn2),
				   learnModuleBtnText: Color(asset: Asset.Colors2.learnModuleBtnText2),
				   searchTextFieldBG: Color(asset: Asset.Colors2.searchTFBackground2),
				   answer1: Color(asset: Asset.Colors2.answer12),
				   answer2: Color(asset: Asset.Colors2.answer22),
				   answer3: Color(asset: Asset.Colors2.answer32),
				   answer4: Color(asset: Asset.Colors2.answer42),
				   
				   mainBackgroundImage: Image(asset: Asset.Images2.gradientBG2),
				   carouselCardBackgroundImage: Image(asset: Asset.Images2.carouselBG2),
				   authBackgroundImage: Image(asset: Asset.Images2.authBG2),
				   learnPageBackgroundImage: Image(asset: Asset.Images2.learnPageBG2))
	]
}
