//
//  ModuleScreen.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import SwiftUI

struct ModuleScreen: View {
	
	@Binding var modules: [Module]
	@ObservedObject var viewModel = ModuleScreenViewModel()
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		Color.clear
			.background(content: {
				GeometryReader { geo in
					ZStack {
						ScrollView {
							VStack {
								Header(viewModel: viewModel)
								Color.clear
									.frame(height: 30)
								AddWordPlusButton { viewModel.showActionSheet = true }
									.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
								LearnModuleButton {  }
									.frame(height: 45)
									.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
								ForEach(0..<viewModel.phraseCount, id: \.self) { i in
									Button {
										viewModel.didTapWord(with: i)
									} label: {
										WordCard(
											width: geo.size.width - 60,
											modules: $modules,
											index: viewModel.index,
											phrase: viewModel.phrases[i]
										)
									}
									.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
								}
								AddWordButton { viewModel.showActionSheet = true }
								DeleteModuleButton { viewModel.didTapDeleteModule() }
							}
						}
						.frame(width: geo.size.width, height: geo.size.height)
					}
					.onChange(of: viewModel.modules) { newValue in
						self.modules = newValue
					}
					.fullScreenCover(isPresented: $viewModel.showActionSheet) {
						AddNewPhrase(modules: $modules, index: viewModel.index)
					}
				}
			})
			.background(BackgroundView())
			.navigationBarBackButtonHidden()
			.showAlert(title: "Удалить этот модуль?", description: "Это действие нельзя будет отменить", isPresented: $viewModel.showAlert, titleWithoutAction: "Отмена", titleForAction: "Удалить") {
				viewModel.nowReallyNeedToDeleteModule()
			}
			.fullScreenCover(isPresented: $viewModel.showWordsCarousel) {
				WordsCarouselView(modules: $modules, moduleIndex: viewModel.index, selectedWordIndex: viewModel.selectedWordIndex)
			}
			.activity($viewModel.showActivity)
			.onChange(of: viewModel.thisModuleSuccessfullyDeleted) { newValue in
				if newValue == true {
					dismiss()
				}
			}
			.showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showErrorAlert) {
				viewModel.nowReallyNeedToDeleteModule()
			}
	}
	
	init(modules: Binding<[Module]>, index: Int) {
		self._modules = modules
		viewModel.modules = modules.wrappedValue
		viewModel.index = index
	}
}

struct ModuleScreen_Previews: PreviewProvider {
	static var previews: some View {
		ModuleScreen(
			modules: .constant( [Module(name: "Test", emoji: "❤️‍🔥")]),
			index: 0
		)
	}
}

struct Header: View {
	
	@ObservedObject var viewModel: ModuleScreenViewModel
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		VStack(spacing: 7) {
			Rectangle()
				.foregroundColor(.clear)
				.frame(height: 20)
			ZStack {
				HStack {
					VStack {
						BackButton { dismiss() }
							.offset(y: 7)
						Spacer()
					}
					Spacer()
				}
				HStack {
					BackButton { dismiss() }
						.opacity(0)
					Spacer()
					Text(viewModel.module.name)
						.foregroundColor(.white)
						.font(.system(size: 36, weight: .bold))
						.lineLimit(1)
					Text(viewModel.module.emoji)
						.font(.system(size: 28))
						.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 24))
					Spacer()
				}
			}
			HStack(spacing: 18) {
				Text("4 ТЕРМИНА  /  15")
					.foregroundColor(.white)
					.font(.system(size: 13, weight: .medium))
				Button {
					
				} label: {
					Image(asset: Asset.Images.question)
						.resizable()
						.frame(width: 19, height: 19)
				}
				
			}
		}
	}
}

struct BackButton: View {
	
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			Image(asset: Asset.Images.backButton)
				.resizable()
				.frame(width: 31, height: 31)
				.padding(
					EdgeInsets(
						top: 0,
						leading: 16,
						bottom: 0,
						trailing: 0
					)
				)
		}
	}
}

struct AddWordPlusButton: View {
	
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			Image(asset: Asset.Images.addWordButton)
				.resizable()
				.frame(width: 60, height: 60)
		}
	}
}

struct LearnModuleButton: View {
	
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				Text("Выучить модуль")
					.foregroundColor(Color(asset: Asset.Colors.descrWordOrange))
					.font(.system(size: 18, weight: .bold))
					.padding(EdgeInsets(top: 16, leading: 26, bottom: 16, trailing: 26))
			}
			.background {
				Color(asset: Asset.Colors.lightPurple)
			}
			.cornerRadius(22)
		}
	}
}

struct AddWordButton: View {
	
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			RoundedRectangle(cornerRadius: 20)
				.frame(height: 60)
				.overlay {
					HStack {
						Image(asset: Asset.Images.plusIcon)
						Text("Добавить слово")
							.foregroundColor(.white)
							.font(.system(size: 18, weight: .medium))
					}
				}
				.foregroundColor (
					Color(asset: Asset.Colors.moduleCardBG)
				)
				.overlay {
					RoundedRectangle(cornerRadius: 20)
						.stroke()
						.foregroundColor(.white)
				}
				.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
		}
	}
}

struct DeleteModuleButton: View {
	
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			Text("Удалить модуль")
				.foregroundColor(.white)
				.font(.system(size: 16, weight: .regular))
				.frame(width: 300, height: 50)
				.offset(y: -15)
		}
		.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
	}
}



