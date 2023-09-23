//
//  TooltipView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 01.09.2023.
//

import SwiftUI

struct TooltipView: View {
	
	let text: String
	let stepNumber: Int
	let allStepCount: Int
	var onNextDidTap: (() -> Void)?
//	var onSkipDidTap: (() -> Void)?
	
	@EnvironmentObject var themeManager: ThemeManager
	
    var body: some View {
		VStack(alignment: .trailing, spacing: 24) {
			Text(text)
				.foregroundColor(themeManager.currentTheme.mainText)
			HStack {
//				Button {
//					onSkipDidTap?()
//				} label: {
//					Text("Пропустить")
//						.foregroundColor(themeManager.currentTheme.mainText)
//				}
				Text("\(stepNumber + 1)/\(allStepCount)")
				Spacer()
				Button {
					onNextDidTap?()
				} label: {
					Text("Понятно")
						.foregroundColor(themeManager.currentTheme.mainText)
						.bold()
				}
			}
		}
    }
}
