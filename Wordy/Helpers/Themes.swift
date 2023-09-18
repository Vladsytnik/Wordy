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
				   accent: Color(asset: Asset.Colors.lightPurple), //
				   main: Color(asset: Asset.Colors.moduleCardBG), //
				   mainText: .white,
				   findedWordsHighlited: Color(asset: Asset.Colors.exampleYellow), //
				   brightForBtnsText: Color(asset: Asset.Colors.descrWordOrange), //
				   moduleCreatingBtn: Color(asset: Asset.Colors.addModuleButtonBG), //
				   mainGray: Color(asset: Asset.Colors.createModuleButton), //
				   caruselCard: Color(asset: Asset.Colors.lightPurple),
				   purchaseBtn: Color(asset: Asset.Colors.lightPurple),
				   mainBackgroundImage: Image(asset: Asset.Images.gradientBG),
				   carouselCardBackgroundImage: Image(asset: Asset.Images.carouselBG),
				   authBackgroundImage: Image(asset: Asset.Images.authBG),
				   learnPageBackgroundImage: Image(asset: Asset.Images.learnPageBG))
	]
}
