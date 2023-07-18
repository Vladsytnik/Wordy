//
//  PaywallViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 26.06.2023.
//

import Foundation

struct AppstorePrice {
	let priceDescription: String
	var descriptionText: String?
}

class PaywallViewModel: ObservableObject {
	
	@Published var selectedIndex: Int?
	var prices: [AppstorePrice] = [
		.init(priceDescription: "$9,99 once", descriptionText: "Pay once and get full access to all features forever"),
		.init(priceDescription: "$0,99 month", descriptionText: "First 7 days free")
	]
	
	init() {
		observeSelectedIndex()
	}
	
	func observeSelectedIndex() {
		
	}
	
	func didTapBtn(index: Int) {
		selectedIndex = index
	}
}
