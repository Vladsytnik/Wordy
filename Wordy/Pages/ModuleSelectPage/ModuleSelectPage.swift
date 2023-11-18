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
	@Binding var needUpdate: Bool
	
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
	@Binding var groupId: String
	@Binding var groups: [Group]
	
	private var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
	
	@State private var modulesStates: [Int: Bool] = [:]
	@State private var addedModules: [Module] = []
	
	@Binding var selectedIndexes: [Int]
	@Binding var isEditMode: Bool
    
	var isOnboardingMode = false
    var isJustNeedToReturnSelectedModules = false
    var onReturnSelectedModules: (([Module]) -> Void)?
    var onReturnSelectedIndexes: (([Int]) -> Void)?
    
	@EnvironmentObject var themeManager: ThemeManager
	
	private var currentGroup: Group {
		groups.first(where: { $0.id == groupId }) ?? Group()
	}
	
	init(modules: Binding<[Module]>,
		 isOpened: Binding<Bool>,
		 groupId: Binding<String>,
		 needUpdate: Binding<Bool>,
		 groups: Binding<[Group]>,
		 isEditMode: Binding<Bool>,
		 isOnboardingMode: Bool = false,
		 selectedIndexes: Binding<[Int]>? = nil,
         isJustNeedToReturnSelectedModules: Bool = false,
         onReturnSelectedModules: (([Module]) -> Void)? = nil,
         onReturnSelectedIndexes: (([Int]) -> Void)? = nil) {
		animations = Array(repeating: false, count: modules.count)
		
        self.isJustNeedToReturnSelectedModules = isJustNeedToReturnSelectedModules
		self._modules = modules
		self._isOpened = isOpened
		self._groupId = groupId
		self._needUpdate = needUpdate
		self._selectedIndexes = selectedIndexes ?? .constant([])
		self._groups = groups
		self._isEditMode = isEditMode
		self.isOnboardingMode = isOnboardingMode
        self.onReturnSelectedModules = onReturnSelectedModules
        self.onReturnSelectedIndexes = onReturnSelectedIndexes
		
		let stateKeys = modulesStates.keys.map{ Int($0) }
		stateKeys.forEach{ modulesStates[$0] = false }
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
										Text(currentGroup.name)
											.foregroundColor(themeManager.currentTheme.mainText)
											.font(.system(size: 36, weight: .bold))
										Spacer()
//										Button {
//
//										} label: {
//											Image(systemName: "trash.fill")
//												.resizable()
//												.frame(width: 25, height: 25)
//												.foregroundColor(.red)
//												.opacity(0.85)
//										}
//										.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
									}
									.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
								}
								LazyVGrid(columns: columns, spacing: 14) {
									ForEach(0..<modules.count, id: \.self) { i in
										Button {
											
										} label: {
											ModuleCard(
												width: 170,
												cardName: modules[i].name,
												emoji: modules[i].emoji,
												module: $modules[i],
												isSelected: animations.count > 0 ? $animations[i] : .constant(false)
											)
											.animateSelected(isSelected: animations.count > 0 ? $animations[i] : .constant(false), index: i, selectedCardIndex: $selectedCardIndex)
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
								createNewGroupOrChangeExisting()
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
				.navigationTitle(LocalizedStringKey("Модули"))
			}
			.activity($showActivity)
			.showAlert(title: alert.title, description: alert.description, isPresented: $showAlert) {
				fetchModules()
			}
			.onChange(of: animations) { newValue in
				print("test")
				if modulesStates[selectedCardIndex] == nil {
					if selectedIndexes.contains(selectedCardIndex) {
						modulesStates[selectedCardIndex] = false
					} else {
						modulesStates[selectedCardIndex] = true
					}
				} else {
					modulesStates[selectedCardIndex]?.toggle()
				}
				
				print(modulesStates)
			}
			.onAppear{
				if selectedIndexes.count > 0 {
					if animations.count > 0 {
						selectedIndexes.forEach{ animations[$0] = true }
					}
				}
			}
			.activity($showActivity)
	}
	
	func createNewGroupOrChangeExisting() {
        guard !isJustNeedToReturnSelectedModules else {
            let newSelectedIndexes = modulesStates
                .filter{ $0.value == true && $0.key >= 0 }
                .compactMap { (key, value) in
                    return  key
                }
            
            var allSelectedIndexes = newSelectedIndexes + self.selectedIndexes
            
            for (moduleIndex, isSelected) in modulesStates {
                if !isSelected && moduleIndex >= 0 {
                    allSelectedIndexes.removeAll(where: { $0 == moduleIndex })
                }
            }
            
            let selectedModules = allSelectedIndexes.map { modules[$0] }
            print("selectedIndexes: \(selectedIndexes)")
            print("self.selectedIndexes: \(self.selectedIndexes)")
            
            onReturnSelectedModules?(selectedModules)
            onReturnSelectedIndexes?(allSelectedIndexes)
            isOpened.toggle()
            return
        }
                
		if isOnboardingMode {
			isOpened.toggle()
		} else {
			isEditMode ? changeGroup() : createNewGroup()
		}
	}
	
	private func createNewGroup() {
		showActivity = true
		let modulesIndexes = modulesStates.filter{ $0.value == true && $0.key >= 0 }.keys.map{ Int($0) }
		modulesIndexes.forEach{ addedModules.append(modules[$0]) }
		NetworkManager.createGroup(name: currentGroup.name, modules: addedModules) { _ in
			generator?.impactOccurred()
			needUpdate.toggle()
			showActivity = false
			isOpened.toggle()
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
	
	private func changeGroup() {
		showActivity = true

		selectedIndexes.forEach{ if modulesStates[$0] == nil { modulesStates[$0] = true } }
		let modulesIndexes = modulesStates.filter{ $0.value == true && $0.key >= 0 }.keys.map{ Int($0) }
		modulesIndexes.forEach{ addedModules.append(modules[$0]) }
		
		guard let group = groups.first(where: { $0.id == groupId }) else { return }
		
		NetworkManager.changeGroup(group, modules: addedModules) { _ in
			generator?.impactOccurred()
			needUpdate.toggle()
			showActivity = false
			isOpened.toggle()
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
		ModuleSelectPage(
			modules: .constant([]),
			isOpened: .constant(false),
//			groupName: "test group",
			groupId: .constant("test group"),
			needUpdate: .constant(false),
			groups: .constant([]),
			isEditMode: .constant(false)
		)
	}
} 


fileprivate struct SaveButton: View {
	
    @Environment(\.colorScheme) var colorScheme
	let action: () -> Void
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
                if themeManager.currentTheme.id == "MainColor"
                    && colorScheme == .light
                {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(asset: Asset.Colors.main))
                        .shadow(color: .white.opacity(0.15), radius: 20)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(themeManager.currentTheme.moduleCreatingBtn)
                        .shadow(color: .white.opacity(0.15), radius: 20)
                }
                HStack {
                    Text(LocalizedStringKey("Сохранить"))
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
		.frame(height: 55)
	}
}
