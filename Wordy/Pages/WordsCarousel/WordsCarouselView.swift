//
//  WordsCarouselView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 08.02.2023.
//

import SwiftUI

struct WordsCarouselView: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	@State private var scrollOffset = CGFloat.zero
	@StateObject var viewModel = WordsCarouselViewModel()
	@Binding var module: Module
	@Environment(\.dismiss) private var dismiss
    
    private let selectedWordIndex: Int
	
	@StateObject var learnPageViewModel = LearnSelectionPageViewModel()
	@State var showLearnPage = false
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
	
	var body: some View {
		ZStack {
			themeManager.currentTheme.mainBackgroundImage
				.resizable()
				.ignoresSafeArea()
			VStack {
				VStack {
					HStack {
						BackButton {
							dismiss()
						}
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
						Spacer()
					}
					Text("\(viewModel.selectedWordIndex + 1)/\(module.phrases.count)")
						.foregroundColor(themeManager.currentTheme.mainText)
						.font(.system(size: 40, weight: .bold))
						.padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
				}
				Spacer()
				
				TabView(selection: $viewModel.selectedWordIndex) {
					ForEach(0..<module.phrases.count, id: \.self) { i in
//						CarouselCard(phrase: viewModel.phrases[viewModel.phrases.count - 1 - i],
//									 onDeletedTap: {
//							viewModel.didTapDeletePhrase(with: viewModel.phrases.count - 1 - i)
//						})
						CarouselCard(phrase: module.phrases[i],
									 onDeletedTap: {
                            viewModel.lastTappedPhraseIndexForDelete = i
                            withAnimation {
                                viewModel.deletePhrase = true
                            }
						})
							.padding(.leading)
							.padding(.trailing)
							.tag(i)
							.environmentObject(viewModel)
						
					}
				}
				.tabViewStyle(.page(indexDisplayMode: .never))
				
				Spacer(minLength: 50)
                LearnModuleButton(customBgColor: themeManager.currentTheme.carouselLearnBtnColor) {
					if module.phrases.count >= 4 {
						checkSubscriptionAndAccessability(module: module) { isAllow in
							if isAllow {
								learnPageViewModel.module = module
								showLearnPage.toggle()
							} else {
								viewModel.showPaywall()
							}
						}
					} else {
						viewModel.didTapShowLearnPage(module: module)
					}
				}
				.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
			}
		}
		.fullScreenCover(isPresented: $showLearnPage, content: {
			LearnSelectionPage(
				module: module,
				viewModel: learnPageViewModel
			)
		})
		.sheet(isPresented: $viewModel.isShowPaywall, content: {
			Paywall(isOpened: $viewModel.isShowPaywall)
		})
		.navigationBarBackButtonHidden()
		.onChange(of: scrollOffset) { newValue in
			print(newValue)
		}
		.onChange(of: showLearnPage, perform: { newValue in
			if !newValue {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					learnPageViewModel.clearAllProperties()
				}
			}
		})
        .onAppear {
            viewModel.selectedWordIndex = self.selectedWordIndex
        }
		.showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showAlert, titleWithoutAction: "OK", titleForAction: "", withoutButtons: true) {
			
		}
        .showAlert(title: "Удалить эту фразу?", description: "Это действие нельзя будет отменить", isPresented: $viewModel.deletePhrase, titleWithoutAction: "Удалить", titleForAction: "Отменить", withoutButtons: false, okAction: { viewModel.didTapDeletePhrase(module.phrases[viewModel.lastTappedPhraseIndexForDelete], module: module) }, repeatAction: {})
		.activity($viewModel.showActivity)
	}
	
    init(module: Binding<Module>, selectedWordIndex: Int) {
		self._module = module
        self.selectedWordIndex = selectedWordIndex
	}
	
    func checkSubscriptionAndAccessability(module: Module, isAllow: ((Bool) -> Void)) {
        let countOfStartingLearnMode = UserDefaultsManager.countOfStartingLearnModes[module.id] ?? 0
        isAllow(subscriptionManager.isUserHasSubscription
                || countOfStartingLearnMode < maxCountOfStartingLearnMode)
    }
    
	func didTapShowLearnPage() {
		if module.phrases.count >= 4 {
            isUserCanLearnModule { isAllow in
                if isAllow {
                    showLearnPage.toggle()
                } else {
                    viewModel.showPaywall()
                }
            }
		} else {
			let wordsCountDifference = 4 - module.phrases.count
            viewModel.alert.title = "Для изучения слов необходимо минимум 4 фразы".localize()
            viewModel.alert.description = "\nОсталось добавить еще".localize() + " \(viewModel.getCorrectWord(value: wordsCountDifference))!"
			withAnimation {
				self.viewModel.showAlert = true
			}
		}
	}
    
    func isUserCanLearnModule(isAllow: ((Bool) -> Void)) {
        let countOfStartingLearnMode =  UserDefaultsManager.countOfStartingLearnModes[module.id] ?? 0
        isAllow(subscriptionManager.isUserHasSubscription
                || (countOfStartingLearnMode < maxCountOfStartingLearnMode
                    && !module.isBlockedFreeFeatures)
                || module.acceptedAsStudent)
    }
}

struct CarouselCard: View {
	
	var phrase: Phrase
	var onDeletedTap: (() -> Void)
	@EnvironmentObject var viewModel: WordsCarouselViewModel
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		VStack {
			SpeachButton {
				viewModel.didTapSpeach(phrase: phrase)
			}
			Spacer()
			MainText(phrase: phrase)
			Spacer()
			Button {
				onDeletedTap()
            } label: {
                Text("УДАЛИТЬ".localize())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.currentTheme.mainText)
            }
		}
		.background{
			themeManager.currentTheme.carouselCardBackgroundImage
				.resizable()
				.padding(EdgeInsets(top: -24, leading: -24, bottom: -24, trailing: -24))
		}
		.padding(EdgeInsets(top: 24, leading: 32, bottom: 24, trailing: 32))
	}
	
}

struct WordsCarouselView_Previews: PreviewProvider {
	static var previews: some View {
		WordsCarouselView(module: .constant(
			Module(name: "Test",
				   emoji: "👻",
				   id: "400",
				   date: Date(),
				   phrases: [
					Phrase(nativeText: "Test", translatedText: "Test", id: "", date: Date()),
					Phrase(nativeText: "Test", translatedText: "Test", id: "", date: Date()),
					Phrase(nativeText: "Test", translatedText: "Test", id: "", date: Date()),
					Phrase(nativeText: "Test", translatedText: "Test", id: "", date: Date())
				   ])
		), selectedWordIndex: 0)
        .environmentObject(SubscriptionManager.shared)
	}
}

fileprivate struct SpeachButton: View {
	
    @EnvironmentObject var themeManager: ThemeManager
	var action: (() -> Void)?
	
	var body: some View {
		HStack {
			Spacer()
			Button {
				action?()
			} label: {
                if themeManager.currentTheme.isDark {
                    Image(asset: Asset.Images.speach)
                        .resizable()
                        .frame(width: 32, height: 32)
                } else {
                    Image(asset: Asset.Images.speach)
                        .resizable()
                        .renderingMode(.template)
                        .colorMultiply(themeManager.currentTheme.mainText)
                        .opacity(themeManager.currentTheme.isDark ? 1 : 0.9)
                        .frame(width: 32, height: 32)
                }
			}
		}
	}
}

fileprivate struct MainText: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	var phrase: Phrase
	
	var body: some View {
		VStack(spacing: 32) {
			VStack(spacing: 10) {
				Text(phrase.nativeText)
					.foregroundColor(themeManager.currentTheme.mainText)
					.font(.system(size: 32, weight: .bold))
					.multilineTextAlignment(.center)
					.minimumScaleFactor(0.5)
				Text(phrase.translatedText)
					.foregroundColor(themeManager.currentTheme.brightForBtnsText)
					.font(.system(size: 18, weight: .medium))
					.multilineTextAlignment(.center)
					.minimumScaleFactor(0.5)
			}
			if phrase.example == nil {
//                Text("Здесь может быть пример употребления фразы".localize())
//					.foregroundColor(themeManager.currentTheme.mainText)
//					.font(.system(size: 18))
//					.multilineTextAlignment(.center)
//					.minimumScaleFactor(0.6)
			} else {
				highlightSubstring(phrase.nativeText, in: phrase.example ?? "")
					.foregroundColor(themeManager.currentTheme.mainText)
					.font(.system(size: 18))
					.multilineTextAlignment(.center)
					.minimumScaleFactor(0.6)
			}
			
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
