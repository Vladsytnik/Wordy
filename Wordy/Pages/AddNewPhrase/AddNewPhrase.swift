//
//  AddNewPhrase.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.01.2023.
//

import SwiftUI
import Combine

struct AddNewPhrase: View {
	
//	let module: Module
	@Binding var modules: [Module]
	@Binding var filteredModules: [Module]
	@Binding var searchText: String
	
	@Environment(\.dismiss) private var dismiss
	@ObservedObject var viewModel = AddNewPhraseViewModel()
	
	init(modules: Binding<[Module]>, searchedText: Binding<String>, filteredModules: Binding<[Module]>, index: Int) {
		self._modules = modules
		self._filteredModules = filteredModules
		self._searchText = searchedText
		viewModel.modules = modules.wrappedValue
		viewModel.searchedText = searchedText.wrappedValue
		viewModel.filteredModules = filteredModules.wrappedValue
		viewModel.index = index
	}
	
	var body: some View {
		ZStack {
			ZStack {
				Color(asset: Asset.Colors.navBarPurple)
					.ignoresSafeArea()
				VStack(spacing: 20) {
					HStack {
						Button {
							dismiss()
						} label: {
							Text("Отменить")
								.foregroundColor(.white)
								.font(.system(size: 20, weight: .medium))
						}
						.padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
						Spacer()
					}
					
					CustomTextField(
						placeholder: "Apple",
						text: $viewModel.nativePhrase,
						enableFocuse: true,
						isFirstResponder: $viewModel.textFieldOneIsActive,
						closeKeyboard: $viewModel.closeKeyboards
					)
					.onTapGesture {
						viewModel.didTapTextField(index: 0)
					}
					.offset(x: !viewModel.nativePhraseIsEmpty ? 0 : 10)
					
					CustomTextField(
						placeholder: "Яблоко",
						text: $viewModel.translatedPhrase,
						enableFocuse: false,
						isFirstResponder: $viewModel.textFieldTwoIsActive,
						closeKeyboard: $viewModel.closeKeyboards
					)
					.onTapGesture {
						viewModel.didTapTextField(index: 1)
					}
					.offset(x: !viewModel.translatedPhraseIsEmpty ? 0 : 10)
					
					if viewModel.wasTappedAddExample {
						CustomTextField(
							placeholder: "I like apple",
							text: $viewModel.examplePhrase,
							enableFocuse: false,
							isFirstResponder: $viewModel.textFieldThreeIsActive,
							closeKeyboard: $viewModel.closeKeyboards
						)
						.onTapGesture {
							viewModel.didTapTextField(index: 1)
						}
						.offset(x: !viewModel.examplePhraseIsEmpty ? 0 : 10)
					} else {
						HStack {
							Button {
								viewModel.wasTappedAddExample.toggle()
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
									viewModel.didTapTextField(index: 2)
								}
							} label: {
								Text("Добавить пример использования")
									.foregroundColor(.white)
									.font(.system(size: 14, weight: .regular))
							}
							.background {
								VStack {
									Spacer()
									Rectangle()
										.frame(height: 1)
										.foregroundColor(.white)
								}
							}
							.padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
							Spacer()
						}
					}
					
					Rectangle()
						.foregroundColor(.clear)
						.frame(height: 30)

					if viewModel.isActivityProccess {
						LottieView(fileName: "addWordLoader")
							.frame(width: 80, height: 80)
							.offset(y: -30)
							.transition(.scale)
					} else {
						Button { addPhraseToModule() } label: {
							HStack {
								Image(uiImage: UIImage(systemName: "checkmark") ?? UIImage())
									.renderingMode(.template)
									.foregroundColor(.white)
								Text("Добавить")
									.foregroundColor(.white)
									.font(.system(size: 20, weight: .medium))
							}
						}
						.transition(.scale)
					}
					Spacer()
				}
				.onSubmit {
					return
				}
				.padding()
			}
			.onChange(of: viewModel.modules, perform: { newValue in
				self.modules = newValue
			})
			.onChange(of: viewModel.filteredModules, perform: { newValue in
				self.filteredModules = newValue
			})
			.offset(y: viewModel.swipeOffsetValue)
			.gesture(
				DragGesture().onEnded{ value in
					print(value.translation.height)
					if value.translation.height > 0 {
						dismiss()
					}
				}
			)
			.showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showAlert) {
				addPhraseToModule()
			}
			.onChange(of: viewModel.showAlert) { newValue in
				if !newValue {
					viewModel.textFieldOneIsActive = false
					viewModel.textFieldTwoIsActive = false
				}
		}
			if viewModel.isActivityProccess {
				Rectangle()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.foregroundColor(.white.opacity(0.00001))
			}
		}
		
	}
	
	private func addPhraseToModule() {
		viewModel.addWordToCurrentModule(success: {
			dismiss()
		})
	}
}

struct AddNewPhrase_Previews: PreviewProvider {
	static var previews: some View {
		AddNewPhrase(
			modules: .constant([.init()]),
			searchedText: .constant(""),
			filteredModules: .constant([]),
			index: 0
		)
	}
}

struct CustomTextField: View {
	
	let placeholder: String
	@Binding var text: String
	let enableFocuse: Bool
	@Binding var isFirstResponder: Bool
	@Binding var closeKeyboard: Bool
	
	let fontSize: CGFloat = 20
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState var isFocused: Bool
	
	var body: some View {
		VStack {
			ZStack(alignment: .leading) {
				Text(placeholder)
					.foregroundColor(.white.opacity(0.3))
					.font(.system(size: fontSize, weight: .medium))
					.opacity(text.isEmpty ? 1 : 0)
				HStack {
					TextField("", text: $text, onCommit: {
						return
					})
					.foregroundColor(.white)
					.tint(.white)
					.font(.system(size: fontSize, weight: .medium))
					.focused($isFocused)
					.keyboardType(.twitter)
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
				isFocused = enableFocuse ? true : false
			}
			.onChange(of: isFirstResponder) { newValue in
				if isFirstResponder {
					isFocused = true
				}
			}
			.onChange(of: closeKeyboard) { newValue in
				isFocused = false
			}
			Rectangle()
				.foregroundColor(isFocused ? .white.opacity(1) : .white.opacity(0.2))
				.frame(height: 1)
				.animation(.default, value: isFocused)
		}
	}
}
