//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 10.12.2022.
//

import SwiftUI
import Firebase

struct Modules: View {
	
	private let columns = [GridItem(.adaptive(minimum: UIScreen.main.bounds.height < 812 ? 100 : 150),
									spacing: UIScreen.main.bounds.height < 812 ? 10 : 20) ]
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
	
	@State var selectedIndexes: [Int] = []
	@State var isEditMode = false
	
	private var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
	private var generator2: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .soft)
	
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
															withAnimation(Animation.spring()) {
																selectedCategoryIndex = j != selectedCategoryIndex ? j : -1
															}
														}
														.onLongPressGesture(minimumDuration: 0.5) {
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
						.setTrailingNavBarItem(completion: {
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
							CreateModuleButton() {
								generator?.impactOccurred()
								showCreateModuleSheet = true
							}
								.frame(width: geometry.size.width - 60)
								.opacity(createModuleButtonOpacity)
								.transition(AnyTransition.offset() )
						}
						.ignoresSafeArea(.keyboard)
					}
					.disabled(showActivity || showAlert)
				}
				.background(
					BackgroundView()
						.onTapGesture {
							UIApplication.shared.endEditing()
						}
				)
				.navigationTitle("Модули")
				.onAppear{ router.showActivityView = false }
			}
			.onAppear{
				listenUserAuth()
				checkUser()
				fetchModules()
				fetchGroups()
			}
			.sheet(isPresented: $showCreateModuleSheet) {
				CreateModuleView(needUpdateData: $needUpdateData, showActivity: $showActivity)
				.environmentObject(router)
			}
//			.sheet(isPresented: $showCreateGroupSheet, content: {
//
//			})
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
	}
	
	init() {
		configNavBarStyle()
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
	
	private func fetchGroups() {
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
