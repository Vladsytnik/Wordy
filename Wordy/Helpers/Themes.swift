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
				   mainText: .white,
				   findedWordsHighlited: Color(asset: Asset.Colors.findedWordHighlite), //
				   brightForBtnsText: Color(asset: Asset.Colors.brightBtnText), //
				   moduleCreatingBtn: Color(asset: Asset.Colors.addModuleButtonBG), //
				   mainGray: Color(asset: Asset.Colors.createModuleButton), //
				   purchaseBtn: Color(asset: Asset.Colors.purchaseBtn),
				   mainBackgroundImage: Image(asset: Asset.Images.gradientBG),
				   carouselCardBackgroundImage: Image(asset: Asset.Images.carouselBG),
				   authBackgroundImage: Image(asset: Asset.Images.authBG),
				   learnPageBackgroundImage: Image(asset: Asset.Images.learnPageBG))
	]
}
