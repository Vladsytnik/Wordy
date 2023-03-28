//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 10.12.2022.
//

import SwiftUI
import Firebase

struct ModuleSelectPage: View {
	
	private let columns = [GridItem(.adaptive(minimum: 150), spacing: 20) ]
	
	@Binding var modules: [Module]
	
	@State private var scrollOffset = CGFloat.zero
	@State private var scrollDirection = CGFloat.zero
	@State private var prevScrollOffsetValue = CGFloat.zero
	@State private var isInlineNavBar = false
	@State private var showActivity = false
	@State private var needUpdateData = false
	@State private var showAlert = false
	@State private var alert = (title: "", description: "")
	@State private var showCreateModuleSheet = false
	@State private var createModuleButtonOpacity = 1.0
	
	@State private var testWords: [String] = ["Эйфория", "Хороший доктор", "Мистер робот", "Нулевой пациент"]
	
	@State private var selectedCardIndex = -1
	@State private var animations: Array<Bool> = []
	@Binding var isOpened: Bool
	let groupName: String
	
	private var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
	
	init(modules: Binding<[Module]>, isOpened: Binding<Bool>, groupName: String) {
		animations = Array(repeating: false, count: modules.count)
		self._modules = modules
		self._isOpened = isOpened
		self.groupName = groupName
	}
	
	var body: some View {
		Color.clear
			.background {
				GeometryReader { geometry in
					ZStack {
						ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
							VStack {
								VStack {
									Rectangle()
										.frame(height: 16)
										.foregroundColor(.clear)
									HStack {
										Text(groupName)
											.foregroundColor(.white)
											.font(.system(size: 36, weight: .bold))
										Spacer()
									}
									.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
								}
								LazyVGrid(columns: columns, spacing: 14) {
									ForEach(0..<modules.count, id: \.self) { i in
										Button {
											print("did select \(i)")
											selectedCardIndex = i
										} label: {
											ModuleCard(
												width: 170,
												cardName: modules[i].name,
												emoji: modules[i].emoji,
												module: $modules[i],
												isSelected: $animations[i]
											)
											.animateSelected(isSelected: $animations[i])
										}
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
							SaveButton() {
								generator?.impactOccurred()
								isOpened.toggle()
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
			}
			.activity($showActivity)
			.showAlert(title: alert.title, description: alert.description, isPresented: $showAlert) {
				fetchModules()
			}
			.onChange(of: selectedCardIndex) { newValue in
				createAnimations()
			}
	}
	
	func createAnimations() {
		if selectedCardIndex >= 0 && animations.count > 0 {
			animations[selectedCardIndex].toggle()
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
			guard !errorText.isEmpty else { return }
			withAnimation {
				showAlert.toggle()
			}
			alert.title = "Упс! Произошла ошибка"
			alert.description = errorText
		}
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
}

struct ModuleSelectPage_Previews: PreviewProvider {
	static var previews: some View {
		ModuleSelectPage(modules: .constant([]), isOpened: .constant(false), groupName: "test group")
	}
}


fileprivate struct SaveButton: View {
	
	let action: () -> Void
	
	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 20)
					.foregroundColor(Color(asset: Asset.Colors.createModuleButton))
					.shadow(color: .white.opacity(0.15), radius: 20)
				HStack {
					Text("Сохранить")
						.foregroundColor(.white)
						.font(.system(size: 16, weight: .medium))
				}
			}
		}
		.frame(height: 55)
	}
}
