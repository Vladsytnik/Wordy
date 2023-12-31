//
//  ModuleScreen.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import SwiftUI
import SwiftUITooltip

struct ModuleScreen: View {
	
	@EnvironmentObject var subscriptionManager: SubscriptionManager
	
	@Binding var modules: [Module]
	@Binding var filteredModules: [Module]
	@Binding var searchText: String
	@ObservedObject var viewModel = ModuleScreenViewModel()
	@StateObject var learnPageViewModel = LearnSelectionPageViewModel()
	@State var showLearnPage = false
	@State var showEditAlert = false
    
    @StateObject private var onboardingManager = OnboardingManager(screen: .moduleScreen, 
                                                                   countOfSteps: 2)
    
    var addNewPhraseViewModel = AddNewPhraseViewModel()
	
	private let countOfWordsForFree = 15
	
	@State var currentEditPhraseIndex = 0
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var showInfoAlert = false
	@EnvironmentObject var themeManager: ThemeManager
	
	@State private var scrollOffset = CGFloat.zero
	@State private var scrollDirection = CGFloat.zero
	@State private var prevScrollOffsetValue = CGFloat.zero
	@State private var createPhraseButtonOpacity = 1.0
	@State var showActivity = false
    
    @State var screenWidth = 0
    
    @State private var showChangeModuleDataScreen = false
    @State private var emoji = ""
    @State private var moduleName = ""
    
    @State var isShared = false
    @State var userIsReallyShared = false

    lazy var currentThemeName: String?  = {
        UserDefaultsManager.themeName
    }()
	
	
	var body: some View {
//		Color.clear
//			.background(content: {
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
//						ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
						ScrollView {
                            VStack {
                                if isShared || viewModel.module.isSharedByTeacher {
                                    HStack(spacing: 6) {
                                        Image(systemName: "network")
                                        Text("Опубликован".localize())
                                    }
                                    .foregroundColor(themeManager.currentTheme.mainText.opacity(0.6))
                                    .padding(EdgeInsets(top: 8, leading: 0, bottom: -22, trailing: 0))
                                }
                                
//                                if viewModel.module.acceptedAsStudent {
//                                    HStack(spacing: 6) {
//                                        Text("Student Mode".localize())
//                                    }
//                                    .foregroundColor(themeManager.currentTheme.mainText.opacity(0.6))
//                                    .padding(EdgeInsets(top: 8, leading: 0, bottom: -22, trailing: 0))
//                                }
                                
								Header(viewModel: viewModel,
                                       showChangeModuleDataScreen: $showChangeModuleDataScreen,
                                       showAlert: $showInfoAlert,
                                       moduleName: $moduleName,
                                       isShared: $isShared, 
                                       module: viewModel.module,
                                       withoutBackButton: true)
								//								Color.clear
								//									.frame(height: 30)
                                
                                Button {
                                    showChangeModuleDataScreen.toggle()
                                } label: {
                                    Text(emoji)
                                        .padding(EdgeInsets(top: 7, leading: 0, bottom: 0, trailing: 0))
                                        .font(.system(size: 28))
                                }

//								Text(emoji)
//                                    .padding(EdgeInsets(top: 7, leading: 0, bottom: 0, trailing: 0))
//									.font(.system(size: 28))
//                                    .onTapGesture {
//                                        showChangeModuleDataScreen.toggle()
//                                    }
								//									.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 24))
                                
								if viewModel.module.phrases.count > 0 {
									AddWordPlusButton {
										didTapShareModule()
									}
									.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                                    
									LearnModuleButton {
                                        onboardingManager.goToNextStep()
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
                                    .mytooltip(onboardingManager.currentStepIndex == 0 
                                               && viewModel.userDidntSeeLearnBtnYet()
                                               && viewModel.phrases.count >= 4,
                                               config: nil,
                                               appearingDelayValue: 0.5) {
                                        let text = "Используйте обучающий режим, \nчтобы эффективнее запоминать фразы".localize()
                                        let descr = "Доступен при добавлении в модуль 4 фраз".localize()
                                        TooltipView(text: text,
                                                    stepNumber: 0,
                                                    allStepCount: 1, 
                                                    withoutSteps: true,
                                                    description: descr,
                                                    onDisappear: {
                                            UserDefaultsManager.isUserSawLearnButton = true
                                        }) {
                                            onboardingManager.goToNextStep()
                                        }
                                                    .frame(width: geo.size.width - 96)

                                    }
                                    .zIndex(100)
								}
								
								ForEach(0..<viewModel.phraseCount, id: \.self) { i in
									Button {
//										viewModel.didTapWord(with: i)
//                                        onboardingManager.goToNextStep()
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
                                        .onTapGesture {
                                            viewModel.didTapWord(with: i)
                                            onboardingManager.goToNextStep()
                                        }
                                        .onLongPressGesture {
                                            currentEditPhraseIndex = i
                                            showEditAlert.toggle()
                                        }
									}
									.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
								}
//								AddWordButton { didTapAddNewPhrase() }
								
								if viewModel.module.phrases.count > 0 {
									DeleteModuleButton { viewModel.didTapDeleteModule() }
                                        .padding(.bottom)
								}
								
								Rectangle()
									.frame(height: 55)
									.foregroundColor(.clear)
                                
                                if viewModel.module.phrases.count == 0 {
                                    EmptyBGView()
                                }
							}
                            .animation(.spring, value: isShared)
						}
						.frame(width: geo.size.width, height: geo.size.height)
						.onChange(of: scrollOffset) { newValue in
							calculateScrollDirection()
						}
						
						VStack {
							Spacer()
                            
                            if viewModel.module.phrases.count == 0 {
                                DeleteModuleButton { viewModel.didTapDeleteModule() }
                            }
                            
                            AddWordButton {
                                didTapAddNewPhrase()
                                onboardingManager.goToNextStep()
                            }
							.opacity(createPhraseButtonOpacity)
							.transition(AnyTransition.offset() )
							.offset(y: geo.size.height < 812 ? -16 : 0 )
							.shadow(color: .white.opacity(0.2), radius: 20)
                            .mytooltip(onboardingManager.currentStepIndex == 1
                                       && viewModel.userDidntSeeCreatePhrase(),
                                       side: .top,
                                       offset: 24,
                                       config: nil,
                                       appearingDelayValue: 0.5) {
                                let text = "Добавьте свою первую фразу!".localize()
                                let descr = "ИИ автоматически переведет ее, \nа также покажет примеры \nиспользования в тексте.".localize()
                                TooltipView(text: text,
                                            stepNumber: 1,
                                            allStepCount: 2,
                                            withoutSteps: true,
                                            description: descr,
                                            onDisappear: {
                                    UserDefaultsManager.isUserSawCreateNewPhrase = true
                                }) {
                                    onboardingManager.goToNextStep()
                                }
                                            .frame(width: geo.size.width - 96)

                            }
                            .zIndex(100)
						}
						.ignoresSafeArea(.keyboard)
						
                        
//                        if showEmojiView {
////                            EmojiView(show: $showEmojiView, txt: $emoji)
//                            ZStack {
//                                EmojiPopoverView(showEmojiView: $showEmojiView, emoji: $emoji)
//                                VStack(alignment: .trailing) {
//                                    Spacer()
//                                    Button {
//                                        showEmojiView.toggle()
//                                    } label: {
//                                        Text("Готово")
//                                            .bold()
//                                            .padding(EdgeInsets(top: 12, leading: 30, bottom: 12, trailing: 30))
//                                            .foregroundColor(themeManager.currentTheme.mainText)
//                                            .background {
//                                                RoundedRectangle(cornerRadius: 15)
//                                                    .foregroundColor(themeManager.currentTheme.accent)
//                                            }
//                                            .opacity(0.95)
//                                    }
//                                }
//                                .padding()
//                                .offset(y: -64)
//                            }
//                        }
					}
                    .showAlert(title: "Удалить этот модуль?", description: "Это действие нельзя будет отменить", isPresented: $viewModel.showAlert, titleWithoutAction: "Отменить", titleForAction: "Удалить") {
                        viewModel.nowReallyNeedToDeleteModule()
                    }
                    .showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showDeletingErrorAlert) {
                        viewModel.nowReallyNeedToDeleteModule()
                    }
                    .showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showOkAlert, withoutButtons: true) {
                        viewModel.nowReallyNeedToDeleteModule()
                    }
                    .showAlert(title: "💡 Правило\n пятнадцати слов", description: "\nНаш мозг устроен таким образом, \nчто информация усваивается \nболее эффективно, если она \nразделена на порции. \n\n 15 – это та самая порция, которая \nявляется оптимальной \nдля запоминания слов 🧠", isPresented: $showInfoAlert, titleWithoutAction: "Буду знать!", withoutButtons: true) {
                        
                    }
                    .showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showErrorAboutPhraseCount, withoutButtons: true) {
                    }
					.onChange(of: viewModel.modules) { newValue in
						self.modules = newValue
					}
					.onChange(of: viewModel.filteredModules) { newValue in
						self.filteredModules = newValue
					}
					.fullScreenCover(isPresented: $viewModel.showActionSheet) {
						AddNewPhrase(modules: $modules, 
                                     filteredModules: $filteredModules,
                                     searchText: $searchText,
                                     index: viewModel.index)
                            .environmentObject(addNewPhraseViewModel)
					}
				}
//			})
			.background(BackgroundView())
//			.navigationBarBackButtonHidden()
//            .navigationTitle("Module name")
            .navigationBarTitleDisplayMode(.inline)
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
					message: Text("Выберите действие".localize())
						.bold(),
					buttons: [
						.default(Text("Изменить".localize()), action: {
							viewModel.didTapAddExample(index: currentEditPhraseIndex)
						}),
						.destructive(Text("Удалить".localize()), action: {
							viewModel.didTapDeletePhrase(with: currentEditPhraseIndex)
						}),
						.cancel(Text("Отменить".localize()), action: {
							
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
            .onChange(of: userIsReallyShared) { newValue in
                if newValue {
                    self.needToUpdateTeacherMode()
                }
            }
			.background {
                UIKitActivityView(isPresented: $showActivity,
                                  userIsReallyShared: $userIsReallyShared,
								  data: [viewModel.getShareUrl()],
//								  data: [URL(string: "https://wordy.onelink.me/HpCP/s3t4ujfk")!],
								  subject: nil,
								  message: nil)
			}
            .onAppear {
                self.emoji = viewModel.module.emoji
                self.moduleName = viewModel.module.name
            }
            .navigationBarItems(
                trailing:
                    Button(action: {
                        showChangeModuleDataScreen.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(themeManager.currentTheme.mainText)
                    }
            )
            .sheet(isPresented: $showChangeModuleDataScreen) {
                if #available(iOS 16.0, *) {
                    ChangeModulePage(module:viewModel.module,
                                     moduleName: $moduleName,
                                     emoji: $emoji)
                    .presentationDetents([.medium])
                } else {
                    ChangeModulePage(module:viewModel.module,
                                     moduleName: $moduleName,
                                     emoji: $emoji)
                }
            }
            
	}
	
	init(modules: Binding<[Module]>, searchedText: Binding<String>, filteredModules: Binding<[Module]>, index: Int) {
		self._modules = modules
		self._filteredModules = filteredModules
		self._searchText = searchedText
		viewModel.modules = modules.wrappedValue
		viewModel.filteredModules = filteredModules.wrappedValue
		viewModel.index = index
        
//        if let currentThemeName {
//            guard let theme = ThemeManager().allThemes().first(where: { $0.id == currentThemeName })
//            else { return }
//            if !theme.isDark {
//                let navigationBarAppearance = UINavigationBarAppearance()
//                navigationBarAppearance.backgroundColor = UIColor(theme.main)
//                UINavigationBar.appearance().standardAppearance = navigationBarAppearance
//            }
//        }
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
		if viewModel.phrases.count < countOfWordsForFree || SubscriptionManager().userHasSubscription() {
			viewModel.showActionSheet = true
		} else {
			viewModel.showPaywall()
		}
	}
	
	func didTapShareModule() {
        showActivity.toggle()
	}
    
    func needToUpdateTeacherMode() {
        userIsReallyShared = false
        viewModel.setToModuleTeacherMode {
            viewModel.setToModuleTeacherMode {
                isShared = true
            }
        }
    }
}

struct ModuleScreen_Previews: PreviewProvider {
	static var previews: some View {
		ModuleScreen(
			modules: .constant( [Module(name: "Test", emoji: "❤️‍🔥", phrases: [
				.init(nativeText: "Test", translatedText: "Test", id: "1")
			])]),
			searchedText: .constant(""),
			filteredModules: .constant([Module(name: "Test", emoji: "❤️‍🔥", phrases: [
				.init(nativeText: "Test", translatedText: "Test", id: "1")
			])]),
			index: 0
		)
		.environmentObject(ThemeManager())
		.environmentObject(SubscriptionManager())
	}
}

struct Header: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	@ObservedObject var viewModel: ModuleScreenViewModel
	@Environment(\.dismiss) var dismiss
	
    @Binding var showChangeModuleDataScreen: Bool
	@Binding var showAlert: Bool
    @Binding var moduleName: String
    @Binding var isShared: Bool
	let module: Module
    var withoutBackButton = false
	
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
                            .opacity(withoutBackButton ? 0 : 1)
						Spacer()
					}
					Spacer()
				}
				HStack {
					BackButton { dismiss() }
						.opacity(0)
					Spacer()
                    
                    Button {
                        showChangeModuleDataScreen.toggle()
                    } label: {
                        Text(moduleName)
                            .foregroundColor(themeManager.currentTheme.mainText)
                            .font(.system(size: 36, weight: .bold))
                            .multilineTextAlignment(.center)
                    }

//					Text(moduleName)
//						.foregroundColor(themeManager.currentTheme.mainText)
//						.font(.system(size: 36, weight: .bold))
//						.multilineTextAlignment(.center)
//                        .onTapGesture {
//                            showChangeModuleDataScreen.toggle()
//                        }
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
            
            Button {
                withAnimation {
                    showAlert.toggle()
                }
            } label: {
                HStack(spacing: 18) {
                    Text("\(module.phrases.count)  /  15")
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .font(.system(size: 13, weight: .medium))
                    
                    Image(asset: Asset.Images.question)
                        .resizable()
                        .renderingMode(.template)
                        .colorMultiply(themeManager.currentTheme.mainText)
                        .opacity(themeManager.currentTheme.isDark ? 1 : 0.75)
                        .frame(width: 15, height: 15)
                }
                .padding()
            }
            .padding(EdgeInsets(top: -8, leading: 0, bottom: -8, trailing: 0))
        }
	}
}

struct BackButton: View {
	
    @EnvironmentObject var themeManager: ThemeManager
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
            if themeManager.currentTheme.isDark {
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
            } else {
                Image(asset: Asset.Images.backButton)
                    .resizable()
                    .renderingMode(.template)
                    .colorMultiply(themeManager.currentTheme.mainText)
                    .opacity(themeManager.currentTheme.isDark ? 1 : 0.75)
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
						.scaleEffect(1.5)
						.offset(y: -2)
						.foregroundColor(themeManager.currentTheme.mainText)
				}
		}
	}
}

struct UIKitActivityView: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
    @Binding var userIsReallyShared: Bool
	
	let data: [Any]
	let subject: String?
	let message: String?
	
	func makeUIViewController(context: Context) -> UIViewController {
		HolderViewController(control: self)
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		let activityViewController = UIActivityViewController(
			activityItems: data,
			applicationActivities: nil
		)
		
		if isPresented && uiViewController.presentedViewController == nil {
			uiViewController.present(activityViewController, animated: true)
		}
		
		activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            if completed {
                userIsReallyShared = true
            }
			isPresented = false
		}
	}
	
	class HolderViewController: UIViewController, UIActivityItemSource {
		private let control: UIKitActivityView
		
		init(control: UIKitActivityView) {
			self.control = control
			super.init(nibName: nil, bundle: nil)
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
			control.message ?? ""
		}
		
		func activityViewController(_ activityViewController: UIActivityViewController,
									itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
			control.message
		}
		
		func activityViewController(_ activityViewController: UIActivityViewController,
									subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
			control.subject ?? ""
		}
	}
}

struct LearnModuleButton: View {
	
    var customBgColor: Color?
	@EnvironmentObject var themeManager: ThemeManager
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				Text("Выучить модуль".localize())
					.foregroundColor(themeManager.currentTheme.learnModuleBtnText)
					.font(.system(size: 18, weight: .bold))
					.padding(EdgeInsets(top: 16, leading: 26, bottom: 16, trailing: 26))
			}
			.background {
                if let customBgColor {
                    customBgColor
                } else {
                    themeManager.currentTheme.moduleScreenBtnsColor
                }
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
//						Image(asset: Asset.Images.plusIcon)
						Image(systemName: "plus.circle.fill")
							.foregroundColor(themeManager.currentTheme.mainText)
						Text("Добавить слово".localize())
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 16, weight: .medium))
					}
				}
				.foregroundColor (
					themeManager.currentTheme.moduleScreenBtnsColor
				)
				.overlay {
					RoundedRectangle(cornerRadius: 20)
						.stroke()
						.foregroundColor(themeManager.currentTheme.mainText)
				}
				.padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
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
			Text("Удалить модуль".localize())
				.foregroundColor(themeManager.currentTheme.mainText)
				.font(.system(size: 16, weight: .regular))
				.frame(width: 300, height: 50)
				.offset(y: -15)
		}
		.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
	}
}



