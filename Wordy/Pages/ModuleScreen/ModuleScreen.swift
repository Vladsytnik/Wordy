//
//  ModuleScreen.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.01.2023.
//

import SwiftUI
import SwiftUITooltip
import Pow

struct ModuleScreen: View {
	
	@EnvironmentObject var subscriptionManager: SubscriptionManager
	
    @Binding var module: Module
	@Binding var modules: [Module]
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
    @State var showPrePaywallAlert = false
    
    @State var isNotificationLoading = false
    
    @State var showNotificationSettingsAlert = false
    @State var notificationSettingsAlertDescription = ""

    lazy var currentThemeName: String?  = {
        UserDefaultsManager.themeName
    }()
    
    @UIApplicationDelegateAdaptor(WordyAppDelegate.self) var appDelegate
	
	var body: some View {
//		Color.clear
//			.background(content: {
				GeometryReader { geo in
					ZStack {
						if viewModel.showEditPhrasePage {
							NavigationLink(
								destination: PhraseEditPage(
									module: $module,
									phraseIndex: viewModel.phraseIndexForEdit
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
                                if isShared || module.isSharedByTeacher {
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
                                       module: module,
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
                                
								if module.phrases.count > 0 {
									AddWordPlusButton {
										didTapShareModule()
									}
									.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                                    
									LearnModuleButton {
                                        onboardingManager.goToNextStep()
										if module.phrases.count >= 4 {
                                            checkSubscriptionAndAccessability(module: module) { isAllow in
												if isAllow {
                                                    AnalyticsManager.shared.trackEvent(.tapOnLearnModule(.Available))
													learnPageViewModel.module = module
													showLearnPage.toggle()
												} else {
                                                    AnalyticsManager.shared.trackEvent(.tapOnLearnModule(.DisabledBecauseNeedSubscription))
													viewModel.showPaywall()
												}
											}
										} else {
                                            AnalyticsManager.shared.trackEvent(.tapOnLearnModule(.DisabledBecauseLessThanRequiredCount))
											viewModel.didTapPhraseCountAlert(module: module)
										}
									}
									.frame(height: 45)
									.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                                    .mytooltip(((onboardingManager.currentStepIndex == 1 && !viewModel.userDidntSeeLearnBtnYet())
                                                || (onboardingManager.currentStepIndex == 0 && !viewModel.userDidntSeeCreatePhrase()))
                                               && viewModel.userDidntSeeLearnBtnYet()
                                               && module.phrases.count >= 4,
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
								
                                ForEach(0..<module.phrases.count, id: \.self) { i in
									Button {
//										viewModel.didTapWord(with: i)
//                                        onboardingManager.goToNextStep()
									} label: {
										WordCard(
											width: geo.size.width - 60,
											module: $module,
											phraseIndex: i,
											onAddExampleTap: { index in
                                                AnalyticsManager.shared.trackEvent(.didTapAddExample(.ModulePage))
												viewModel.didTapAddExample(index: index)
											},
											onEditTap: { index in
												currentEditPhraseIndex = index
												showEditAlert.toggle()
											}, onSpeachTap: { index in
                                                AnalyticsManager.shared.trackEvent(.didTapOnSpeechButton)
                                                viewModel.didTapSpeach(phrase: module.phrases[i])
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
								
								if module.phrases.count > 0 {
									DeleteModuleButton { viewModel.didTapDeleteModule() }
                                        .padding(.bottom)
								}
								
								Rectangle()
									.frame(height: 55)
									.foregroundColor(.clear)
                                
                                if module.phrases.count == 0 {
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
                            
                            // РАЗОБРАТЬСЯ С ТЕМ ЧТО НЕПРАВИЛЬНО УДАЛЯЮТСЯ ФРАЗЫ
                            if module.phrases.count == 0 {
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
                            .mytooltip(onboardingManager.currentStepIndex == 0
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
                    .showAlert(title: "Удалить этот модуль?", description: "Это действие нельзя будет отменить", isPresented: $viewModel.showAlert, titleWithoutAction: "Удалить", titleForAction: "Отменить", withoutButtons: false, okAction: { viewModel.nowReallyNeedToDeleteModule(module: module) }, repeatAction: {})
                    .showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showDeletingErrorAlert) {
                        viewModel.nowReallyNeedToDeleteModule(module: module)
                    }
                    .showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showOkAlert, withoutButtons: true) {
                        viewModel.nowReallyNeedToDeleteModule(module: module)
                    }
                    .showAlert(title: "💡 Правило\n пятнадцати слов", description: "\nНаш мозг устроен таким образом, \nчто информация усваивается \nболее эффективно, если она \nразделена на порции. \n\n 15 – это та самая порция, которая \nявляется оптимальной \nдля запоминания слов 🧠", isPresented: $showInfoAlert, titleWithoutAction: "Буду знать!", withoutButtons: true) {
                        
                    }
                    .showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showErrorAboutPhraseCount, withoutButtons: true) {
                    }
                    .showAlert(title: "Wordy.app", description: "\n" + "Вы достигли лимита по количеству \nслов в одном модуле. \n\nМы не рекомендуем добавлять больше 15 фраз в один модуль. \n\nНо если вы все равно хотите снять все ограничения, то попробуйте \nподписку Wordy PRO".localize(), isPresented: $showPrePaywallAlert, titleWithoutAction: "Попробовать", titleForAction: "Понятно", withoutButtons: false, okAction: { reallyShowPaywall() }, repeatAction: {})
					.fullScreenCover(isPresented: $viewModel.showActionSheet) {
                        AddNewPhrase(module: $module)
                            .environmentObject(addNewPhraseViewModel)
					}
				}
//			})
			.background(BackgroundView())
            .navigationBarTitleDisplayMode(.inline)
			.fullScreenCover(isPresented: $viewModel.showWordsCarousel) {
				WordsCarouselView(
					module: $module,
					selectedWordIndex: viewModel.selectedWordIndex
				)
			}
			.fullScreenCover(isPresented: $showLearnPage, content: {
				LearnSelectionPage(
					module: module,
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
                            viewModel.didTapDeletePhrase(module: module, phrase: module.phrases[currentEditPhraseIndex])
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
                                  data: [viewModel.getShareUrl(module: module)],
//								  data: [URL(string: "https://wordy.onelink.me/HpCP/s3t4ujfk")!],
								  subject: nil,
								  message: nil)
			}
            .onAppear {
                self.emoji = module.emoji
                self.moduleName = module.name
                AnalyticsManager.shared.trackEvent(.openedModule)
//                viewModel.setSharingUrl(module: module)
            }
            .navigationBarItems(
                trailing:
                    HStack {
                        Button(action: {
                            
                            checkNotificationAuthorization { isAllow in
                                if isAllow {
                                    AnalyticsManager.shared.trackEvent(.toggleNotificationButtonInsideModule)
                                    toggleNotificationsState()
                                } else {
                                    notificationSettingsAlertDescription = "\n Чтобы включить уведомления, необходимо дать к ним доступ в настройках".localize()
                                    withAnimation(.bouncy) {
                                        showNotificationSettingsAlert = true
                                    }
                                }
                            }
                            
                        }) {
                            Image(systemName: module.isNotificationTurnedOn ? "bell.fill" : "bell")
                                .foregroundColor(themeManager.currentTheme.mainText)
//                                .changeEffect(.pulse(shape: Circle(), count: 1), value: module.isNotificationTurnedOn)
                                .changeEffect(.jump(height: 5), value: isNotificationLoading)
                                .conditionalEffect(.repeat(.glow(color: themeManager.currentTheme.mainText.opacity(0.8), radius: 10), every: 0.8),
                                                   condition: isNotificationLoading)
                        }
                        .animation(.spring, value: isNotificationLoading)
                        
                        Button(action: {
                            showChangeModuleDataScreen.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(themeManager.currentTheme.mainText)
                        }
                    }
            )
            .sheet(isPresented: $showChangeModuleDataScreen) {
                if #available(iOS 16.0, *) {
                    ChangeModulePage(module:module,
                                     moduleName: $moduleName,
                                     emoji: $emoji)
//                    .presentationDetents([.medium])
                } else {
                    ChangeModulePage(module:module,
                                     moduleName: $moduleName,
                                     emoji: $emoji)
                }
            }
            .onChange(of: module) { val in
//                module = val
            }
            .showAlert(title: "Wordy.app", description: notificationSettingsAlertDescription, isPresented: $showNotificationSettingsAlert, titleWithoutAction: "Перейти в настройки".localize(), titleForAction: "Отмена".localize(), withoutButtons: false, okAction: {
                showNotificationSettingsAlert.toggle()
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings)
                }
            }, repeatAction: {
                
            })
            .onAppear {
                appDelegate.onNotificationStatusChanged = { isAllow in
                    if isAllow {
                        toggleNotificationsState()
                    }
                }
            }
	}
	
    init(module: Binding<Module>, modules: Binding<[Module]>, searchedText: Binding<String>, index: Int) {
        self._module = module
		self._modules = modules
		self._searchText = searchedText
    }
    
    func setToModuleTeacherMode(module: Module, successCallback: (() -> Void)?) {
        guard subscriptionManager.isUserHasSubscription else {
            return
        }
        
        Task { @MainActor in
            do {
               let isSuccess = try await NetworkManager.setTeacherModeToModule(id: module.id)
                if isSuccess {
                    successCallback?()
                }
            } catch (let error) {
                print("Error in ModuleScreenViewModel -> setToModuleTeacherMode: \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleNotificationsState() {
        isNotificationLoading = true
        
        Task {
            do {
                if let notification = try await NetworkManager.getNotificationsInfo() {
                    try await updateNotification(with: notification)
                } else {
                    let calendar = Calendar.current
                    let date1 = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                    let date2 = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                    let notification = Notification(isOn: true,
                                                    isNight: false,
                                                    dates: [date1, date2],
                                                    notificationCount: 2,
                                                    selectedModulesIds: [module.id],
                                                    phrases: [])
                    try await updateNotification(with: notification)
                }
            } catch (let error) {
                isNotificationLoading = false
                print("Error in ModuleScreen -> turnOnNotifications: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkNotificationAuthorization(isAllow: @escaping ((Bool) -> Void)) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Доступ к уведомлениям разрешен")
                isAllow(true)
            case .denied:
                print("Доступ к уведомлениям запрещен")
                isAllow(false)
            case .notDetermined:
                print("Доступ к уведомлениям не определен")
                appDelegate.sendNotificationPermissionRequest { isTrue in
                   
                }
//                isAllow?(false)
            default:
                break
            }
        }
    }
    
    private func updateNotification(with notif: Notification) async throws {
        var isOk = false
        var notification = notif
        let isOn = module.isNotificationTurnedOn
        
        if isOn {
            if let deletionIndex = notification.selectedModulesIds.firstIndex(where: { $0 == module.id }) {
                notification.selectedModulesIds.remove(at: Int(deletionIndex))
                notification.isOn = false
            }
        } else {
            notification.selectedModulesIds.append(module.id)
            notification.isOn = true
        }

        try await NetworkManager.updateNotificationsInfo(notification: notification)
        
//        if isOk {
//            module.isNotificationTurnedOn = !isOn
//        }
        
        isNotificationLoading = false
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
    
    func checkSubscriptionAndAccessability(module: Module, isAllow: ((Bool) -> Void)) {
        let countOfStartingLearnMode = UserDefaultsManager.countOfStartingLearnModes[module.id] ?? 0
        isAllow(subscriptionManager.isUserHasSubscription
                || (countOfStartingLearnMode < maxCountOfStartingLearnMode
                    && !module.isBlockedFreeFeatures)
                || module.acceptedAsStudent)
    }
	
    func reallyShowPaywall() {
        withAnimation {
            showPrePaywallAlert = false
        }
        viewModel.showPaywall()
    }
    
	func didTapAddNewPhrase() {
		if module.phrases.count < countOfWordsForFree || subscriptionManager.isUserHasSubscription {
            AnalyticsManager.shared.trackEvent(.didTapAddNewPhrase(.DisabledBecauseMoreThanAllowedCount))
			viewModel.showActionSheet = true
		} else {
            AnalyticsManager.shared.trackEvent(.didTapAddNewPhrase(.Available))
            withAnimation {
                showPrePaywallAlert.toggle()
            }
		}
	}
	
	func didTapShareModule() {
        showActivity.toggle()
	}
    
    func needToUpdateTeacherMode() {
        userIsReallyShared = false
        setToModuleTeacherMode(module: module) {
            module.isSharedByTeacher = true
            isShared = true
        }
    }
}

struct ModuleScreen_Previews: PreviewProvider {
	static var previews: some View {
		ModuleScreen(
            module: .constant(.init()),
			modules: .constant( [Module(name: "Test", emoji: "❤️‍🔥", phrases: [
				.init(nativeText: "Test", translatedText: "Test", id: "1")
			])]),
			searchedText: .constant(""),
			index: 0
		)
		.environmentObject(ThemeManager())
        .environmentObject(SubscriptionManager.shared)
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
            AnalyticsManager.shared.trackEvent(.didTapShareModule)
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
	
    var title: String?
	let action: () -> Void
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		Button {
			action()
		} label: {
            if let title {
                Text(title.localize())
                    .foregroundColor(themeManager.currentTheme.mainText)
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 300, height: 50)
                    .offset(y: -15)
            } else {
                Text("Удалить модуль".localize())
                    .foregroundColor(themeManager.currentTheme.mainText)
                    .font(.system(size: 16, weight: .regular))
                    .frame(width: 300, height: 50)
                    .offset(y: -15)
            }
		}
		.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
	}
}



