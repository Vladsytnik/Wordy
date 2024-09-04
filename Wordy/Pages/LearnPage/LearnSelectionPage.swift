//
//  LearnSelectionPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.04.2023.
//

import SwiftUI
import AVFoundation

struct LearnSelectionPage: View {
	
	@EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
	@StateObject var viewModel: LearnSelectionPageViewModel
	@Environment(\.dismiss) private var dismiss
	
	@State var spacing: CGFloat = -100
	@State var textWidth: CGFloat = 500
	
	private var colors = [
		Color(asset: Asset.Colors.answer2),
		Color(asset: Asset.Colors.answer2),
		Color(asset: Asset.Colors.answer3),
		Color(asset: Asset.Colors.answer4)
	]
	
	@State var isAppear: Bool = false
    
    @State private var player: AVAudioPlayer? = AVAudioPlayer()
	
	init(module: Module, viewModel: LearnSelectionPageViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		ZStack {
			LearnBG()
			
			if viewModel.learningIsFinished {
				VStack {
					Spacer()
					VStack {
						Text("Ты молодец!".localize())
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 36, weight: .bold))
							.multilineTextAlignment(.center)
							.padding()
						Text("Еще один урок уже позади 🥳".localize())
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 28, weight: .medium))
							.multilineTextAlignment(.center)
					}
                    Spacer()
                    LottieView(fileName: "congeralations")
                        .onAppear {
//                            playEndOfLearningSound()
                        }
                    Spacer()
					CreateModuleButton(action: {
						dismiss()
                    }, text: "Супер!".localize())
					.frame(width: 200)
                    
					Spacer()
				}
			} else {
				VStack {
					if viewModel.showSuccessAnimation {
						LottieView(fileName: "success")
                            .onAppear {
//                                playCorrectAnswerSound()
                            }
                    }
				}
				.ignoresSafeArea()
				VStack {
					LearnBackButton()
						.opacity(0)
					Spacer()
					Text(viewModel.currentQuestion)
                        .foregroundColor(viewModel.inputTextAnsweredType == .notSelected ? themeManager.currentTheme.mainText : viewModel.inputTextAnsweredType == .correct ? .green : .red)
						.font(.system(size: 24, weight: .bold))
						.padding()
						.multilineTextAlignment(.center)
						.animation(.spring(), value: viewModel.inputTextAnsweredType)
					Spacer()
					if viewModel.currentPageType == .selectable {
						VStack(spacing: spacing) {
							ForEach(0..<viewModel.answersCount, id: \.self) { i in
								ZStack {
									RoundedRectangle(cornerRadius: 20)
										.foregroundColor(getColor(with: i))
										.frame(height: 80)
										.overlay {
											RoundedRectangle(cornerRadius: 20)
												.stroke()
												.foregroundColor(.white.opacity(0.1))
										}
										.padding(EdgeInsets(top: 0, leading: -1, bottom: 0, trailing: -1))
										.shadow(color: .black.opacity(0.24), radius: 26)
									Rectangle()
										.frame(height: 80)
										.foregroundColor(getColor(with: i))
										.offset(y: i != viewModel.currentAnswers.count - 1 ? 20 : 50)
									Text(viewModel.currentAnswers[i])
                                        .foregroundColor(viewModel.buttonSelected[i] ? viewModel.indexOfCorrectButton == i ? Color.green : Color.red : themeManager.currentTheme.mainText)
										.font(.system(size: 18, weight: .medium))
										.padding()
										.lineLimit(2)
										.animation(.spring(), value: viewModel.buttonSelected[i])
								}
								.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
								.onTapGesture {
									viewModel.userDidSelectAnswer(answer: viewModel.currentAnswers[i])
									viewModel.didTapButton(index: i)
								}
							}
						}
					}
					else {
						if viewModel.needOpenTextField {
							LearnTextField(
								placeholder: $viewModel.textFieldPLaceholder,
								text: $viewModel.inputText,
								needOpen: $viewModel.needOpenTextField,
								isFirstResponder: $viewModel.textFieldIsFirstResponder,
								closeKeyboard: .constant(false),
                                dontKnowText: $viewModel.dontKnowBtnText,
								onReturn: {
									viewModel.userDidSelectAnswer(answer: viewModel.inputText)
								}, onUserDoesntKnow : {
									viewModel.userDoesntKnow()
								}
							)
							.padding()
						} else {
							LearnTextField(
								placeholder: $viewModel.textFieldPLaceholder,
								text: $viewModel.inputText,
								needOpen: $viewModel.needOpenTextField,
								isFirstResponder: $viewModel.textFieldIsFirstResponder,
								closeKeyboard: .constant(true),
                                dontKnowText: $viewModel.dontKnowBtnText,
								onReturn: {
									viewModel.userDidSelectAnswer(answer: viewModel.inputText)
								}, onUserDoesntKnow : {
									viewModel.userDoesntKnow()
								}
							)
							.padding()
						}
						Spacer()
					}
				}
			}
			
			if viewModel.showDifferenceInFailure {
				if themeManager.currentTheme.isDark {
					Color.black
						.opacity(0.2)
						.ignoresSafeArea()
				} else {
					Color.white
						.opacity(0.2)
						.ignoresSafeArea()
				}
				
				VStack {
						VStack(alignment: .leading, spacing: 12) {
							VStack(alignment: .leading, spacing: 4) {
								HStack {
									Text("Вы ответили: ".localize())
										.bold()
										.font(.system(size: 18))
									Spacer()
								}
								
								HStack {
									Text(viewModel.answeredAttributedPhrase)
									Spacer()
								}
							}
							
							Divider()
							
							VStack(alignment: .leading, spacing: 4) {
								HStack {
									Text("Правильный ответ: ".localize())
										.font(.system(size: 18))
										.bold()
										.foregroundColor(.green)
									Spacer()
								}
								
								HStack {
									Text(viewModel.originalAttributedPhrase)
									Spacer()
								}
							}
							
							/*
							HStack {
								//							Spacer()
								HStack(alignment: .top) {
									VStack(alignment: .leading) {
										HStack {
											Text("Вы ответили: ")
												.multilineTextAlignment(.leading)
											Spacer()
										}
									}
									Text(viewModel.answeredAttributedPhrase)
									Spacer()
								}
								.foregroundColor(themeManager.currentTheme.mainText)
								Spacer()
							}
							
							
							HStack {
								//							Spacer()
								HStack(alignment: .top) {
									HStack {
										Text("Правильный ответ: ")
										Spacer()
									}
									Text(viewModel.originalAttributedPhrase)
									//						Text("Some some some long long long long long long long long long long long long long long long long long long long long long long long long long long long")
									Spacer()
								}
								.foregroundColor(themeManager.currentTheme.mainText)
								Spacer()
							}
							 */
						}
						.padding()
						.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
					
					HStack {
						Button {
							withAnimation {
								viewModel.flowCanContinue?()
							}
						} label: {
							HStack {
								Spacer()
								HStack {
									Image(systemName: "checkmark")
									Text("Готово".localize())
										.bold()
								}
								.foregroundColor(themeManager.currentTheme.mainText)
								Spacer()
							}
						}
					}
					.padding()
					.background(themeManager.currentTheme.accent.opacity(0.2))

				}
				.cornerRadius(24)
				.background {
					RoundedRectangle(cornerRadius: 24)
						.foregroundColor(themeManager.currentTheme.main)
						.clipped()
				}
				.padding()
//				.frame(maxHeight: 300)
				.shadow(radius: 30)
			}
			
			VStack {
				LearnBackButton()
				Spacer()
			}
			.opacity(viewModel.learningIsFinished ? 0 : 1)
		}
		.onAppear {
			withAnimation(Animation.spring()) {
				spacing = 0
			}
			if !viewModel.isAppeared {
				viewModel.start()
				viewModel.isAppeared = true
			}
			print("method onAppear")
			upCountOfFreeLearnMode()
		}
		.onChange(of: viewModel.needClosePage) { _ in
			dismiss()
		}
		.animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: viewModel.showDifferenceInFailure)
	}
	
	private func getColor(with index: Int) -> Color {
		let tempColors = [
			themeManager.currentTheme.answer1,
			themeManager.currentTheme.answer2,
			themeManager.currentTheme.answer3,
			themeManager.currentTheme.answer4
		]
		return tempColors[index]
	}
	
	private func upCountOfFreeLearnMode() {
		guard !subscriptionManager.isUserHasSubscription else { return }
		
		if let value = UserDefaultsManager.countOfStartingLearnModes[self.viewModel.module.id] {
			UserDefaultsManager.countOfStartingLearnModes[self.viewModel.module.id] = value + 1
		} else {
			UserDefaultsManager.countOfStartingLearnModes[self.viewModel.module.id] = 1
		}
	}
    
    private func playEndOfLearningSound() {
        guard let path = Bundle.main.path(forResource: "successFinishedLearning2", ofType : "m4r")
        else {
            print("Проблемы в пути к звуку")
            return
        }
        
        let url = URL(fileURLWithPath : path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            print("Play")
        } catch {
            print ("There is an issue with this code!")
        }
    }
    
    private func playCorrectAnswerSound() {
        guard let path = Bundle.main.path(forResource: "correctChose", ofType : "m4r")
        else {
            print("Проблемы в пути к звуку")
            return
        }
        
        let url = URL(fileURLWithPath : path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            print("Play")
        } catch {
            print ("There is an issue with this code!")
        }
    }
}


struct LearnTextField: View {
	
	@Binding var placeholder: String
	@Binding var text: String
	@Binding var needOpen: Bool
	@Binding var isFirstResponder: Bool
	@Binding var closeKeyboard: Bool
    @Binding var dontKnowText: String
	
	let fontSize: CGFloat = 20
	
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject var themeManager: ThemeManager
	
	@FocusState var isFocused: Bool
    
	
	var onReturn: (() -> Void)?
	var onUserDoesntKnow: (() -> Void)?
	
	var body: some View {
		VStack {
			ZStack(alignment: .leading) {
				HStack {
					if text.isEmpty {
						Text(placeholder)
							.foregroundColor(themeManager.currentTheme.mainText.opacity(0.3))
							.font(.system(size: fontSize, weight: .medium))
							.opacity(text.isEmpty ? 1 : 0)
                            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
					} else {
						Text(placeholder)
							.foregroundColor(themeManager.currentTheme.mainText.opacity(0.3))
							.font(.system(size: fontSize, weight: .medium))
							.opacity(text.isEmpty ? 1 : 0)
							.lineLimit(1)
                            .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
					}
					
					Spacer()
					
					if text.count == 0 {
						Text(dontKnowText)
							.foregroundColor(.clear)
							.font(.system(size: fontSize, weight: .medium))
					}
				}
				.animation(.spring(), value: text)
				HStack {
					TextField("", text: $text, onCommit: {
						onReturn?()
					})
					.foregroundColor(themeManager.currentTheme.mainText)
					.tint(themeManager.currentTheme.mainText)
					.font(.system(size: fontSize, weight: .medium))
					.focused($isFocused)
					//					.keyboardType(.twitter)
					if text.count > 0 && isFocused {
						Button {
							text = ""
						} label: {
                            if themeManager.currentTheme.isDark {
                                Image(asset: Asset.Images.plusIcon)
                                    .rotationEffect(.degrees(45))
                                    .opacity(isFocused ? 1 : 0)
                            } else {
                                Image(asset: Asset.Images.plusIcon)
                                    .renderingMode(.template)
                                    .rotationEffect(.degrees(45))
                                    .colorMultiply(themeManager.currentTheme.mainText)
                                    .opacity(themeManager.currentTheme.isDark ? 1 : 0.75)
                                    .opacity(isFocused ? 1 : 0)
                            }
						}
					}
					if isFocused && text.count == 0 {
						Button {
							onUserDoesntKnow?()
						} label: {
                            Text(dontKnowText)
                                .foregroundColor(themeManager.currentTheme.mainText.opacity(0.6))
								.font(.system(size: fontSize, weight: .medium))
						}
					}
				}
			}
			.onSubmit {
				return
			}
			.onAppear {
				isFocused = true
			}
			.onChange(of: isFocused) { newValue in
				isFirstResponder = newValue
				if !newValue {
					
				}
			}
			.onChange(of: needOpen) { newValue in
				if newValue {
					isFocused = true
					needOpen = false
				}
			}
			Rectangle()
				.foregroundColor(isFocused ? themeManager.currentTheme.mainText.opacity(1) : themeManager.currentTheme.mainText.opacity(0.2))
				.frame(height: 1)
				.animation(.default, value: isFocused)
		}
	}
}

struct LearnSelectionPage_Previews: PreviewProvider {
	static var previews: some View {
		LearnSelectionPage(module: .init(phrases: [
			.init(nativeText: "Обезьяна", translatedText: "Monkey", id: ""),
			.init(nativeText: "Солнце", translatedText: "Sun", id: ""),
			.init(nativeText: "Я знаю что это ничего", translatedText: "I know that it is nothing", id: ""),
			.init(nativeText: "хорошо ладить с кем то", translatedText: "Get on well with smbd", id: ""),
			.init(nativeText: "Вторник", translatedText: "Thusday", id: ""),
			.init(nativeText: "хорошо ладить с кем то", translatedText: "Get on well with smbd", id: "")
		]), viewModel: .init())
		.environmentObject(ThemeManager())
        .environmentObject(SubscriptionManager.shared)
	}
}

struct LearnBG: View {
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		themeManager.currentTheme.learnPageBackgroundImage
			.resizable()
			.edgesIgnoringSafeArea(.all)
	}
}

struct LearnBackButton: View {
	
    @EnvironmentObject var themeManager: ThemeManager
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		HStack {
			Button {
				dismiss()
			} label: {
                if themeManager.currentTheme.isDark {
                    Image(asset: Asset.Images.backButton)
                } else {
                    Image(asset: Asset.Images.backButton)
                        .renderingMode(.template)
                        .colorMultiply(themeManager.currentTheme.mainText)
                        .opacity(themeManager.currentTheme.isDark ? 1 : 0.75)
                }
			}
			.padding()
			Spacer()
		}
	}
}


// MARK: - WidthKey
//
//extension EqualWidthKey: EnvironmentKey { }
//
//struct EqualWidthKey: PreferenceKey {
//	static var defaultValue: CGFloat? { nil }
//
//	static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
//		switch (value, nextValue()) {
//		case (_, nil): break
//		case (nil, let next): value = next
//		case (let a?, let b?): value = max(a, b)
//		}
//	}
//}
//
//extension EnvironmentValues {
//	var equalWidth: CGFloat? {
//		get { self[EqualWidthKey.self] }
//		set { self[EqualWidthKey.self] = newValue }
//	}
//}
//
//struct EqualWidthModifier: ViewModifier {
//	var alignment: Alignment
//	@Environment(\.equalWidth) var equalWidth
//
//	func body(content: Content) -> some View {
//		return content
//			.background(
//				GeometryReader { proxy in
//					Color.clear
//						.preference(key: EqualWidthKey.self, value: proxy.size.width)
//				}
//			)
//			.frame(width: equalWidth, alignment: alignment)
//	}
//}
//
//extension View {
//	func equalWidth(alignment: Alignment) -> some View {
//		return self.modifier(EqualWidthModifier(alignment: alignment))
//	}
//}
//
//struct EqualWidthHost: ViewModifier {
//	@State var width: CGFloat? = nil
//
//	func body(content: Content) -> some View {
//		return content
//			.environment(\.equalWidth, width)
//			.onPreferenceChange(EqualWidthKey.self) { self.width = $0 }
//	}
//}
//
//extension View {
//	func equalWidthHost() -> some View {
//		return self.modifier(EqualWidthHost())
//	}
//}
