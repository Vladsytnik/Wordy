//
//  Themes.swift
//  Wordy
//
//  Created by Vlad Sytnik on 18.09.2023.
//

import SwiftUI


struct Themes {
	static let availableThemes: [ColorTheme] = [
        ColorTheme(isFree: true,
                   isDark: true,
				   id: "MainColor",
				   accent: Color(asset: Asset.Colors.accent),
				   main: Color(asset: Asset.Colors.main),
				   darkMain: Color(asset: Asset.Colors.darkMain),
				   mainText: Color(asset: Asset.Colors.mainTextColor),
				   findedWordsHighlited: Color(asset: Asset.Colors.findedWordHighlite),
				   brightForBtnsText: Color(asset: Asset.Colors.brightBtnText),
				   moduleCreatingBtn: Color(asset: Asset.Colors.addModuleButtonBG),
				   mainGray: Color(asset: Asset.Colors.createModuleButton),
				   purchaseBtn: Color(asset: Asset.Colors.purchaseBtn),
				   learnModuleBtnText: Color(asset: Asset.Colors.learnModuleBtnText),
				   searchTextFieldBG: Color(asset: Asset.Colors.searchTFBackground),
				   searchTextFieldText: Color(asset: Asset.Colors.searchTextFieldTextColor),
				   moduleCardRoundedAreaColor: Color(asset: Asset.Colors.moduleCardRoundedAreaColor),
				   nonActiveCategory: Color(asset: Asset.Colors.nonActiveCategory),
                   carouselLearnBtnColor: Color(asset: Asset.Colors.carouselLearnBtnColor),
                   paywallBtnsColor: Color(asset: Asset.Colors.paywallBtnsColor),
                   moduleScreenBtnsColor: Color(asset: Asset.Colors.moduleScreenBtns),
                   
				   answer1: Color(asset: Asset.Colors.answer1),
				   answer2: Color(asset: Asset.Colors.answer2),
				   answer3: Color(asset: Asset.Colors.answer3),
				   answer4: Color(asset: Asset.Colors.answer4),
                   
                   moduleCardMainTextColor: Color(asset: Asset.Colors.moduleCardMainTextColor),
                   gradientStart: Color(asset: Asset.Colors.gradientStart),
                   gradientEnd: Color(asset: Asset.Colors.gradientEnd),
				   
				   mainBackgroundImage: Image(asset: Asset.Images.gradientBG),
				   carouselCardBackgroundImage: Image(asset: Asset.Images.carouselBG),
				   authBackgroundImage: Image(asset: Asset.Images.authBG),
				   learnPageBackgroundImage: Image(asset: Asset.Images.learnPageBG)),
		
		ColorTheme(isFree: true,
                   isDark: true,
				   id: "RedColor",
				   accent: Color(asset: Asset.Colors2.accent2),
				   main: Color(asset: Asset.Colors2.main2),
				   darkMain: Color(asset: Asset.Colors2.darkMain2),
				   mainText: Color(asset: Asset.Colors2.mainTextColor2),
				   findedWordsHighlited: Color(asset: Asset.Colors2.findedWordHighlite2),
				   brightForBtnsText: Color(asset: Asset.Colors2.brightBtnText2),
				   moduleCreatingBtn: Color(asset: Asset.Colors2.addModuleButtonBG2),
				   mainGray: Color(asset: Asset.Colors2.createModuleButton2),
				   purchaseBtn: Color(asset: Asset.Colors2.purchaseBtn2),
				   learnModuleBtnText: Color(asset: Asset.Colors2.learnModuleBtnText2),
				   searchTextFieldBG: Color(asset: Asset.Colors2.searchTFBackground2),
				   searchTextFieldText: Color(asset: Asset.Colors2.searchTextFieldTextColor2),
				   moduleCardRoundedAreaColor: Color(asset: Asset.Colors2.moduleCardRoundedAreaColor2),
				   nonActiveCategory: Color(asset: Asset.Colors2.nonActiveCategory2),
                   carouselLearnBtnColor: Color(asset: Asset.Colors2.carouselLearnBtnColor2),
                   paywallBtnsColor: Color(asset: Asset.Colors2.paywallBtnsColor2),
                   moduleScreenBtnsColor: Color(asset: Asset.Colors2.moduleScreenBtns2),
                   
				   answer1: Color(asset: Asset.Colors2.answer12),
				   answer2: Color(asset: Asset.Colors2.answer22),
				   answer3: Color(asset: Asset.Colors2.answer32),
				   answer4: Color(asset: Asset.Colors2.answer42),
                   
                   moduleCardMainTextColor: Color(asset: Asset.Colors2.moduleCardMainTextColor2),
				   
				   mainBackgroundImage: Image(asset: Asset.Images2.gradientBG2),
				   carouselCardBackgroundImage: Image(asset: Asset.Images2.carouselBG2),
				   authBackgroundImage: Image(asset: Asset.Images2.authBG2),
				   learnPageBackgroundImage: Image(asset: Asset.Images2.learnPageBG2)),
		
		ColorTheme(isFree: false,
                   isDark: false,
				   id: "LightPinkColor",
				   accent: Color(asset: Asset.Colors3.accent3),
				   main: Color(asset: Asset.Colors3.main3),
				   darkMain: Color(asset: Asset.Colors3.darkMain3),
				   mainText: Color(asset: Asset.Colors3.mainTextColor3),
				   findedWordsHighlited: Color(asset: Asset.Colors3.findedWordHighlite3),
				   brightForBtnsText: Color(asset: Asset.Colors3.brightBtnText3),
				   moduleCreatingBtn: Color(asset: Asset.Colors3.addModuleButtonBG3),
				   mainGray: Color(asset: Asset.Colors3.createModuleButton3),
				   purchaseBtn: Color(asset: Asset.Colors3.purchaseBtn3),
				   learnModuleBtnText: Color(asset: Asset.Colors3.learnModuleBtnText3),
				   searchTextFieldBG: Color(asset: Asset.Colors3.searchTFBackground3),
				   searchTextFieldText: Color(asset: Asset.Colors3.searchTextFieldTextColor3),
				   moduleCardRoundedAreaColor: Color(asset: Asset.Colors3.moduleCardRoundedAreaColor3),
				   nonActiveCategory: Color(asset: Asset.Colors3.nonActiveCategory3),
                   carouselLearnBtnColor: Color(asset: Asset.Colors3.carouselLearnBtnColor3),
                   paywallBtnsColor: Color(asset: Asset.Colors3.paywallBtnsColor3),
                   moduleScreenBtnsColor: Color(asset: Asset.Colors3.moduleScreenBtns3),
                   
				   answer1: Color(asset: Asset.Colors3.answer13),
				   answer2: Color(asset: Asset.Colors3.answer23),
				   answer3: Color(asset: Asset.Colors3.answer33),
                   answer4: Color(asset: Asset.Colors3.answer43),
                   
                   moduleCardMainTextColor: Color(asset: Asset.Colors3.moduleCardMainTextColor3),
                   
				   
				   mainBackgroundImage: Image(asset: Asset.Images3.gradientBG3),
				   carouselCardBackgroundImage: Image(asset: Asset.Images3.carouselBG3),
				   authBackgroundImage: Image(asset: Asset.Images3.authBG3),
				   learnPageBackgroundImage: Image(asset: Asset.Images3.learnPageBG3)),
        
        ColorTheme(isFree: false,
                   isDark: false,
                   id: "LightPastilleBlue",
                   accent: Color(asset: Asset.Colors4.accent4),
                   main: Color(asset: Asset.Colors4.main4),
                   darkMain: Color(asset: Asset.Colors4.darkMain4),
                   mainText: Color(asset: Asset.Colors4.mainTextColor4),
                   findedWordsHighlited: Color(asset: Asset.Colors4.findedWordHighlite4),
                   brightForBtnsText: Color(asset: Asset.Colors4.brightBtnText4),
                   moduleCreatingBtn: Color(asset: Asset.Colors4.addModuleButtonBG4),
                   mainGray: Color(asset: Asset.Colors4.createModuleButton4),
                   purchaseBtn: Color(asset: Asset.Colors4.purchaseBtn4),
                   learnModuleBtnText: Color(asset: Asset.Colors4.learnModuleBtnText4),
                   searchTextFieldBG: Color(asset: Asset.Colors4.searchTFBackground4),
                   searchTextFieldText: Color(asset: Asset.Colors4.searchTextFieldTextColor4),
                   moduleCardRoundedAreaColor: Color(asset: Asset.Colors4.moduleCardRoundedAreaColor4),
                   nonActiveCategory: Color(asset: Asset.Colors4.nonActiveCategory4),
                   carouselLearnBtnColor: Color(asset: Asset.Colors4.carouselLearnBtnColor4),
                   paywallBtnsColor: Color(asset: Asset.Colors4.paywallBtnsColor4),
                   moduleScreenBtnsColor: Color(asset: Asset.Colors4.moduleScreenBtns4),
                   
                   answer1: Color(asset: Asset.Colors4.answer14),
                   answer2: Color(asset: Asset.Colors4.answer24),
                   answer3: Color(asset: Asset.Colors4.answer34),
                   answer4: Color(asset: Asset.Colors4.answer44),
                   
                   moduleCardMainTextColor: Color(asset: Asset.Colors4.moduleCardMainTextColor4),
                   
                   mainBackgroundImage: Image(asset: Asset.Images4.gradientBG4),
                   carouselCardBackgroundImage: Image(asset: Asset.Images4.carouselBG4),
                   authBackgroundImage: Image(asset: Asset.Images4.authBG4),
                   learnPageBackgroundImage: Image(asset: Asset.Images4.learnPageBG4))
	]
}
