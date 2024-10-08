//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 10.12.2022.
//

import SwiftUI
import Firebase
import SwiftUITooltip
import ApphudSDK
import AVFAudio
import StoreKit
import Combine


struct NewModulesScreen: View {
    
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 20) ]
    private let moduleCardWidth: CGFloat = UIScreen.main.bounds.height < 812 ? 145 : 170
    
    @State private var scrollOffset = CGFloat.zero
    @State private var scrollDirection = CGFloat.zero
    @State private var prevScrollOffsetValue = CGFloat.zero
    @State private var isInlineNavBar = false
    @State private var searchText = ""
    @State private var createModuleButtonOpacity = 1.0
    @State private var showCreateModuleSheet = false
    @State private var showCreateGroupSheet = false
    
    @EnvironmentObject var router: Router
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var deeplinkManager: DeeplinkManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State var pullToRefresh = false
    
    @State private var showSettings = false
    
    @EnvironmentObject var dataManager: DataManager
    
    @State private var needUpdateData = false
    
    @State var showAlert = false
    @State var showGroupsAlert = false
    @State var alert = (title: "", description: "")
    @State var showSelectModulePage = false
    @State var showEditModulePage = false
    
    @State private var longPressIndex = 0
    
    @State private var groupId = ""
    @State var isOnAppear = false
    
    @State var selectedIndexes: [Int] = []
    @State var isEditMode = false
    @State var paywallIsOpened = false
    @State var navigationIsActive = false
    
    private var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
    private var generator2: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .soft)
    @StateObject private var onboardingManager = OnboardingManager(screen: .modules, countOfSteps: 3)
    
    @StateObject var vm = ScrollToModel()
    private let macCountOfFreeGroups = 3
    
    @State var isShowPaywall = false
    @State var isFirstLaunch = true
    
    @State var navBarColor: UIColor?
    
    @State var openModule = false
    @State var openModuleIndex = 0
    
    lazy var currentTheme: String?  = {
        UserDefaultsManager.themeName
    }()
    
    @State private var player: AVAudioPlayer? = AVAudioPlayer()
    
    @AppStorage("isReviewBtnDidTap") private var isReviewDidTap = false
    @AppStorage("review.counter") private var reviewCounter = 0
    @AppStorage("review.counterLimit") private var reviewCounterLimit = 10
    @State private var isReviewOpened = false
    
    @EnvironmentObject var rewardManager: RewardManager
    @UIApplicationDelegateAdaptor(WordyAppDelegate.self) var appDelegate
    
    @State var showPopups = false
    
    @State var cancelable = Set<AnyCancellable>()
    @State var indexOfPopup = 0
    
    @State var isMultiSelectMode = false
    let multiSelectionModeAnimation = Animation.interpolatingSpring(duration: 0.2, bounce: 0.4, initialVelocity: 0.7)
    @State var longTappedIndex = 0
    @State var showDeleteMultiSelectedModulesButton = false
    @State var showDeleteModulesAlert = false
    @State var isDeletionShaking = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        
                        NavigationLink("", isActive: $openModule, destination: {
                            ModuleScreen(
                                module: openModuleIndex < dataManager.modules.count ? $dataManager.modules[openModuleIndex] : .constant(.init()),
                                modules: $dataManager.modules,
                                searchedText: $searchText,
                                index: openModuleIndex
                            )
                        })
                        
                        ScrollView {
                            VStack {
//                                RefreshControl(coordinateSpace: .named("RefreshControl")) { pullDownToRefresh() }
                                
//                                HStack {
//                                    Text("Модули".localize())
//                                        .font(.title)
//                                        .bold()
//                                        .padding(.horizontal)
//                                    Spacer()
//                                }
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 16)
                                
                                if (!onboardingManager.isOnboardingMode || UserDefaultsManager.isNotFirstLaunchOfModulesPage)
                                    && UserDefaultsManager.isMainScreenPopupsShown {
                                    SearchTextField(modules: $dataManager.modules, searchText: $searchText, placeholder: "Поиск".localize())
                                        .padding(.leading)
                                        .padding(.trailing)
                                        .disabled(onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    withAnimation {
                                        HStack(spacing: 10) {
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: 12)
                                            Button {
                                                AnalyticsManager.shared.trackEvent(.didTapOnCreateNewGroupPlusButton)
                                                withAnimation {
                                                    checkSubscriptionAndCountOfGroups { isAllow in
                                                        if isAllow {
                                                            showCreateGroupSheet.toggle()
                                                        } else {
                                                            isShowPaywall.toggle()
                                                        }
                                                    }
                                                }
                                            } label: {
                                                RoundedRectangle(cornerRadius: 35 / 2)
                                                    .frame(width: 35, height: 35)
                                                    .foregroundColor(themeManager.currentTheme.nonActiveCategory)
                                                    .overlay {
                                                        Image(asset: Asset.Images.newGroup)
                                                            .resizable()
                                                            .renderingMode(.template)
                                                            .colorMultiply(themeManager.currentTheme.mainText)
                                                            .opacity(themeManager.currentTheme.isDark ? 1 : 0.75)
                                                            .frame(width: 19, height: 19)
                                                    }
                                            }
                                            .disabled(onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
                                            .showPopup(order: 1, title: "Объединяйте модули в группы".localize())
                                            
                                            if showCreateGroupSheet {
                                                NewCategoryCard() { success, text in
                                                    if success {
                                                        isEditMode = false
                                                        showCreateGroupSheet = false
                                                        let newGroup = Group(name: text)
                                                        dataManager.groups.insert(newGroup, at: 0)
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                            showSelectModulePage.toggle()
                                                        }
                                                    } else {
                                                        withAnimation {
                                                            showCreateGroupSheet = false
                                                        }
                                                    }
                                                }
                                            }
                                            HStack(spacing: 12) {
                                                ForEach(0..<dataManager.groups.count, id: \.self) { j in
                                                    CategoryCard(
                                                        group: dataManager.groups[j],
                                                        isSelected: dataManager.selectedCategoryIndex == j,
                                                        modules: $dataManager.modules,
                                                        searchText: $searchText
                                                    )
                                                        .onTapGesture {
                                                            if isOnboardingStepNumber(2) {
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                                    onboardingManager.goToNextStep()
                                                                }
                                                            }
//                                                            withAnimation(Animation.spring()) {
                                                                dataManager.selectedCategoryIndex = j != dataManager.selectedCategoryIndex ? j : -1
                                                                dataManager.filter(withText: self.searchText)
//                                                            }
                                                        }
                                                        .onLongPressGesture(minimumDuration: 0.5) {
                                                            if isOnboardingStepNumber(0) {
                                                                onboardingManager.goToNextStep()
                                                            }
                                                            isEditMode = true
                                                            self.groupId = dataManager.groups[j].id
                                                            selectedIndexes = translateUuidies(dataManager.groups[j].modulesID)
                                                            showEditModulePage.toggle()
                                                            generator2?.impactOccurred()
                                                            AnalyticsManager.shared.trackEvent(.didLongTappedForChangeGroup)
                                                        }
                                                        .modifier(CategoryLongTapModifier())
                                                }
                                            }
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: 10)
                                        }
                                    }
                                }
                                .padding(.top)
                                .disabled(showPopups)
                                .mytooltip(isOnboardingStepNumber(0),
                                           config: nil,
                                           appearingDelayValue: 0.5)
                                {
                                    let text = "Удерживайте, чтобы добавить \nили удалить модуль из группы".localize()
                                    TooltipView(
                                        text: text,
                                        stepNumber: onboardingManager.currentStepIndex,
                                        allStepCount: onboardingManager.countOfSteps,
                                        onDisappear: { },
                                        onNextDidTap: {
                                            self.onboardingManager.goToNextStep()
                                        }
                                    )
                                }
                                .mytooltip(isOnboardingStepNumber(2),
                                           config: nil,
                                           appearingDelayValue: 0.5)
                                {
                                    let text = "Нажмите, чтобы увидеть \nмодули из этой группы".localize()
                                    TooltipView(
                                        text: text,
                                        stepNumber: onboardingManager.currentStepIndex,
                                        allStepCount: onboardingManager.countOfSteps,
                                        onDisappear: { },
                                        onNextDidTap: {
                                            self.onboardingManager.goToNextStep()
                                            AnalyticsManager.shared.trackEvent(.finishFirstOnboarding)
                                        }
                                    )
                                }
                                .zIndex(100)
                                
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(0..<dataManager.modules.count, id: \.self) { i in
                                        ModuleCard(
                                            width: moduleCardWidth,
                                            cardName: dataManager.modules[i].name,
                                            emoji: dataManager.modules[i].emoji,
                                            module: $dataManager.modules[i],
                                            isSelected: .constant(false)
                                        )
                                        .longTapAnimatableModifier(
                                            onTap: {
                                                guard !isMultiSelectMode else {
                                                    withAnimation(multiSelectionModeAnimation) {
                                                        showDeleteMultiSelectedModulesButton = true
                                                    }
                                                    
                                                    dataManager.selectModule(withId: dataManager.modules[i].id)
//                                                    dataManager.allModules[i].isSelected.toggle()
                                                    return
                                                }
                                                
                                                openModuleIndex = i
                                                openModule.toggle()
                                            }, onLongTap: {
                                                generator2?.impactOccurred()
                                                longTappedIndex = i
                                                withAnimation(multiSelectionModeAnimation) {
                                                    isMultiSelectMode.toggle()
                                                }
                                            })
                                        .disabled(onboardingManager.isOnboardingMode 
                                                  && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
//                                        .shake(isAnimatable: $isDeletionShaking)
//                                        .animation(.default.speed(1.4).repeatForever().delay(Double(i) * 0.1), value: isDeletionShaking)
                                        .overlay {
                                            if isMultiSelectMode {
                                                HStack {
                                                    Spacer()
                                                    VStack {
                                                        if dataManager.modules[i].isSelected {
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .resizable()
                                                                .foregroundColor(themeManager.currentTheme.mainText)
                                                                .frame(width: 20, height: 20)
                                                                .opacity(0.9)
                                                        } else {
                                                            Circle()
                                                                .stroke(lineWidth: 1)
                                                                .frame(width: 20, height: 20)
                                                                .foregroundColor(themeManager.currentTheme.mainText)
                                                                .opacity(0.9)
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                                .padding()
                                            }
                                        }
                                        .opacity(isMultiSelectMode && !dataManager.modules[i].isSelected ? 0.7 : 1)
                                        .animation(multiSelectionModeAnimation.delay(Double(abs(longTappedIndex - i)) * 0.02), value: isMultiSelectMode)
                                    }
                                    .listRowBackground(Color.green)
                                    .listStyle(.plain)
                                }
                                .padding()
                                
                                Rectangle()
                                    .frame(height: 132)
                                    .foregroundColor(.clear)
                            }
                        }
//                        .if((!onboardingManager.isOnboardingMode || UserDefaultsManager.isNotFirstLaunchOfModulesPage)
//                            && UserDefaultsManager.isMainScreenPopupsShown)
//                        { view in
//                            view.searchable(text: $searchText)
//                        }
//                        .searchable(text: $searchText)
                        .refreshable{
                            pullDownToRefresh()
                        }
                        .onChange(of: searchText) { _ in
                            self.filterModules(text: searchText)
                        }
                        .coordinateSpace(name: "RefreshControl")
                        .edgesIgnoringSafeArea(.bottom)
                        .setTrailingNavBarItem(
                            isSkipBtn: onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage,
                            disabled: (onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
                            || (showPopups && indexOfPopup != 2),
                            onSkip: {
                                AnalyticsManager.shared.trackEvent(.skippedFirstOnboarding)
                                onboardingManager.finish()
                            },
                            completion: {
                                if showPopups {
                                    indexOfPopup+=1
                                    UserDefaultsManager.isMainScreenPopupsShown = true
                                    showPopups = false
                                }
                        })
//                        .onChange(of: scrollOffset) { newValue in
//                            
//                            withAnimation(.easeInOut(duration: 0.1)) {
//                                showOrHideNavBar(value: newValue)
//                            }
//                            calculateScrollDirection()
//                        }
//                        BlurNavBar(show: $isInlineNavBar, scrollOffset: $scrollOffset)
                        
                        VStack {
                            Spacer()
                            
                            if isMultiSelectMode {
                                HStack {
                                    if showDeleteMultiSelectedModulesButton {
                                        let btnWidth: CGFloat = 45
                                        
                                        Button(action: {
                                            withAnimation(Animations.customSheet) {
                                                showDeleteModulesAlert.toggle()
                                            }
                                        }, label: {
                                            Image(systemName: "trash")
                                                .resizable()
                                                .frame(width: btnWidth - 24, height: btnWidth - 24)
                                                .foregroundColor(themeManager.currentTheme.mainText)
                                                .padding()
                                                .background {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .foregroundColor(themeManager.currentTheme.moduleCreatingBtn)
//                                                        .foregroundColor(.red)
                                                }
                                        })
                                        .offset(y: geometry.size.height < 812 ? -16 : 0 )
                                        .shadow(color: .white.opacity(0.15), radius: 20)
                                        .if(!isDark()) { v in
                                            v
                                                .shadow(color: themeManager.currentTheme.mainText.opacity(0.35), radius: 25)
                                        }
                                        .transition(.move(edge: .trailing).combined(with: .opacity))
                                    }
                                    
                                    Button(action: {
                                        withAnimation(multiSelectionModeAnimation) {
                                            isMultiSelectMode = false
                                            showDeleteMultiSelectedModulesButton = false
                                        }
                                    }, label: {
                                        Text("Готово".localize())
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(themeManager.currentTheme.mainText)
                                            .padding()
                                            .padding(.horizontal)
                                            .padding(.horizontal)
                                            .background {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .foregroundColor(themeManager.currentTheme.moduleCreatingBtn)
                                                    .shadow(color: .white.opacity(0.15), radius: 20)
                                                    .if(!isDark()) { v in
                                                        v
                                                            .shadow(color: themeManager.currentTheme.mainText.opacity(0.35), radius: 25)
                                                    }
                                            }
                                    })
                                    .offset(y: geometry.size.height < 812 ? -16 : 0 )
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            } else {
                                CreateModuleButton() {
                                    generator?.impactOccurred()
                                    showCreateModuleSheet = true
                                    onboardingManager.goToNextStep()
                                }
                                .showPopup(order: 0, title: "Создавайте модули".localize())
                                .frame(width: geometry.size.width - 60)
                                .opacity(createModuleButtonOpacity)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .offset(y: geometry.size.height < 812 ? -16 : 0 )
                                .disabled(!isOnboardingStepNumber(1) && onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
                                .mytooltip(isOnboardingStepNumber(1),
                                           side: .top,
                                           offset: 24,
                                           config: nil,
                                           appearingDelayValue: 0.5)
                                {
                                    let text = "Нажмите, чтобы создать \nновый модуль".localize()
                                    TooltipView(
                                        text: text,
                                        stepNumber: onboardingManager.currentStepIndex,
                                        allStepCount: onboardingManager.countOfSteps,
                                        onDisappear: { },
                                        onNextDidTap: {
                                            self.onboardingManager.goToNextStep()
                                        }
                                    )
                                }
                            }
                        }
                        .ignoresSafeArea(.keyboard)
                        
                        VStack {
                            Spacer()
                            if onboardingManager.onboardingHasFinished {
                                LottieView(fileName: "onboarding", isLooped: false)
                            }
                        }
                        .ignoresSafeArea()
                        
                        if (dataManager.modules.count == 0)
                            && !dataManager.isLoading {
                                EmptyBGView()
                                .onTapGesture {
                                    UIApplication.shared.endEditing()
                                }
                        }
                        
                        if isReviewOpened {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(themeManager.currentTheme.isDark ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
                                    .ignoresSafeArea()
                                ReviewView(isOpened: $isReviewOpened)
                            }
                            .zIndex(9999)
                        }
                        
                        VStack {
                            HStack {
                                Spacer()
                                Color.clear
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .showPopup(order: 2, title: "Настраивайте уведомления и выбирайте цветовую тему".localize())
                            }
                            Spacer()
                        }
                        .ignoresSafeArea()
                        
//                        if onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage {
//                            VStack {
//                                HStack {
//                                    Spacer()
//                                    
//                                    Button {
//                                        onboardingManager.finish()
//                                    } label: {
//                                        HStack {
//                                            Text("Пропустить".localize())
//                                                .underline()
//                                            Image(systemName: "arrow.right")
//                                                .foregroundColor(themeManager.currentTheme.mainText)
//                                        }
//                                    }
//                                    .padding()
//                                    .offset(y: -50)
//                                    .zIndex(100)
//                                }
//                                Spacer()
//                            }
////                            .ignoresSafeArea()
//                            
//                            
////                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0))
//                        }
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    .disabled(dataManager.isLoading || showAlert)
                    .sheet(isPresented: $deeplinkManager.isOpenModuleType) {
                        if #available(iOS 16.0, *) {
                            SharedModulePage(needUpdateData: $needUpdateData,
                                             showActivity: $dataManager.isLoading,
                                             screenFullHeight: geometry.size.height,
                                             isNotAbleToChangeIcon: true
                            )
                            .presentationDetents([.medium, .large])
                        } else {
                            SharedModulePage(needUpdateData: $needUpdateData,
                                             showActivity: $dataManager.isLoading,
                                             screenFullHeight: geometry.size.height,
                                             isNotAbleToChangeIcon: true)
                        }
                    }
                    .animation(.spring, value: isReviewOpened)
                }
                .background(
                    BackgroundView()
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                        }
                )
//                .navigationTitle("Модули".localize())
                .onAppear{ router.showActivityView = false }
//            }
//                .preferredColorScheme(ColorScheme.init(.dark))
            .onAppear{
                isOnAppear = true
                listenUserAuth()
                checkUser()
//                if isFirstLaunch {
                isFirstLaunch = false
                fetchDataFromServer()
//                }
                router.userIsAlreadyLaunched = true
                
//                if UserDefaultsManager.isNotFirstLaunchOfModulesPage {
//                    appDelegate.sendNotificationPermissionRequest()
//                }
                
                if !(reviewCounter >= reviewCounterLimit && !isReviewDidTap && dataManager.modules.count > 2) {
                    reviewCounter += 1
                }
                
                if  UserDefaultsManager.isNotFirstLaunchOfModulesPage
                        && !UserDefaultsManager.isMainScreenPopupsShown
                {
                    self.startPopupsIfNeeded()
                }
                 
                onboardingManager
                    .$isOnboardingMode
                    .dropFirst()
                    .sink { val in
                        if !val {
                            self.startPopupsIfNeeded()
                        }
                    }
                    .store(in: &cancelable)
            }
            .sheet(isPresented: $showCreateModuleSheet) {
                CreateModuleView(needUpdateData: $needUpdateData, showActivity: $dataManager.isLoading, isOnboardingMode: onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
                    .environmentObject(router)
            }
            .activity($dataManager.isLoading)
//            .onChange(of: needUpdateData) { _ in
//                fetchDataFromServer()
//            }
            .onChange(of: onboardingManager.isOnboardingMode, perform: { newValue in
                if !newValue {
                    fetchDataFromServer()
                }
            })
            .onChange(of: showCreateModuleSheet, perform: { isOpened in
                if !isOpened {
                    showReviewIfNeeded()
                }
            })
            .fullScreenCover(isPresented: $showSelectModulePage, content: {
                ModuleSelectPage(
                    modules: dataManager.isMockData ? .constant(MockDataManager().modules) : $dataManager.allModules,
                    isOpened: $showSelectModulePage,
                    groupId: $dataManager.groups[0].id,
                    needUpdate: $needUpdateData,
                    groups: $dataManager.groups,
                    isEditMode: $isEditMode
                )
            })
            .sheet(isPresented: $showEditModulePage, content: {
                ModuleSelectPage(
                    modules: dataManager.isMockData ? .constant(MockDataManager().modules) : $dataManager.allModules,
                    isOpened: $showEditModulePage,
                    groupId: $groupId,
                    needUpdate: $needUpdateData,
                    groups: $dataManager.groups,
                    isEditMode: $isEditMode,
                    isOnboardingMode: onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage,
                    selectedIndexes: $selectedIndexes
                )
            })
            .showAlert(title: alert.title, description: alert.description, isPresented: $showAlert) {
                fetchDataFromServer()
            }
            .showAlert(title: alert.title, description: alert.description, isPresented: $showGroupsAlert) {
                fetchDataFromServer()
            }
            .sheet(isPresented: $isShowPaywall, content: {
                Paywall(isOpened: $isShowPaywall)
            })
            .fullScreenCover(isPresented: $paywallIsOpened, content: {
                Paywall(isOpened: $paywallIsOpened)
            })
            .onChange(of: onboardingManager.onboardingHasFinished) { newValue in
                if newValue {
                    generator2?.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        generator2?.impactOccurred()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            generator2?.impactOccurred()
                        }
                    }
                }
            }
            .onAppear {
                
            }
            .navigationBarTitleDisplayMode(.inline)
//            .if(!showPopups) { v in
//                v.navigationTitle("Модули".localize())
//            }
            .navigationTitle("Модули".localize())
            .animation(.spring(), value: showPopups)
            .preferredColorScheme(themeManager.currentTheme.isDark ? (themeManager.currentTheme.id != "MainColor" ? .dark : nil) : .light)
            .popup(allowToShow: $showPopups, currentIndex: $indexOfPopup) {
                AnalyticsManager.shared.trackEvent(.skippedSecondPopupOnboarding)
                UserDefaultsManager.isMainScreenPopupsShown = true
                AnalyticsManager.shared.trackEvent(.finishSecondPopupsOnboarding)
            }
            .onChange(of: showPopups) { val in
                if !val {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        appDelegate.sendNotificationPermissionRequest()
//                    }
                }
            }
            .onChange(of: dataManager.isLoading) { val in
                if !val {
                    if (dataManager.isInitialized && !dataManager.isLoading)
                        || UserDefaultsManager.userID == nil {
                        print("loading page test: все условия совпали и надо запускать анимацию")
                        dataManager.startLoadingAnimation = true
                    }
                }
            }
            .onChange(of: isMultiSelectMode) { isMultiSelect in
                if !isMultiSelect {
                    dataManager.deselectAllModules()
                    withAnimation(multiSelectionModeAnimation) {                    
                        showDeleteMultiSelectedModulesButton = false
                    }
                    isDeletionShaking = false
                } else {
                        isDeletionShaking = isMultiSelectMode
                }
            }
            .showAlert(title: "Вы уверены, что хотите удалить выбранные модули?", description: "Это действие нельзя будет отменить", isPresented: $showDeleteModulesAlert, titleWithoutAction: "Удалить", titleForAction: "Отменить", withoutButtons: false, okAction: { deleteSelectedModules() }, repeatAction: {})
    }
    
    init() {
        configNavBarStyle()
        configTooltip()
    }
    
    private func deleteSelectedModules() {
        let selectedModules = dataManager.modules.filter { $0.isSelected }
        
        withAnimation(multiSelectionModeAnimation) { isMultiSelectMode = false }
        withAnimation(Animations.customSheet) { showDeleteModulesAlert = false }
        
        dataManager.isLoading = true
        
        Task {
            do {
                try await NetworkManager.deleteModules(selectedModules)
                print("async await debug: метод завершился и мы можем обновить UI")
                dataManager.delete(modules: selectedModules)
                dataManager.isLoading = false
            } catch (let error) {
                print("Error in NewModulesScreen -> deleteSelectedModules: \(error)")
                dataManager.isLoading = false
            }
        }
    }
    
    private func showReviewIfNeeded() {
        print("fevwewev: \(reviewCounter) \(reviewCounterLimit) \(isReviewDidTap)")
        if reviewCounter >= reviewCounterLimit && !isReviewDidTap && dataManager.modules.count > 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isReviewOpened = true
            }
            reviewCounter = 0
            reviewCounterLimit += 50
        } else {
            reviewCounter += 1
        }
    }
    
    private func startPopupsIfNeeded() {
        if  UserDefaultsManager.isNotFirstLaunchOfModulesPage
                && !UserDefaultsManager.isMainScreenPopupsShown
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showPopups = true
            }
        }
    }
    
    private func isOnboardingStepNumber(_ value: Int) -> Bool {
        onboardingManager.isOnboardingMode
        && onboardingManager.currentStepIndex == value
        && !UserDefaultsManager.isNotFirstLaunchOfModulesPage
    }
    
   private func filterModules(text: String) {
       dataManager.filter(withText: text)
    }
    
    private func isDark() -> Bool {
        themeManager.currentTheme.isSupportLightTheme
        ? colorScheme != .light
        : themeManager.currentTheme.isDark
    }
    
    private mutating func configTooltip() {
        
    }
    
    private func translateUuidies(_ uuidies: [String]) -> [Int] {
        var result: [Int] = []
        
        for uuid in uuidies {
            for (i, module) in dataManager.modules.enumerated() {
                if module.id == uuid {
                    result.append(i)
                }
            }
        }
        
        return result
    }
    
    private func pullDownToRefresh() {
        simpleSuccess()
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.7) {
            dataManager.forceLoadFromServer()
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func fetchDataFromServer() {
        onboardingManager.onFinish = {
            dataManager.forceLoadFromServer()
            dataManager.setRealData()
        }
        if onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage {
            dataManager.setMockData()
        } else {
            dataManager.setRealData()
        }
    }
    
    private func showAlert(errorText: String) {
        withAnimation {
            showAlert.toggle()
        }
        alert.title = "Упс! Произошла ошибка".localize()
        alert.description = errorText
    }
    
    private mutating func configNavBarStyle() {
        let navigationBarAppearance = UINavigationBarAppearance()
//        navigationBarAppearance.backgroundColor = UIColor(ThemeManager().currentTheme.main)
        navigationBarAppearance.backgroundEffect = .init(style: .regular)
//        navigationBarAppearance.largeTitleTextAttributes = [
//            .foregroundColor: UIColor.white
//        ]
//        navigationBarAppearance.titleTextAttributes = [
//            .foregroundColor:  UIColor(ThemeManager().currentTheme.mainText) ,
//        ]
//        navigationBarAppearance.configureWithTransparentBackground()
//        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
    }
    
    private func showOrHideNavBar(value: CGFloat) {
        if value >= 10 && isInlineNavBar == false {
            self.isInlineNavBar = true
        }
        if value <= 10 && isInlineNavBar == true {
            self.isInlineNavBar = false
        }
    }
    
    private func calculateScrollDirection() {
        if scrollOffset > 10 {
            scrollDirection = scrollOffset - prevScrollOffsetValue
            prevScrollOffsetValue = scrollOffset
        }
        withAnimation {
            if scrollDirection < 0 || scrollOffset < 10 {
                createModuleButtonOpacity = 1
            } else {
                createModuleButtonOpacity = 0
            }
        }
    }
    
    private func listenUserAuth() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                print("USER IS signed in")
                updateSubscriptionDateFromFirebase()
            } else {
                // No user is signed in.
                subscriptionManager.isUserHasSubscription = false
                
                withAnimation {
                    router.userIsLoggedIn = false
                    UserDefaultsManager.userID = nil
                    
                    Apphud.logout()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dataManager.groups = []
                    dataManager.allModules = []
                }
                print("USER IS signed out")
            }
            print("Current user:", auth.currentUser?.email)
        }
    }
    
    private func updateSubscriptionDateFromFirebase() {
        Task {
            do {
                let expireSubscriptionDateFromServer = try await NetworkManager.getSubscriptionExpireDateFromServer()
                UserDefaultsManager.serverSubscrExpireDate = expireSubscriptionDateFromServer
                subscriptionManager.forceUpdateSubscriptionInfo()
                print("expire date from server: \(expireSubscriptionDateFromServer)")
            } catch (let error) {
                print("error in NewModulesSreen -> .task -> try await NetworkManager.getSubscriptionExpireDateFromServer(): \(error.localizedDescription)")
                subscriptionManager.forceUpdateSubscriptionInfo()
            }
        }
    }
    
    private func checkUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        currentUser.getIDTokenResult(forcingRefresh: true) { idToken, error in
            if let error = error {
                print("ERROR")
            } else {
                print("NOT ERROR")
            }
        }
    }
    
    private func checkSubscriptionAndCountOfGroups(isAllow: ((Bool) -> Void)) {
        isAllow(subscriptionManager.isUserHasSubscription
                || dataManager.groups.count < macCountOfFreeGroups)
    }
}


struct NewModulesScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewModulesScreen()
                .environmentObject(Router())
                .environmentObject(DeeplinkManager())
                .environmentObject(ThemeManager())
                .environmentObject(SubscriptionManager.shared)
        }
    }
}

