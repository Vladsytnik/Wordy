//
//  ModuleScreen.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import SwiftUI

struct ModuleScreen: View {
	
	@Binding var modules: [Module]
	@Binding var filteredModules: [Module]
	@Binding var searchText: String
	@ObservedObject var viewModel = ModuleScreenViewModel()
	@StateObject var learnPageViewModel = LearnSelectionPageViewModel()
	@State var showLearnPage = false
	@State var showEditAlert = false
	
	private let countOfWordsForFree = 15
	
	@State var currentEditPhraseIndex = 0
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var showInfoAlert = false
	@EnvironmentObject var themeManager: ThemeManager
	
	@State private var scrollOffset = CGFloat.zero
	@State private var scrollDirection = CGFloat.zero
	@State private var prevScrollOffsetValue = CGFloat.zero
	@State private var createPhraseButtonOpacity = 1.0
	
	var body: some View {
		Color.clear
			.background(content: {
				GeometryReader { geo in
					ZStack {
						if viewModel.showEditPhrasePage {
							NavigationLink(
								destination: PhraseEditPage(
									modules: $modules,
									searchedText: $searchText,
									filteredModules: $filteredModules,
									phraseIndex: viewModel.phraseIndexForEdit,
									moduleIndex: viewModel.index
								),
								isActive: $viewModel.showEditPhrasePage
							) {
								EmptyView()
							}
							.hidden()
						}
						ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
							VStack {
								Header(viewModel: viewModel, showAlert: $showInfoAlert, module: viewModel.module)
								//								Color.clear
								//									.frame(height: 30)
								Text(viewModel.module.emoji)
									.font(.system(size: 28))
								//									.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 24))
								if viewModel.module.phrases.count > 0 {
									AddWordPlusButton {
										didTapShareModule()
									}
									.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
									LearnModuleButton {
										if viewModel.module.phrases.count >= 4 {
											viewModel.checkSubscriptionAndAccessability { isAllow in
												if isAllow {
													learnPageViewModel.module = viewModel.module
													showLearnPage.toggle()
												} else {
													viewModel.showPaywall()
												}
											}
										} else {
											viewModel.didTapPhraseCountAlert()
										}
									}
									.frame(height: 45)
									.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
								}
								
								ForEach(0..<viewModel.phraseCount, id: \.self) { i in
									Button {
										viewModel.didTapWord(with: i)
									} label: {
										WordCard(
											width: geo.size.width - 60,
											modules: $filteredModules,
											index: viewModel.index,
											phrase: viewModel.phrases[i],
											phraseIndex: i,
											onAddExampleTap: { index in
												viewModel.didTapAddExample(index: index)
											},
											onEditTap: { index in
												currentEditPhraseIndex = index
												showEditAlert.toggle()
											}, onSpeachTap: { index in
												viewModel.didTapSpeach(index: index)
											} )
									}
									.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
								}
//								AddWordButton { didTapAddNewPhrase() }
								
								if viewModel.module.phrases.count > 0 {
									DeleteModuleButton { viewModel.didTapDeleteModule() }
								}
								
								Rectangle()
									.frame(height: 55)
									.foregroundColor(.clear)
							}
						}
						.frame(width: geo.size.width, height: geo.size.height)
						.onChange(of: scrollOffset) { newValue in
							calculateScrollDirection()
						}
						
						VStack {
							Spacer()
							AddWordButton { didTapAddNewPhrase() }
							.opacity(createPhraseButtonOpacity)
							.transition(AnyTransition.offset() )
							.offset(y: geo.size.height < 812 ? -16 : 0 )
							.shadow(color: .white.opacity(0.2), radius: 20)
						}
						.ignoresSafeArea(.keyboard)
						
						if viewModel.module.phrases.count == 0 {
							EmptyBGView()
						}
					}
					.onChange(of: viewModel.modules) { newValue in
						self.modules = newValue
					}
					.onChange(of: viewModel.filteredModules) { newValue in
						self.filteredModules = newValue
					}
					.fullScreenCover(isPresented: $viewModel.showActionSheet) {
						AddNewPhrase(modules: $modules, searchedText: $searchText, filteredModules: $filteredModules, index: viewModel.index)
					}
				}
			})
			.background(BackgroundView())
			.navigationBarBackButtonHidden()
			.showAlert(title: "Удалить этот модуль?", description: "Это действие нельзя будет отменить", isPresented: $viewModel.showAlert, titleWithoutAction: "Отменить", titleForAction: "Удалить") {
				viewModel.nowReallyNeedToDeleteModule()
			}
			.fullScreenCover(isPresented: $viewModel.showWordsCarousel) {
				WordsCarouselView(
					modules: $modules,
					filteredModules: $filteredModules,
					moduleIndex: viewModel.index,
					selectedWordIndex: viewModel.selectedWordIndex
				)
			}
			.fullScreenCover(isPresented: $showLearnPage, content: {
				LearnSelectionPage(
					module: viewModel.module,
					viewModel: learnPageViewModel
				)
			})
			.onChange(of: showLearnPage, perform: { newValue in
				if !newValue {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
						learnPageViewModel.clearAllProperties()
					}
				}
			})
			.actionSheet(isPresented: $showEditAlert, content: {
				ActionSheet(
					title: Text(""),
					message: Text(LocalizedStringKey("Выберите действие"))
						.bold(),
					buttons: [
						.default(Text(LocalizedStringKey("Изменить")), action: {
							viewModel.didTapAddExample(index: currentEditPhraseIndex)
						}),
						.destructive(Text(LocalizedStringKey("Удалить")), action: {
							viewModel.didTapDeletePhrase(with: currentEditPhraseIndex)
						}),
						.cancel(Text(LocalizedStringKey("Отменить")), action: {
							
						})
					])
			})
			.sheet(isPresented: $viewModel.isShowPaywall, content: {
				Paywall(isOpened: $viewModel.isShowPaywall)
			})
			.activity($viewModel.showActivity)
			.onChange(of: viewModel.thisModuleSuccessfullyDeleted) { newValue in
				if newValue == true {
					dismiss()
				}
			}
			.showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showErrorAlert) {
				viewModel.nowReallyNeedToDeleteModule()
			}
			.showAlert(title: "💡 Правило\n пятнадцати слов", description: "\nНаш мозг устроен таким образом, \nчто информация усваивается \nболее эффективно, если она \nразделена на порции. \n\n 15 – это та самая порция, которая \nявляется оптимальной \nдля запоминания слов 🧠", isPresented: $showInfoAlert, titleWithoutAction: "Буду знать!", withoutButtons: true) {
				
			}
			.showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showErrorAboutPhraseCount, withoutButtons: true) {
				
			}
	}
	
	init(modules: Binding<[Module]>, searchedText: Binding<String>, filteredModules: Binding<[Module]>, index: Int) {
		self._modules = modules
		self._filteredModules = filteredModules
		self._searchText = searchedText
		viewModel.modules = modules.wrappedValue
		viewModel.filteredModules = filteredModules.wrappedValue
		viewModel.index = index
	}
	
	private func calculateScrollDirection() {
		if scrollOffset > 10 {
			scrollDirection = scrollOffset - prevScrollOffsetValue
			prevScrollOffsetValue = scrollOffset
		}
		withAnimation {
			if scrollDirection < 0 || scrollOffset < 10 {
				createPhraseButtonOpacity = 1
			} else {
				createPhraseButtonOpacity = 0
			}
		}
	}
	
	func didTapAddNewPhrase() {
		if viewModel.phrases.count < countOfWordsForFree || UserDefaultsManager.userHasSubscription {
			viewModel.showActionSheet = true
		} else {
			viewModel.showPaywall()
		}
	}
	
	func didTapShareModule() {
		
	}
}

struct ModuleScreen_Previews: PreviewProvider {
	static var previews: some View {
		ModuleScreen(
			modules: .constant( [Module(name: "Test", emoji: "❤️‍🔥")]),
			searchedText: .constant(""),
			filteredModules: .constant([Module(name: "Test", emoji: "❤️‍🔥")]),
			index: 0
		)
		.environmentObject(ThemeManager())
	}
}

struct Header: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	@ObservedObject var viewModel: ModuleScreenViewModel
	@Environment(\.dismiss) var dismiss
	
	@Binding var showAlert: Bool
	let module: Module
	//	private var alertText = ""
	
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
						.foregroundColor(themeManager.currentTheme.mainText)
						.font(.system(size: 36, weight: .bold))
						.multilineTextAlignment(.center)
					//						.lineLimit(1)
					//					VStack {
					//						Spacer()
					//						Text(viewModel.module.emoji)
					//							.font(.system(size: 28))
					//							.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 24))
					//					}
					Spacer()
					BackButton { dismiss() }
						.opacity(0)
				}
			}
			HStack(spacing: 18) {
				Text("\(module.phrases.count)  /  15")
					.foregroundColor(themeManager.currentTheme.mainText)
					.font(.system(size: 13, weight: .medium))
				Button {
					withAnimation {
						showAlert.toggle()
					}
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
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		Button {
			action()
		} label: {
//			Image(asset: Asset.Images.addWordButton)
//				.resizable()
			RoundedRectangle(cornerRadius: 26)
				.frame(width: 60, height: 60)
				.foregroundColor(themeManager.currentTheme.main)
				.overlay {
//					Image(asset: Asset.Images.addWordButton)
					Image(systemName: "square.and.arrow.up")
						.scaleEffect(1.3)
						.offset(y: -2)
						.foregroundColor(themeManager.currentTheme.mainText)
				}
		}
	}
}

struct LearnModuleButton: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				Text(LocalizedStringKey("Выучить модуль"))
					.foregroundColor(themeManager.currentTheme.learnModuleBtnText)
					.font(.system(size: 18, weight: .bold))
					.padding(EdgeInsets(top: 16, leading: 26, bottom: 16, trailing: 26))
			}
			.background {
				themeManager.currentTheme.accent
			}
			.cornerRadius(22)
		}
	}
}

struct AddWordButton: View {
	
	@EnvironmentObject var themeManager: ThemeManager
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
						Text(LocalizedStringKey("Добавить слово"))
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 18, weight: .medium))
					}
				}
				.foregroundColor (
					themeManager.currentTheme.moduleCreatingBtn
				)
				.overlay {
					RoundedRectangle(cornerRadius: 20)
						.stroke()
						.foregroundColor(themeManager.currentTheme.mainText)
				}
				.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
		}
	}
}

struct DeleteModuleButton: View {
	
	let action: () -> Void
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		Button {
			action()
		} label: {
			Text(LocalizedStringKey("Удалить модуль"))
				.foregroundColor(themeManager.currentTheme.mainText)
				.font(.system(size: 16, weight: .regular))
				.frame(width: 300, height: 50)
				.offset(y: -15)
		}
		.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
	}
}



