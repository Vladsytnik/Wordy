//
//  WordCard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import SwiftUI

struct WordCard: View {
	
	let width: CGFloat
	@ObservedObject var viewModel = WordCardViewModel()
	
	@Binding var modules: [Module]
	
	init(width: CGFloat, modules: Binding<[Module]>, index: Int, phrase: Phrase) {
		self._modules = modules
		self.width = width
		viewModel.modules = modules.wrappedValue
		viewModel.index = index
		viewModel.phrase = phrase
	}
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack(alignment: .firstTextBaseline) {
					VStack(alignment: .leading, spacing: 7) {
						Text(viewModel.phrase.nativeText)
							.foregroundColor(.white)
							.font(.system(size: 24, weight: .bold))
						Text(viewModel.phrase.translatedText)
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
					.multilineTextAlignment(.leading)
			}
			.padding()
		}
		.onChange(of: viewModel.modules, perform: { newValue in
			self.modules = newValue
		})
		.background {
			RoundedRectangle(cornerRadius: 20)
				.foregroundColor(Color(asset: Asset.Colors.moduleCardBG))
//				.frame(width: width)
		}
	}
}

struct WordCard_Previews: PreviewProvider {
    static var previews: some View {
		WordCard(
			width: 300,
			modules: .constant([.init(name: "Test", emoji: "🔮")]),
			index: 0,
			phrase: Phrase(nativeText: "Overcome", translatedText: "Преодолевать")
		)
    }
}
