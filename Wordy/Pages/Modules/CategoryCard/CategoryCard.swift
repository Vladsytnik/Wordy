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
	
	let group: Group
	var isSelected = false
	
	@Binding var modules: [Module]
	@Binding var filteredModules: [Module]
	@Binding var searchText: String
	
	@State private var savedModules: [Module] = []
	@State private var animationState = Animation.spring()
	
    var body: some View {
		Text(group.name)
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
			.onChange(of: isSelected) { newValue in
					if newValue {
						filteredModules = modules.filter{ group.modulesID.contains($0.id) }
					}
			}
    }
}

struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
		CategoryCard(group: Group(), modules: .constant([]), filteredModules: .constant([]), searchText: .constant(""))
    }
}
