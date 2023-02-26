//
//  CategoryCard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI

struct SizeKey: PreferenceKey {
	static var defaultValue: CGSize = .zero
	
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

struct CategoryCard: View {
	
	let text: String
	var isSelected = false
	
    var body: some View {
        Text(text)
			.padding(EdgeInsets(top: 10, leading: 32, bottom: 10, trailing: 32))
			.background {
				GeometryReader { geo in
					if isSelected {
						Color(asset: Asset.Colors.lightPurple)
							.cornerRadius(geo.size.height / 2)
					} else {
						Color(asset: Asset.Colors.nonActiveCategory)
							.cornerRadius(geo.size.height / 2)
					}
				}
			}
			.foregroundColor(.white)
			.font(.system(size: 16, weight: .regular))
    }
}

struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCard(text: "Эйфория ")
    }
}
