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
	@EnvironmentObject var themeManager: ThemeManager
	
	@Binding var module: Module
    private let phraseIndex: Int
	@FocusState var isFocused: Bool
	
	var onAddExampleTap: ((Int) -> Void)?
	var onEditTap: ((Int) -> Void)?
	var onSpeachTap: ((Int) -> Void)?
	
	init(
		width: CGFloat,
		module: Binding<Module>,
		phraseIndex: Int,
		onAddExampleTap: ((Int) -> Void)?,
		onEditTap: ((Int) -> Void)?,
		onSpeachTap: ((Int) -> Void)?
	) {
		self._module = module
		self.width = width
        self.phraseIndex = phraseIndex
		self.onAddExampleTap = onAddExampleTap
		self.onEditTap = onEditTap
		self.onSpeachTap = onSpeachTap
	}
	
	var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack(alignment: .firstTextBaseline) {
					VStack(alignment: .leading, spacing: 7) {
                        Text(module.phrases[phraseIndex].nativeText)
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 24, weight: .bold))
							.multilineTextAlignment(.leading)
						Text(module.phrases[phraseIndex].translatedText)
							.foregroundColor(themeManager.currentTheme.brightForBtnsText)
							.font(.system(size: 18, weight: .medium))
							.multilineTextAlignment(.leading)
//							.lineLimit(1)
					}
//					.padding()
					Spacer()
					HStack(spacing: 0) {
						Button {
							onSpeachTap?(phraseIndex)
							print("tap speach")
						} label: {
							Image(asset: Asset.Images.speach)
								.resizable()
                                .renderingMode(.template)
                                .colorMultiply(themeManager.currentTheme.mainText)
                                .opacity(themeManager.currentTheme.isDark ? 1 : 0.75)
								.frame(width: 30, height: 30)
//								.offset(x: -11, y: 5)
								.padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
						}
						Button {
							print("tap more")
							onEditTap?(phraseIndex)
						} label: {
							Image(systemName: "ellipsis")
							//								.resizable()
							//								.frame(width: 30, height: 30)
								.foregroundColor(themeManager.currentTheme.mainText)
								.rotationEffect(.degrees(90))
							//								.offset(y: 3)
								.scaleEffect(1.4)
								.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 8))
						}
					}
				}
				Color.clear
					.frame(height: module.phrases[phraseIndex].example != nil ? 5 : 1)
				if let example = module.phrases[phraseIndex].example, example.count > 0 {
					highlightSubstring(
                        module.phrases[phraseIndex].nativeText,
						in: example
					)
						.foregroundColor(themeManager.currentTheme.mainText)
						.multilineTextAlignment(.leading)
				} else {
					Button {
						onAddExampleTap?(phraseIndex)
					} label: {
						VStack(spacing: 5) {
							Text("Добавить пример".localize())
//								.foregroundColor(.white.opacity(0.9))
                                .foregroundColor(themeManager.currentTheme.mainText)
								.font(.system(size: 16, weight: .regular))
								.background {
									VStack {
										Spacer()
										Rectangle()
											.foregroundColor(themeManager.currentTheme.mainText)
//                                            .foregroundColor(.white.opacity(0.9))
											.frame(height: 1)
									}
									.offset(y: 5)
								}
						}
					}
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
				}
			}
			.padding()
		}
		.background {
			RoundedRectangle(cornerRadius: 20)
				.foregroundColor(themeManager.currentTheme.main)
//				.frame(width: width)
		}
	}
	
	func highlightSubstring(_ substring: String, in string: String) -> Text {
		guard let range = string.range(of: substring, options: [.caseInsensitive, .diacriticInsensitive]) else {
			return Text(string) // если подстрока не найдена, возвращаем исходный текст
		}
		let wordRange = string.rangeOfWord(containing: range)
		let prefix = string.prefix(upTo: wordRange.lowerBound)
		let highlightedSubstring = Text(string[wordRange]).foregroundColor(themeManager.currentTheme.findedWordsHighlited)
		let suffix = string.suffix(from: wordRange.upperBound)
		return Text(prefix) + highlightedSubstring + highlightSubstring(substring, in: String(suffix))
	}
}

struct WordCard_Previews: PreviewProvider {
    static var previews: some View {
		WordCard(
			width: 300,
			module: .constant(.init(name: "Test", emoji: "🔮")),
			phraseIndex: 0,
			onAddExampleTap: { _ in},
			onEditTap: { _ in },
			onSpeachTap: { _ in}
		)
    }
}
