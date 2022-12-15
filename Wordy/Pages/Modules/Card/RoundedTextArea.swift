//
//  RoundedTextArea.swift
//  Wordy
//
//  Created by Vlad Sytnik on 12.12.2022.
//

import SwiftUI

struct RoundedTextArea: View {
	
	let cardWidth: CGFloat
	let cardName: String
	let words: [String?]
	
	private var width: CGFloat {
		cardWidth / 1.12592593
	}
	private var height: CGFloat {
		cardWidth / 1.94871
	}
	
	var body: some View {
		ZStack {
			Background(width: width, height: height)
			VStack(alignment: .leading) {
				Text(cardName)
					.font(.system(size: 18, weight: .bold))
					.bold()
				Spacer()
				HStack() {
					VStack(alignment: .leading, spacing: 4) {
						Text(words[0] ?? "")
						Text(words[1] ?? "")
					}
					.font(.system(size: 9, weight: .medium))
					Spacer()
					Text("11/15")
						.foregroundColor(Color(asset: Asset.Colors.moduleCardLightGray))
				}
			}
			.foregroundColor(.white)
			.offset(y: -5)
			.padding()
		}
		.frame(
			width: width,
			height: height
		)
	}
}

struct RoundedTextArea_Previews: PreviewProvider {
	static var previews: some View {
		RoundedTextArea(cardWidth: 150, cardName: "Games", words: [
			"Dude",
			"Get on well well well",
			"Map",
			"Word"
		])
	}
}

struct Background: View {
	let width: CGFloat
	let height: CGFloat
	
	var body: some View {
		Rectangle()
			.frame(
				width: width,
				height: height
			)
			.foregroundColor(Color(asset: Asset.Colors.moduleCardDarkGray))
			.cornerRadius(10, corners: [.topLeft, .topRight])
			.cornerRadius(30, corners: [.bottomLeft, .bottomRight])
	}
}
