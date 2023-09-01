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
	
    var body: some View {
		VStack(alignment: .trailing, spacing: 24) {
			Text(text)
				.foregroundColor(.white)
			HStack {
//				Button {
//					onSkipDidTap?()
//				} label: {
//					Text("Пропустить")
//						.foregroundColor(.white)
//				}
				Text("\(stepNumber + 1)/\(allStepCount)")
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
    }
}
