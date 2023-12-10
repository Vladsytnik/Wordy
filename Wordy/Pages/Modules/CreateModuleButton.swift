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
	
	let createModuleText = "Создать модуль".localize()
	
    var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 20)
					.foregroundColor(themeManager.currentTheme.moduleCreatingBtn)
					.shadow(color: .white.opacity(0.15), radius: 20)
				HStack {
					if text == nil {
						Image(systemName: "plus.circle.fill")
							.foregroundColor(themeManager.currentTheme.mainText)
					}
					if text == nil {
						Text("Создать модуль".localize())
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
