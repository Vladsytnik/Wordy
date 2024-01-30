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
    @Environment(\.colorScheme) var colorScheme
	
    var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 20)
					.foregroundColor(themeManager.currentTheme.moduleCreatingBtn)
					.shadow(color: .white.opacity(0.15), radius: 20)
                    .if(!isDark()) { v in
                        v
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(themeManager.currentTheme.moduleCardRoundedAreaColor, lineWidth: 1)
//                                    .foregroundColor(themeManager.currentTheme.mainText)
//                            }
                            .shadow(color: themeManager.currentTheme.mainText.opacity(0.35), radius: 25)
                    }
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
                        Text((text ?? "").localize())
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 16, weight: .medium))
					}
				}
			}
		}
		.frame(height: 55)
    }
    
    private func isDark() -> Bool {
        themeManager.currentTheme.isSupportLightTheme
        ? colorScheme != .light
        : themeManager.currentTheme.isDark
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
