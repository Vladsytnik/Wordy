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
				   answer1: Color(asset: Asset.Colors.answer1),
				   answer2: Color(asset: Asset.Colors.answer2),
				   answer3: Color(asset: Asset.Colors.answer3),
				   answer4: Color(asset: Asset.Colors.answer4),
				   mainBackgroundImage: Image(asset: Asset.Images.gradientBG),
				   carouselCardBackgroundImage: Image(asset: Asset.Images.carouselBG),
				   authBackgroundImage: Image(asset: Asset.Images.authBG),
				   learnPageBackgroundImage: Image(asset: Asset.Images.learnPageBG)),
		ColorTheme(id: "RedColor",
				   accent: Color(asset: Asset.Colors2.accent), //
				   main: Color(asset: Asset.Colors2.main), //
				   darkMain: Color(asset: Asset.Colors2.darkMain),
				   mainText: .white,
				   findedWordsHighlited: Color(asset: Asset.Colors2.findedWordHighlite), //
				   brightForBtnsText: Color(asset: Asset.Colors2.brightBtnText), //
				   moduleCreatingBtn: Color(asset: Asset.Colors2.addModuleButtonBG), //
				   mainGray: Color(asset: Asset.Colors2.createModuleButton), //
				   purchaseBtn: Color(asset: Asset.Colors2.purchaseBtn),
				   answer1: Color(asset: Asset.Colors2.answer1),
				   answer2: Color(asset: Asset.Colors2.answer2),
				   answer3: Color(asset: Asset.Colors2.answer3),
				   answer4: Color(asset: Asset.Colors2.answer4),
				   mainBackgroundImage: Image(asset: Asset.Images.gradientBG),
				   carouselCardBackgroundImage: Image(asset: Asset.Images.carouselBG),
				   authBackgroundImage: Image(asset: Asset.Images.authBG),
				   learnPageBackgroundImage: Image(asset: Asset.Images.learnPageBG))
	]
}
