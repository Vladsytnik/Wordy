//
//  LearnSelectionPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.04.2023.
//

import SwiftUI

struct LearnSelectionPage: View {
	
	@StateObject var viewModel: LearnSelectionPageViewModel
	@Environment(\.dismiss) private var dismiss
	
	@State var spacing: CGFloat = -100
	
	private let colors = [
		Color(asset: Asset.Colors.answer1),
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
									.foregroundColor(colors[i])
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
									.foregroundColor(colors[i])
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
							placeholder: "Введите ваш ответ",
							text: $viewModel.inputText,
							needOpen: $viewModel.needOpenTextField,
							isFirstResponder: $viewModel.textFieldIsFirstResponder,
							closeKeyboard: .constant(false),
							onReturn: {
								viewModel.userDidSelectAnswer(answer: viewModel.inputText)
							}
						)
						.padding()
					} else {
						LearnTextField(
							placeholder: "Введите ваш ответ",
							text: $viewModel.inputText,
							needOpen: $viewModel.needOpenTextField,
							isFirstResponder: $viewModel.textFieldIsFirstResponder,
							closeKeyboard: .constant(true),
							onReturn: {
								viewModel.userDidSelectAnswer(answer: viewModel.inputText)
							}
						)
						.padding()
					}
					Spacer()
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
		}
		.onChange(of: viewModel.needClosePage) { _ in
			dismiss()
		}
	}
}


struct LearnTextField: View {
	
	let placeholder: String
	@Binding var text: String
	@Binding var needOpen: Bool
	@Binding var isFirstResponder: Bool
	@Binding var closeKeyboard: Bool
	
	let fontSize: CGFloat = 20
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState var isFocused: Bool
	
	var onReturn: (() -> Void)?
	
	var body: some View {
		VStack {
			ZStack(alignment: .leading) {
				Text(placeholder)
					.foregroundColor(.white.opacity(0.3))
					.font(.system(size: fontSize, weight: .medium))
					.opacity(text.isEmpty ? 1 : 0)
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
			.init(nativeText: "Обезьяна", translatedText: "Monkey"),
			.init(nativeText: "Солнце", translatedText: "Sun"),
			.init(nativeText: "Я знаю что это ничего", translatedText: "I know that it is nothing"),
			.init(nativeText: "хорошо ладить с кем то", translatedText: "Get on well with smbd"),
			.init(nativeText: "Вторник", translatedText: "Thusday"),
			.init(nativeText: "хорошо ладить с кем то", translatedText: "Get on well with smbd")
		]), viewModel: .init())
	}
}

struct LearnBG: View {
	var body: some View {
		Image(asset: Asset.Images.learnPageBG)
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


