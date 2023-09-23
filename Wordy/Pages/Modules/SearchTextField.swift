//
//  SearchTextField.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.12.2022.
//

import SwiftUI

struct SearchTextField: View {
	
	@Binding var modules: [Module]
	@Binding var filteredModules: [Module]
	@Binding var searchText: String
	let placeholder: String
	@EnvironmentObject var themeManager: ThemeManager
	
//	@State private var initialModules: [Module] = []

    var body: some View {
		Color.clear
			.frame(height: 35)
			.background {
				GeometryReader { geo in
					ZStack {
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(themeManager.currentTheme.searchTextFieldBG)
							.overlay {
								HStack {
									Image(asset: Asset.Images.searchIcon)
//										.foregroundColor(themeManager.currentTheme.searchTextFieldText)
										.colorMultiply(themeManager.currentTheme.searchTextFieldText)
										.padding(.leading)
									ZStack {
										TextField("", text: $searchText)
											.foregroundColor(themeManager.currentTheme.searchTextFieldText)
											.tint(themeManager.currentTheme.accent)
											.onChange(of: searchText) { newValue in
												filterModules(text: newValue)
											}
										HStack {
											Text(placeholder)
												.fontWeight(.medium)
												.opacity(searchText.isEmpty ? 0.8 : 0)
												.foregroundColor(themeManager.currentTheme.searchTextFieldText)
												.padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
											Spacer()
										}
									}
								}
							}
					}
				}
			}
    }
	
	func filterModules(text: String) {
		print(text, modules.count, filteredModules.count)
		if text.count > 0 {
			filteredModules = modules.filter({ module in
				module.name.contains("\(text)")
			})
		} else {
			filteredModules = modules
		}
	}

//	init(modules: Binding<[Module]>, searchText: Binding<String>, placeholder: String) {
//		self.modules = modules.wrappedValue
//		self._filteredModules = modules
//		self._searchText = searchText
//		self.placeholder = placeholder
//	}
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
		SearchTextField(modules: .constant([]), filteredModules: .constant([]), searchText: .constant("test"), placeholder: "Search")
			.frame(width: 300)
    }
}
