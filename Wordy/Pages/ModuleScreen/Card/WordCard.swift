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
							.multilineTextAlignment(.leading)
						Text(viewModel.phrase.translatedText)
							.foregroundColor(Color(asset: Asset.Colors.descrWordOrange))
							.font(.system(size: 18, weight: .medium))
							.multilineTextAlignment(.leading)
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
					.frame(height: viewModel.phrase.example != nil ? 5 : 1)
				if viewModel.phrase.example != nil {
					highlightSubstring(
						viewModel.phrase.nativeText,
						in: viewModel.phrase.example ?? ""
					)
						.foregroundColor(.white)
						.multilineTextAlignment(.leading)
				}
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
	
	func highlightSubstring(_ substring: String, in string: String) -> Text {
		guard let range = string.range(of: substring, options: [.caseInsensitive, .diacriticInsensitive]) else {
			return Text(string) // если подстрока не найдена, возвращаем исходный текст
		}
		let wordRange = string.rangeOfWord(containing: range)
		let prefix = string.prefix(upTo: wordRange.lowerBound)
		let highlightedSubstring = Text(string[wordRange]).foregroundColor(Color(asset: Asset.Colors.exampleYellow))
		let suffix = string.suffix(from: wordRange.upperBound)
		return Text(prefix) + highlightedSubstring + highlightSubstring(substring, in: String(suffix))
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
