//
//  ModuleCard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 12.12.2022.
//

import SwiftUI

struct ModuleCard: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	let width: CGFloat
	
	var cardName = "Games"
	var emoji = "📄"
	let words = [
		"Dude",
		"Get on well",
		"Map",
		"Word"
	]
	
	@Binding var module: Module
	@Binding var isSelected: Bool
	
	private var height: CGFloat {
		width / 0.9268
	}
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 35.0)
				.overlay {
					if isSelected {
						Color.green.opacity(0.6)
							.cornerRadius(35.0)
					}
				}
				.foregroundColor(themeManager.currentTheme.main)
				.frame(width: width, height: height)
			VStack {
				Spacer()
				ZStack {
					Text(emoji)
						.font(.system(size: width / 3.16666))
					if isSelected {
						HStack {
							Spacer()
							VStack {
								Image(systemName: "checkmark.circle.fill")
									.resizable()
									.foregroundColor(themeManager.currentTheme.mainText)
									.frame(width: 20, height: 20)
									.opacity(0.9)
								Spacer()
							}
						}
						.padding()
					}
				}
				Spacer()
				RoundedTextArea(
					cardWidth: width,
					cardName: cardName,
					module: $module
				)
			}
			.frame(width: width, height: height)
			.offset(y: -7)
		}
	}
}

struct ModuleCard_Previews: PreviewProvider {
	static var previews: some View {
		ModuleCard(width: 150, module: .constant(.init()), isSelected: .constant(false))
			.frame(width: 150)
	}
}
