//
//  WordCard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import SwiftUI

struct WordCard: View {
	
	let width: CGFloat
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack(alignment: .firstTextBaseline) {
					VStack(alignment: .leading) {
						Text("Overcome")
							.foregroundColor(.white)
							.font(.system(size: 24, weight: .bold))
						Text("Преодолевать, преодолеть")
							.foregroundColor(Color(asset: Asset.Colors.descrWordOrange))
							.font(.system(size: 18, weight: .medium))
//							.lineLimit(1)
					}
//					.padding()
					Spacer()
					Button {
						
					} label: {
						Image(asset: Asset.Images.speach)
							.resizable()
							.frame(width: 30, height: 30)
							.offset(x: -11, y: 5)
					}

				}
				Color.clear
					.frame(height: 5)
				Text("I want to overcome myself because i bealive I want to overcome myself because i bealive ")
					.foregroundColor(.white)
//					.padding()
			}
			.padding()
		}
		.background {
			RoundedRectangle(cornerRadius: 20)
				.foregroundColor(Color(asset: Asset.Colors.moduleCardBG))
//				.frame(width: width)
		}
	}
}

struct WordCard_Previews: PreviewProvider {
    static var previews: some View {
        WordCard(width: 300)
//			.frame(width: 333, height: 120)
    }
}
