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
	
	var onSubmit: (Bool, String) -> Void
	
	var body: some View {
		TextField("Новая группа", text: $inputText)
			.focused($isFocused)
			.padding(EdgeInsets(top: 10, leading: 32, bottom: 10, trailing: 32))
			.tint(.white)
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