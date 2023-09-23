//
//  CreateModuleButton.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.12.2022.
//

import SwiftUI

struct CreateModuleButton: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	let action: () -> Void
	var text: String?
	
	let createModuleText = LocalizedStringKey("Создать модуль")
	
    var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 20)
					.foregroundColor(Color(asset: Asset.Colors.createModuleButton))
					.shadow(color: .white.opacity(0.15), radius: 20)
				HStack {
					if text == nil {
						Image(systemName: "plus.circle.fill")
							.foregroundColor(themeManager.currentTheme.mainText)
					}
					if text == nil {
						Text(LocalizedStringKey("Создать модуль"))
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 16, weight: .medium))
					} else {
						Text(LocalizedStringKey(text ?? ""))
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 16, weight: .medium))
					}
				}
			}
		}
		.frame(height: 55)
    }
}

struct CreateModuleButton_Previews: PreviewProvider {
	static var previews: some View {
		CreateModuleButton() {}
			.frame(width: 300, height: 55)
			.background{
				Image(asset: Asset.Images.gradientBG)
			}
	}
}
