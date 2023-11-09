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
    var withoutSteps = false
    var description: String?
    var onDisappear: (() -> Void)?
	var onNextDidTap: (() -> Void)?
//	var onSkipDidTap: (() -> Void)?
	
	@EnvironmentObject var themeManager: ThemeManager
	
    var body: some View {
		VStack(alignment: .leading, spacing: 24) {
			Text(text)
                .foregroundColor(.white)
            
            if let description {
                Text(description)
                    .foregroundColor(.gray)
            }
            
			HStack {
//				Button {
//					onSkipDidTap?()
//				} label: {
//					Text("Пропустить")
//						.foregroundColor(themeManager.currentTheme.mainText)
//				}
                if !withoutSteps {
                    Text("\(stepNumber + 1)/\(allStepCount)")
                }
                
				Spacer()
                
				Button {
					onNextDidTap?()
				} label: {
					Text("Понятно")
						.foregroundColor(.white)
						.bold()
				}
			}
		}
        .onDisappear {
            onDisappear?()
        }
    }
}
