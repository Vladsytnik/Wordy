//
//  ModuleCard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 12.12.2022.
//

import SwiftUI

struct ModuleCard: View {
	
	let backgroundColor = Color(asset: Asset.Colors.moduleCardBG)
	let width: CGFloat
	
	var cardName = "Games"
	var emoji = "📄"
	let words = [
		"Dude",
		"Get on well",
		"Map",
		"Word"
	]
	
	private var height: CGFloat {
		width / 0.9268
	}
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 35.0)
				.foregroundColor(backgroundColor)
				.frame(width: width, height: height)
			VStack {
				Spacer()
				Text(emoji)
					.font(.system(size: width / 3.16666))
				Spacer()
				RoundedTextArea(
					cardWidth: width,
					cardName: cardName,
					words: words
				)
			}
			.frame(width: width, height: height)
			.offset(y: -7)
		}
	}
}

struct ModuleCard_Previews: PreviewProvider {
	static var previews: some View {
		ModuleCard(width: 150)
			.frame(width: 150)
	}
}
