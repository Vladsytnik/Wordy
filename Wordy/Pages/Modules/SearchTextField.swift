//
//  SearchTextField.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.12.2022.
//

import SwiftUI

struct SearchTextField: View {
	
	@Binding var modules: [Module]
	@Binding var searchText: String
	let placeholder: String
	@EnvironmentObject var themeManager: ThemeManager
    
    @FocusState var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
	
//	@State private var initialModules: [Module] = []

    var body: some View {
		Color.clear
			.frame(height: 35)
			.background {
				GeometryReader { geo in
					ZStack {
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(themeManager.currentTheme.searchTextFieldBG)
//                        VisualEffectView(effect: UIBlurEffect(style: .regular))
//                            .cornerRadius(11, corners: .allCorners)
							.overlay {
								HStack {
									Image(asset: Asset.Images.searchIcon)
//										.foregroundColor(themeManager.currentTheme.searchTextFieldText)
										.colorMultiply(themeManager.currentTheme.searchTextFieldText)
										.padding(.leading)
                                        .onTapGesture {
                                            isFocused = true
                                        }
									ZStack {
										TextField("", text: $searchText)
											.foregroundColor(themeManager.currentTheme.searchTextFieldText)
											.tint(themeManager.currentTheme.accent)
											.onChange(of: searchText) { newValue in
												filterModules(text: newValue)
											}
                                            .focused($isFocused)
										HStack {
											Text(placeholder)
												.fontWeight(.regular)
                                                .opacity(searchText.isEmpty ? (isDark() ? 0.5 : 0.7) : 0)
												.foregroundColor(themeManager.currentTheme.searchTextFieldText)
												.padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
                                                .onTapGesture {
                                                    isFocused = true
                                                }
											Spacer()
										}
									}
								}
							}
					}
				}
			}
    }
    
    private func isDark() -> Bool {
        themeManager.currentTheme.isSupportLightTheme
        ? colorScheme != .light
        : themeManager.currentTheme.isDark
    }
	
	func filterModules(text: String) {
//		print(text, modules.count, filteredModules.count)
//		if text.count > 0 {
//			filteredModules = modules.filter({ module in
//				module.name.contains("\(text)")
//			})
//		} else {
//			filteredModules = modules
//		}
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
		SearchTextField(modules: .constant([]), searchText: .constant("test"), placeholder: "Search")
			.frame(width: 300)
    }
}
