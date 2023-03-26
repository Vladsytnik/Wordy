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
	
	@State private var testWords: [String] = ["Эйфория", "Хороший доктор", "Мистер робот", "Нулевой пациент"]
	
	private var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
	
	init(modules: Binding<[Module]>) {
		self._modules = modules
	}
	
	var body: some View {
		Color.clear
			.background {
				GeometryReader { geometry in
					ZStack {
						ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
							VStack {
								LazyVGrid(columns: columns, spacing: 14) {
									ForEach(0..<modules.count, id: \.self) { i in
										Button {
											print("did select \(i)")
										} label: {
											ModuleCard(
												width: 170,
												cardName: modules[i].name,
												emoji: modules[i].emoji,
												module: $modules[i]
											)
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
	}
}

struct ModuleSelectPage_Previews: PreviewProvider {
	static var previews: some View {
		ModuleSelectPage(modules: .constant([]))
	}
}

