//
//  PaywallViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 26.06.2023.
//

import Foundation
import ApphudSDK
import StoreKit
import SwiftUI

struct AppstorePrice {
	let priceDescription: String
	var descriptionText: String?
}

@MainActor
class PaywallViewModel: ObservableObject {
	
	@Published var selectedIndex: Int = 1
	@Published var products: [Product] = []
	
	@State var isPurchasing = false
	
	@Published var isInProgress = false
	
	let advantagesText = [
		("Разблокируйте свой творческий потенциал: бесконечное количество модулей и фраз", "Разблокируйте свой творческий потенциал:"),
		("Погружайтесь в мир обучения без ограничений: неограниченный доступ к обучающему режиму", "Погружайтесь в мир обучения без ограничений:"),
		("Личность и стиль: стилизация интерфейса на свой вкус", "Личность и стиль:"),
		("Настраивайте время и частоту уведомлений: (описание пока не придумал)", "Настраивайте время и частоту уведомлений:")
	]
	
	var attributedAdvantages: [AttributedString] = []
	
//	var prices: [AppstorePrice] = [
//		.init(priceDescription: "$9,99 once", descriptionText: "Pay once a year and get full access to all features while saving money"),
//		.init(priceDescription: "$0,99 month", descriptionText: "First 7 days free")
//	]
	
	init() {
		observeSelectedIndex()
		setAttributedAdvantages()
		Task {
			await fetchProducts()
		}
	}
	
	private func setAttributedAdvantages() {
		let theme = ThemeManager().currentTheme
		
		for (advantage, coloredPart) in advantagesText {
            let localizedString = NSLocalizedString(advantage, comment: "advantage")
            let localizedColoredPart = NSLocalizedString(coloredPart, comment: coloredPart)
            
//			let string = advantage
            let string = String(format: localizedString, advantage)
			var attributedString = AttributedString(string)
			//	attributedString.foregroundColor = .pink
            
            let colored = String(format: localizedColoredPart, coloredPart)
			
			if let range = attributedString.range(of: colored) {
				//	attributedString[range].foregroundColor = theme.accent
//				attributedString[range].foregroundColor = Color(asset: Asset.Colors.paywallCheckmark)
//				attributedString[range].underlineStyle = .single
//				attributedString[range].underlineColor = .green
				attributedString[range].font = .system(size: 14, weight: .black)
				attributedAdvantages.append(attributedString)
			}
		}
	}
	
	func observeSelectedIndex() {
		
	}
	
	func getSelectedProduct() -> Product {
		products[selectedIndex]
	}
	
	func didTapBtn(index:Int) {
		selectedIndex = index
	}
	
	func userDidBuyProduct(_ product: Product) {
		if selectedIndex < products.count {
			isInProgress = true
			Task { @MainActor in
				// productStruct is Product struct model from StoreKit2
				// $isPurchasing should be used only in SwiftUI apps, otherwise don't use this parameter
				let result = await Apphud.purchase(product, isPurchasing: $isPurchasing)
				isInProgress = false
				if result.success {
					// handle successful purchase
				}
			}
		}
	}
	
	func getPriceTitleFor(index: Int) -> String {
		products[index].displayPrice + "  " + products[index].displayName
	}
	
	func fetchProducts() async {
		do {
			//			let mainPaywall = await Apphud.paywall("wordy")
			products = try await Apphud.fetchProducts()
			for product in products {
				let displayName = product.displayName
				let descr = product.description
				let price = product.displayPrice
				print("Apphud product: ", displayName, descr, price)
				let test = true
			}

			//			print("Apphud products: ", apphudProducts)
		} catch {

		}
	}
}
