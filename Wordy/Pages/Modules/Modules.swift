//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 10.12.2022.
//

import SwiftUI
import Firebase
import SwiftUITooltip

class ScrollToModel: ObservableObject {
	enum Action {
		case end
		case top
	}
	@Published var direction: Action? = nil
}

struct Modules: View {
	
//	private let columns = [GridItem(.adaptive(minimum: UIScreen.main.bounds.height < 812 ? 100 : 150),
//									spacing: UIScreen.main.bounds.height < 812 ? 10 : 20) ]
	private let columns = [GridItem(.adaptive(minimum: 150), spacing: 20) ]
	private let moduleCardWidth: CGFloat = UIScreen.main.bounds.height < 812 ? 145 : 170
	
	@State private var scrollOffset = CGFloat.zero
	@State private var scrollDirection = CGFloat.zero
	@State private var prevScrollOffsetValue = CGFloat.zero
	@State private var isInlineNavBar = false
	@State private var searchText = ""
	@State private var createModuleButtonOpacity = 1.0
	@State private var showCreateModuleSheet = false
	@State private var showActivity = false
	@State private var selectedCategoryIndex = -1
	@State private var showCreateGroupSheet = false
	
	@EnvironmentObject var router: Router
	
	@State var pullToRefresh = false
	
	@State private var showSettings = false
	
	@State private var modules: [Module] = []
//		didSet {
//			if searchText.count > 0 {
//				filteredModules = modules.filter{ $0.name.contains("\(searchText)") }
//			} else {
//				filteredModules = modules
//			}
//		}
//	}
	@State private var filteredModules: [Module] = []
	
	@State private var needUpdateData = false
	
	@State var showAlert = false
	@State var showGroupsAlert = false
	@State var alert = (title: "", description: "")
	@State var showSelectModulePage = false
	@State var showEditModulePage = false
	
	@State private var longPressIndex = 0
	
	@State private var groupId = ""
	
	@State var groups: [Group] = [
//		"Эйфория", "Хороший доктор", "Мистер робот", "Нулевой пациент"
	]
	@State var isOnAppear = false
	
	@State var selectedIndexes: [Int] = []
	@State var isEditMode = false
	@State var paywallIsOpened = false
	
	private var tooltipConfig = MyDefaultTooltipConfig()
	
	private var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
	private var generator2: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .soft)
	@ObservedObject private var onboardingManager = OnboardingManager(screen: .modules, countOfSteps: 3)
	
	@StateObject var vm = ScrollToModel()
	
	var body: some View {
		Color.clear
			.background {
				GeometryReader { geometry in
					ZStack {
						ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
							VStack {
								RefreshControl(coordinateSpace: .named("RefreshControl")) { pullDownToRefresh() }
								SearchTextField(modules: $modules, filteredModules: $filteredModules, searchText: $searchText, placeholder: "Search")
									.padding(.leading)
									.padding(.trailing)
									.padding(.top)
									.disabled(onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
								ScrollView(.horizontal, showsIndicators: false) {
									withAnimation {
										HStack(spacing: 10) {
											Rectangle()
												.foregroundColor(.clear)
												.frame(width: 12)
											Button {
												withAnimation {
													showCreateGroupSheet.toggle()
												}
											} label: {
												Image(asset: Asset.Images.newGroup)
													.resizable()
													.frame(width: 35, height: 35)
											}
											.disabled(onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
											if showCreateGroupSheet {
												NewCategoryCard() { success, text in
													if success {
														isEditMode = false
														showCreateGroupSheet = false
														let newGroup = Group(name: text)
														groups.insert(newGroup, at: 0)
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
												ForEach(0..<groups.count, id: \.self) { j in
													CategoryCard(
														group: groups[j],
														isSelected: selectedCategoryIndex == j,
														modules: $modules,
														filteredModules: $filteredModules,
														searchText: $searchText
													)
														.onTapGesture {
															if isOnboardingStepNumber(2) {
																DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
																	onboardingManager.goToNextStep()
																}
															}
															withAnimation(Animation.spring()) {
																selectedCategoryIndex = j != selectedCategoryIndex ? j : -1
															}
														}
														.onLongPressGesture(minimumDuration: 0.5) {
															if isOnboardingStepNumber(0) {
																onboardingManager.goToNextStep()
															}
															isEditMode = true
															self.groupId = groups[j].id
															selectedIndexes = translateUuidies(groups[j].modulesID)
															showEditModulePage.toggle()
															generator2?.impactOccurred()
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
								.mytooltip(isOnboardingStepNumber(0), config: tooltipConfig, appearingDelayValue: 0.5) {
									TooltipView(text: "Удерживайте, чтобы добавить \nили удалить модуль из группы",
												stepNumber: onboardingManager.currentStepIndex,
												allStepCount: onboardingManager.countOfSteps) {
										self.onboardingManager.goToNextStep()
									}
								}
								.mytooltip(isOnboardingStepNumber(2), config: tooltipConfig, appearingDelayValue: 0.5) {
									TooltipView(text: "Нажмите, чтобы увидеть \nмодули из этой группы",
												stepNumber: onboardingManager.currentStepIndex,
												allStepCount: onboardingManager.countOfSteps) {
										self.onboardingManager.goToNextStep()
									}
								}
								.zIndex(100)
								LazyVGrid(columns: columns, spacing: 14) {
									ForEach(0..<filteredModules.count, id: \.self) { i in
										NavigationLink(
											destination: ModuleScreen(
												modules: $modules,
												searchedText: $searchText,
												filteredModules: $filteredModules,
												index: i
											), label: {
												ModuleCard(
													width: moduleCardWidth,
													cardName: filteredModules[i].name,
													emoji: filteredModules[i].emoji,
													module: $filteredModules[i],
													isSelected: .constant(false)
												)
											})
										.disabled(onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
									}
									.listRowBackground(Color.green)
									.listStyle(.plain)
								}
								.padding()
								Rectangle()
									.frame(height: 100)
									.foregroundColor(.clear)
							}
						}
						.coordinateSpace(name: "RefreshControl")
						.edgesIgnoringSafeArea(.bottom)
						.setTrailingNavBarItem(disabled: onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage, completion: {
							print("settings")
						})
						.onChange(of: scrollOffset) { newValue in
							
							withAnimation(.easeInOut(duration: 0.1)) {
								showOrHideNavBar(value: newValue)
							}
							calculateScrollDirection()
						}
						BlurNavBar(show: $isInlineNavBar, scrollOffset: $scrollOffset)
						VStack {
							Spacer()
							if onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage {
								Button {
									onboardingManager.finish()
								} label: {
									Text("Пропустить обучение")
										.bold()
								}
								.padding(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0))
							}
							CreateModuleButton() {
								generator?.impactOccurred()
								showCreateModuleSheet = true
								onboardingManager.goToNextStep()
							}
								.frame(width: geometry.size.width - 60)
								.opacity(createModuleButtonOpacity)
								.transition(AnyTransition.offset() )
								.offset(y: geometry.size.height < 812 ? -16 : 0 )
								.disabled(!isOnboardingStepNumber(1) && onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
								.mytooltip(isOnboardingStepNumber(1), side: .top, config: tooltipConfig, appearingDelayValue: 0.5) {
									TooltipView(text: "Нажмите, чтобы создать \nновый модуль",
												stepNumber: onboardingManager.currentStepIndex,
												allStepCount: onboardingManager.countOfSteps) {
										self.onboardingManager.goToNextStep()
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
						if modules.count == 0 {
								Spacer()
								VStack(spacing: 16) {
									Spacer()
									Text("👀")
										.font(.system(size: 48))
									Text("There is nothing\nhere yet...")
										.multilineTextAlignment(.center)
										.font(.system(size: 20, weight: .medium))
										.opacity(0.72)
									Spacer()
								}
								.offset(y: -15)
								Spacer()
						}
					}
					.disabled(showActivity || showAlert)
				}
				.background(
					BackgroundView()
						.onTapGesture {
							UIApplication.shared.endEditing()
						}
				)
				.navigationTitle(LocalizedStringKey("Модули"))
				.onAppear{ router.showActivityView = false }
			}
			.onAppear{
				isOnAppear = true
				listenUserAuth()
				checkUser()
				fetchModules()
				fetchGroups()
				router.userIsAlreadyLaunched = true
			}
			.sheet(isPresented: $showCreateModuleSheet) {
				if UserDefaultsManager.userHasSubscription || !UserDefaultsManager.isNotFirstLaunchOfModulesPage {
					CreateModuleView(needUpdateData: $needUpdateData, showActivity: $showActivity, isOnboardingMode: onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage)
						.environmentObject(router)
				} else {
					Paywall(isOpened: $paywallIsOpened)
				}
			}
			.activity($showActivity)
			.onChange(of: needUpdateData) { _ in
				fetchModules()
				fetchGroups()
			}
			.onChange(of: modules, perform: { newValue in
				if searchText.count > 0 {
					filteredModules = modules.filter{ $0.name.contains("\(searchText)") }
				} else {
					filteredModules = modules
				}
			})
			.onChange(of: onboardingManager.isOnboardingMode, perform: { newValue in
				if !newValue {
					fetchGroups()
					fetchModules()
				}
			})
			.fullScreenCover(isPresented: $showSelectModulePage, content: {
				ModuleSelectPage(
					modules: $modules,
					isOpened: $showSelectModulePage,
					groupId: $groups[0].id,
					needUpdate: $needUpdateData,
					groups: $groups,
					isEditMode: $isEditMode
				)
			})
			.sheet(isPresented: $showEditModulePage, content: {
				ModuleSelectPage(
					modules: $modules,
					isOpened: $showEditModulePage,
					groupId: $groupId,
					needUpdate: $needUpdateData,
					groups: $groups,
					isEditMode: $isEditMode,
					isOnboardingMode: onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage,
					selectedIndexes: $selectedIndexes
				)
			})
			.showAlert(title: alert.title, description: alert.description, isPresented: $showAlert) {
				fetchModules()
			}
			.showAlert(title: alert.title, description: alert.description, isPresented: $showGroupsAlert) {
				fetchGroups()
			}
			.onChange(of: selectedCategoryIndex) { newValue in
				if newValue == -1 {
					filteredModules = modules
				}
			}
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
	}
	
	init() {
		configNavBarStyle()
		configTooltip()
	}
	
	private func isOnboardingStepNumber(_ value: Int) -> Bool {
		onboardingManager.isOnboardingMode
		&& onboardingManager.currentStepIndex == value
		&& !UserDefaultsManager.isNotFirstLaunchOfModulesPage
	}
	
	private mutating func configTooltip() {
		self.tooltipConfig.enableAnimation = true
		self.tooltipConfig.animationOffset = 10
		self.tooltipConfig.animationTime = 1
		self.tooltipConfig.backgroundColor = Color(asset: Asset.Colors.moduleCardDarkGray)
		self.tooltipConfig.borderWidth = 0
		self.tooltipConfig.zIndex = 1000
		self.tooltipConfig.contentPaddingBottom = 12
		self.tooltipConfig.contentPaddingTop = 12
		self.tooltipConfig.contentPaddingLeft = 16
		self.tooltipConfig.contentPaddingRight = 16
		self.tooltipConfig.borderRadius = 12
		self.tooltipConfig.shadowColor = .black.opacity(0.3)
		self.tooltipConfig.shadowRadius = 20
		self.tooltipConfig.shadowOffset = .init(x: 3, y: 20)
	}
	
	private func translateUuidies(_ uuidies: [String]) -> [Int] {
		var result: [Int] = []
		
		for uuid in uuidies {
			for (i, module) in modules.enumerated() {
				if module.id == uuid {
					result.append(i)
				}
			}
		}
		
		return result
	}
	
	private func pullDownToRefresh() {
		simpleSuccess()
		DispatchQueue.global().async {
			while scrollOffset < 0 {
				if scrollOffset >= 0 {
					fetchModules()
					fetchGroups()
					break
				}
			}
		}
	}
	
	func simpleSuccess() {
		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(.success)
	}
	
	private func fetchModules() {
		if onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage {
			modules = MockDataManager().modules
		} else {
			showActivity = true
			searchText = ""
			NetworkManager.getModules { modules in
				showActivity = false
				self.modules = modules
				self.filteredModules = modules
			} errorBlock: { errorText in
				showActivity = false
				guard !errorText.isEmpty else { return }
				showAlert(errorText: errorText)
			}
		}
	}
	
	private func fetchGroups() {
		if onboardingManager.isOnboardingMode && !UserDefaultsManager.isNotFirstLaunchOfModulesPage {
			groups = MockDataManager().groups
		} else {
			selectedCategoryIndex = -1
			showActivity = true
			NetworkManager.getGroups { groups in
				showActivity = false
				self.groups = groups
			} errorBlock: { errorText in
				showActivity = false
				guard !errorText.isEmpty else { return }
				showAlert(errorText: errorText)
			}
		}
	}
	
	private func showAlert(errorText: String) {
		withAnimation {
			showAlert.toggle()
		}
		alert.title = "Упс! Произошла ошибка"
		alert.description = errorText
	}
	
	private func configNavBarStyle() {
		let navigationBarAppearance = UINavigationBarAppearance()
		navigationBarAppearance.backgroundColor = UIColor.clear
		navigationBarAppearance.largeTitleTextAttributes = [
			.foregroundColor: UIColor.white
		]
		navigationBarAppearance.titleTextAttributes = [
			.foregroundColor: UIColor.white,
		]
		navigationBarAppearance.configureWithTransparentBackground()
		UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
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
			} else {
				// No user is signed in.
				withAnimation {
					router.userIsLoggedIn = false
				}
			}
			print("Current user:", auth.currentUser?.email)
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
}

struct BlurNavBar: View {
	@Binding var show: Bool
	@Binding var scrollOffset: CGFloat
	
	var opacity: Double {
		switch scrollOffset {
		case 0...100:
			return Double(scrollOffset) / 100.0
		case 100...:
			return 1
		default:
			return 0
		}
	}
	
	var body: some View {
		GeometryReader { geo in
			VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
				.frame(height: geo.safeAreaInsets.top)
				.foregroundColor(Color(asset: Asset.Colors.navBarPurple))
				.edgesIgnoringSafeArea(.top)
				.opacity(opacity)
		}
	}
}

struct BackgroundView: View {
	var body: some View {
		Image(asset: Asset.Images.gradientBG)
			.resizable()
			.edgesIgnoringSafeArea(.all)
	}
}

struct Modules_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			Modules()
				.environmentObject(Router())
		}
	}
}


struct RefreshControl: View {
	
	var coordinateSpace: CoordinateSpace
	var onRefresh: ()->Void
	
	@State private var refresh: Bool = false
	
	private let size: CGFloat = 25
	
	var body: some View {
		GeometryReader { geo in
			if (geo.frame(in: coordinateSpace).midY > 50) {
				Spacer()
					.onAppear {
						if refresh == false {
							onRefresh() ///call refresh once if pulled more than 50px
						}
						refresh = true
					}
			} else if (geo.frame(in: coordinateSpace).maxY < 1) {
				Spacer()
					.onAppear {
						refresh = false
						///reset  refresh if view shrink back
					}
			}
			ZStack(alignment: .center) {
				if refresh { ///show loading if refresh called
					ProgressView()
				} else { ///mimic static progress bar with filled bar to the drag percentage
					ForEach(0..<8) { tick in
						VStack {
							Rectangle()
								.fill(Color(asset: Asset.Colors.lightPurple))
								.opacity((Int((geo.frame(in: coordinateSpace).midY)/7) < tick) ? 0 : 1)
								.frame(width: size / 6.66666667, height: size / 2.85714286)
								.cornerRadius(size / 6.66666667)
							Spacer()
						}.rotationEffect(Angle.degrees(Double(tick)/(8) * 360))
					}.frame(width: size, height: size, alignment: .center)
				}
			}.frame(width: geo.size.width)
		}.padding(.top, -70)
	}
}
