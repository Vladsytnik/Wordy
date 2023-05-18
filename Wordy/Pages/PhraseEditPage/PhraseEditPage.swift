//
//  AddNewPhrase.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.01.2023.
//

import SwiftUI
import Combine

struct PhraseEditPage: View {
	
	//	let module: Module
	@Binding var modules: [Module]
	@Binding var filteredModules: [Module]
	@Binding var searchText: String
	
	@Environment(\.dismiss) private var dismiss
	@ObservedObject var viewModel = PhraseEditViewModel()
	
	init(
		modules: Binding<[Module]>,
		searchedText: Binding<String>,
		filteredModules: Binding<[Module]>,
		phraseIndex: Int,
		moduleIndex: Int
	) {
		self._modules = modules
		self._filteredModules = filteredModules
		self._searchText = searchedText
		viewModel.modules = modules.wrappedValue
		viewModel.searchedText = searchedText.wrappedValue
		viewModel.filteredModules = filteredModules.wrappedValue
		viewModel.modulesIndex = moduleIndex
		
		if moduleIndex < filteredModules.count {
			let index = filteredModules[moduleIndex].phrases.count - phraseIndex - 1
			viewModel.phraseIndex = index
			
			if moduleIndex >= 0 && index >= 0 {
				viewModel.nativePhrase = viewModel.filteredModules[moduleIndex].phrases[index].nativeText
				viewModel.translatedPhrase = viewModel.filteredModules[moduleIndex].phrases[index].translatedText
				viewModel.examplePhrase = viewModel.filteredModules[moduleIndex].phrases[index].example ?? ""
			}
		}
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
							Image(asset: Asset.Images.backButton)
								.resizable()
								.frame(width: 31, height: 31, alignment: .leading)
								.offset(x: -1)
						}
						Spacer()
					}
					Spacer()
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
					
					Rectangle()
						.foregroundColor(.clear)
						.frame(height: 30)
					
					if viewModel.isActivityProccess {
						LottieView(fileName: "addWordLoader")
							.frame(width: 80, height: 80)
							.offset(y: -30)
							.transition(.scale)
					} else {
						Button { savePhrase() } label: {
							HStack {
								Image(uiImage: UIImage(systemName: "checkmark") ?? UIImage())
									.renderingMode(.template)
									.foregroundColor(.white)
								Text("Сохранить")
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
			.gesture(
				DragGesture().onEnded{ value in
					print(value.translation.height)
					if value.translation.height > 0 {
						dismiss()
					}
				}
			)
			.showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showAlert) {
				savePhrase()
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
		.navigationBarHidden(true)
	}
	
	private func savePhrase() {
		viewModel.saveChanges(success: {
			dismiss()
		})
	}
}

struct PhraseEditPage_Previews: PreviewProvider {
	static var previews: some View {
		AddNewPhrase(
			modules: .constant([.init()]),
			searchedText: .constant(""),
			filteredModules: .constant([]),
			index: 0
		)
	}
}