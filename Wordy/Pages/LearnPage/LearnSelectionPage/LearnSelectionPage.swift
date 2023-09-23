//
//  LearnSelectionPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.04.2023.
//

import SwiftUI

struct LearnSelectionPage: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	@StateObject var viewModel: LearnSelectionPageViewModel
	@Environment(\.dismiss) private var dismiss
	
	@State var spacing: CGFloat = -100
	
	private var colors = [
		Color(asset: Asset.Colors.answer2),
		Color(asset: Asset.Colors.answer2),
		Color(asset: Asset.Colors.answer3),
		Color(asset: Asset.Colors.answer4)
	]
	
	@State var isAppear: Bool = false
	
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
						Text(LocalizedStringKey("Поздравляем!"))
							.foregroundColor(.white)
							.font(.system(size: 36, weight: .bold))
							.multilineTextAlignment(.center)
							.padding()
						Text(LocalizedStringKey("Ты прошел еще одну тренировку 🥳"))
							.foregroundColor(.white)
							.font(.system(size: 28, weight: .medium))
							.multilineTextAlignment(.center)
					}
					Spacer()
					LottieView(fileName: "congeralations")
					Spacer()
					CreateModuleButton(action: {
						dismiss()
					}, text: "Супер!")
					.frame(width: 200)
					Spacer()
				}
			} else {
				VStack {
					if viewModel.showSuccessAnimation {
						LottieView(fileName: "success")
					}
				}
				.ignoresSafeArea()
				VStack {
					LearnBackButton()
					Spacer()
					Text(viewModel.currentQuestion)
						.foregroundColor(viewModel.inputTextAnsweredType == .notSelected ? .white : viewModel.inputTextAnsweredType == .correct ? .green : .red)
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
										.foregroundColor(viewModel.buttonSelected[i] ? viewModel.indexOfCorrectButton == i ? Color.green : Color.red : .white)
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
		guard !UserDefaultsManager.userHasSubscription else { return }
		
		if let value = UserDefaultsManager.countOfStartingLearnModes[self.viewModel.module.id] {
			UserDefaultsManager.countOfStartingLearnModes[self.viewModel.module.id] = value + 1
		} else {
			UserDefaultsManager.countOfStartingLearnModes[self.viewModel.module.id] = 1
		}
	}
}


struct LearnTextField: View {
	
	@Binding var placeholder: String
	@Binding var text: String
	@Binding var needOpen: Bool
	@Binding var isFirstResponder: Bool
	@Binding var closeKeyboard: Bool
	
	let fontSize: CGFloat = 20
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState var isFocused: Bool
	
	var onReturn: (() -> Void)?
	var onUserDoesntKnow: (() -> Void)?
	
	var body: some View {
		VStack {
			ZStack(alignment: .leading) {
				HStack {
					if text.isEmpty {
						Text(placeholder)
							.foregroundColor(.white.opacity(0.3))
							.font(.system(size: fontSize, weight: .medium))
							.opacity(text.isEmpty ? 1 : 0)
					} else {
						Text(placeholder)
							.foregroundColor(.white.opacity(0.3))
							.font(.system(size: fontSize, weight: .medium))
							.opacity(text.isEmpty ? 1 : 0)
							.lineLimit(1)
					}
					
					Spacer()
					
					if text.count == 0 {
						Text(LocalizedStringKey("Не знаю"))
							.foregroundColor(.clear)
							.font(.system(size: fontSize, weight: .medium))
					}
				}
				.animation(.spring(), value: text)
				HStack {
					TextField("", text: $text, onCommit: {
						onReturn?()
					})
					.foregroundColor(.white)
					.tint(.white)
					.font(.system(size: fontSize, weight: .medium))
					.focused($isFocused)
					//					.keyboardType(.twitter)
					if text.count > 0 && isFocused {
						Button {
							text = ""
						} label: {
							Image(asset: Asset.Images.plusIcon)
								.rotationEffect(.degrees(45))
								.opacity(isFocused ? 1 : 0)
						}
					}
					if isFocused && text.count == 0 {
						Button {
							onUserDoesntKnow?()
						} label: {
							Text(LocalizedStringKey("Не знаю"))
								.foregroundColor(.white.opacity(0.6))
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
				.foregroundColor(isFocused ? .white.opacity(1) : .white.opacity(0.2))
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
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		HStack {
			Button {
				dismiss()
			} label: {
				Image(asset: Asset.Images.backButton)
			}
			.padding()
			Spacer()
		}
	}
}


