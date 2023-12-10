//
//  NewCategoryCard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 06.03.2023.
//

import SwiftUI

struct NewCategoryCard: View {
	
	var isSelected = false
	@State var inputText = ""
	@FocusState var isFocused
	@EnvironmentObject var themeManager: ThemeManager
	
	var onSubmit: (Bool, String) -> Void
	
	var body: some View {
		TextField("Новая группа".localize(), text: $inputText)
			.focused($isFocused)
			.padding(EdgeInsets(top: 10, leading: 32, bottom: 10, trailing: 32))
			.tint(.white)
			.background {
				GeometryReader { geo in
					if isSelected {
						themeManager.currentTheme.accent
							.cornerRadius(geo.size.height / 2)
					} else {
						themeManager.currentTheme.nonActiveCategory
							.cornerRadius(geo.size.height / 2)
					}
				}
			}
			.foregroundColor(themeManager.currentTheme.mainText)
			.font(.system(size: 16, weight: .regular))
			.onAppear{
				isFocused = true
			}
			.onSubmit {
				isFocused = false
				onSubmit(inputText.count > 0, inputText)
			}
	}
}

struct NewCategoryCard_Previews: PreviewProvider {
    static var previews: some View {
		NewCategoryCard() { success, text in }
    }
}
