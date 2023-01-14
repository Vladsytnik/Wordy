//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 10.12.2022.
//

import SwiftUI
import Firebase

struct Modules: View {
	
	private let columns = [GridItem(.adaptive(minimum: 150), spacing: 20) ]
	
	@State private var scrollOffset = CGFloat.zero
	@State private var scrollDirection = CGFloat.zero
	@State private var prevScrollOffsetValue = CGFloat.zero
	@State private var isInlineNavBar = false
	@State private var searchText = ""
	@State private var createModuleButtonOpacity = 1.0
	@State private var showCreateModuleSheet = false
	@State private var showActivity = false
	
	@EnvironmentObject var router: Router
	
	@State var pullToRefresh = false
	
	@State private var showSettings = false
	@State private var modules: [Module] = []
	
	@State private var needUpdateData = false
	
	@State var showAlert = false
	@State var alert = (title: "", description: "")
	
	var body: some View {
		Color.clear
			.background {
				GeometryReader { geometry in
					ZStack {
						ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
							VStack {
								RefreshControl(coordinateSpace: .named("RefreshControl")) { pullDownToRefresh() }
								SearchTextField(searchText: $searchText, placeholder: "Search")
									.padding(.leading)
									.padding(.trailing)
									.padding(.top)
								ScrollView(.horizontal, showsIndicators: false) {
									HStack(spacing: 12) {
										ForEach(0...10, id: \.self) { j in
											CategoryCard(text: "\(j)")
												.padding(j == 0 ? .leading : j == 10 ? .trailing : .init())
										}
									}
								}
								.padding(.top)
								LazyVGrid(columns: columns, spacing: 14) {
									ForEach(0..<modules.count, id: \.self) { i in
										NavigationLink(destination: ModuleScreen(modules: $modules, index: i), label: {
											ModuleCard(
												width: 170,
												cardName: modules[i].name,
												emoji: modules[i].emoji
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
								showCreateModuleSheet = true
							}
								.frame(width: geometry.size.width - 60)
								.opacity(createModuleButtonOpacity)
								.transition(AnyTransition.offset() )
						}
					}
					.disabled(showActivity || showAlert)
				}
				.background(BackgroundView())
				.navigationTitle("Модули")
				.onAppear{ router.showActivityView = false }
			}
			.onAppear{
				listenUserAuth()
				checkUser()
				fetchModules()
			}
			.sheet(isPresented: $showCreateModuleSheet) {
				CreateModuleView(needUpdateData: $needUpdateData, showActivity: $showActivity)
				.environmentObject(router)
			}
			.activity($showActivity)
			.onChange(of: needUpdateData) { _ in
				fetchModules()
			}
			.showAlert(title: alert.title, description: alert.description, isPresented: $showAlert) {
				fetchModules()
			}
	}
	
	init(){
		configNavBarStyle()
	}
	
	private func pullDownToRefresh() {
		simpleSuccess()
		DispatchQueue.global().async {
			while scrollOffset < 0 {
				if scrollOffset >= 0 {
					fetchModules()
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
		NetworkManager.getModules { modules in
			showActivity = false
			self.modules = modules
		} errorBlock: { errorText in
			showActivity = false
			withAnimation {
				showAlert.toggle()
			}
			alert.title = "Упс! Произошла ошибка"
			alert.description = errorText
		}
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
	@State var refresh: Bool = false
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
								.fill(Color(UIColor.tertiaryLabel))
								.opacity((Int((geo.frame(in: coordinateSpace).midY)/7) < tick) ? 0 : 1)
								.frame(width: 3, height: 7)
								.cornerRadius(3)
							Spacer()
						}.rotationEffect(Angle.degrees(Double(tick)/(8) * 360))
					}.frame(width: 20, height: 20, alignment: .center)
				}
			}.frame(width: geo.size.width)
		}.padding(.top, -50)
	}
}
