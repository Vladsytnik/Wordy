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

enum SubscriptionPeriod: String, CaseIterable {
    case OneMonth = "month"
    case OneYear = "year"
    
    func getPeriodText() -> String {
        switch self {
        case .OneMonth:
            return "month".localize()
        case .OneYear:
            return "year".localize()
        }
    }
    
    static func fetch(from offerName: String) -> Self? {
        for period in SubscriptionPeriod.allCases {
            if offerName.lowercased().contains(period.rawValue.lowercased()) {
                return period
            }
        }
        return nil
    }
 }

@MainActor
class PaywallViewModel: ObservableObject {
	
	@Published var selectedIndex: Int = 1
	@Published var products: [Product] = []
	
	@State var isPurchasing = false
	
	@Published var isInProgress = false
    @Published var showAlert = false
    @Published var alertText = ""
    @Published var alertTitle = "Wordy.app"
    @Published var isNeedToClosePaywall = false
    
    var popularIndex = 0
	
	let advantagesText = [
		("Разблокируйте свой творческий потенциал: бесконечное количество модулей и фраз", "Разблокируйте свой творческий потенциал:"),
		("Погружайтесь в мир обучения без ограничений: неограниченный доступ к обучающему режиму", "Погружайтесь в мир обучения без ограничений:"),
		("Личность и стиль: стилизация интерфейса на свой вкус", "Личность и стиль:"),
		("Настраивайте время и частоту уведомлений: простое и эффективное изучение новых слов", "Настраивайте время и частоту уведомлений:")
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
	
//	func userDidBuyProduct(_ product: Product) {
//		if selectedIndex < products.count {
//			isInProgress = true
//			Task { @MainActor in
//				// productStruct is Product struct model from StoreKit2
//				// $isPurchasing should be used only in SwiftUI apps, otherwise don't use this parameter
//				let result = await Apphud.purchase(product, isPurchasing: $isPurchasing)
//				isInProgress = false
//				if result.success {
//					// handle successful purchase
////                    alertText = "Поздравляем, оплата прошла успешно! \n\nСпасибо, что поддерживаете нас! <3. Теперь вам доступны все возможности приложения без ограничений!".localize()
////                    showAlert.toggle()
//				}
//			}
//		}
//	}
	
	func getPriceTitleFor(index: Int) -> String {
        print(products[index])
        guard let period = SubscriptionPeriod.fetch(from: products[index].id) else { return "error" }
        if period == .OneYear {
            popularIndex = index
        }
        return products[index].displayPrice + " / " + period.getPeriodText()
	}
    
    func getSubscriptionPeriodFor(index: Int) -> SubscriptionPeriod? {
        guard let period = SubscriptionPeriod.fetch(from: products[index].id) else { return nil }
        return period
    }
    
    func showErrorRestore() {
        alertTitle = "Wordy.app"
        alertText = "К сожалению, нам не удалось возобновить покупку".localize()
        showAlert.toggle()
    }
    
    func showSuccessRestore() {
        alertTitle = "Все прошло успешно!".localize()
        alertText = "Теперь вам доступны все возможности приложения без ограничений!".localize()
        showAlert.toggle()
        isNeedToClosePaywall = true
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
