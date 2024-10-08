//
//  CreateModuleView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 23.12.2022.
//

import SwiftUI
import MCEmojiPicker

struct CreateModuleView: View {
	
	@Binding var needUpdateData: Bool
	@Binding var showActivity: Bool
	@State private var needAnimate = false
	@State var showEmojiView = false
	@State var moduleName = ""
    
    @State var emoji = "📄"
	
	var isOnboardingMode = false
    var isNotAbleToChangeIcon = false
    
	@State var disableClosing = false
//	let action: () -> Void
	
	@EnvironmentObject var router: Router
	@Environment(\.presentationMode) var presentation
	@EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var rewardManager: RewardManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var isNeedOpenKeyboard = false
    
    @AppStorage("isFirstModuleRewardShown") private var isFirstModuleRewardShown = false
	
    var body: some View {
//		Color.clear
//			.background {
				GeometryReader { geo in
					ZStack {
                        BackgroundView()
                        
                        VStack(spacing:  UIScreen.main.bounds.height < 812 ? 16 : 40) {
							Text("Новый модуль".localize())
								.foregroundColor(themeManager.currentTheme.mainText)
								.font(.system(size: 38, weight: .bold))
                                .padding(EdgeInsets(top: UIScreen.main.bounds.height < 812 ? 16 : 52, leading: 0, bottom: 0, trailing: 0))
//								.offset(y: needAnimate ? 0 : 100)
							if UIScreen.main.bounds.height < 812 {
								CreateModuleCard(
									width: geo.size.width - 164,
									needAnimate: $needAnimate,
									showEmojiView: $showEmojiView,
									emoji: $emoji,
									moduleName: $moduleName,
                                    isNeedOpenKeyboard: $isNeedOpenKeyboard,
                                    isNotAbleToChangeIcon: isNotAbleToChangeIcon
								) {
									createModule()
								}
								.shadow(radius: 19)
							} else {
								CreateModuleCard(
									width: geo.size.width - 200,
									needAnimate: $needAnimate,
									showEmojiView: $showEmojiView,
									emoji: $emoji,
									moduleName: $moduleName,
                                    isNeedOpenKeyboard: $isNeedOpenKeyboard,
                                    isNotAbleToChangeIcon: isNotAbleToChangeIcon
								) {
									createModule()
								}
								.shadow(radius: 19)
								.ignoresSafeArea()
							}
							Button {
								guard !moduleName.isEmpty else { return }
								createModule()
							} label: {
								HStack(spacing: 12) {
                                    if themeManager.currentTheme.isDark {
                                        Image(asset: Asset.Images.addModuleCheckMark)
                                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                                    } else {
                                        Image(asset: Asset.Images.addModuleCheckMark)
                                            .renderingMode(.template)
                                            .colorMultiply(themeManager.currentTheme.mainText)
//                                            .opacity(themeManager.currentTheme.isDark ? 1 : 0.75)
                                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                                    }
									
									Text("Добавить".localize())
										.foregroundColor(themeManager.currentTheme.mainText)
										.font(.system(size: 18, weight: .bold))
										.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
								}
								.frame(height: 50)
								.padding(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24))
								.background(themeManager.currentTheme.moduleCreatingBtn)
								.cornerRadius(17)
//								.offset(y: needAnimate ? 0 : 300)
							}
							Spacer()
						}
//						if showEmojiView {
////							EmojiView(show: $showEmojiView, txt: $emoji)
//							ZStack {
//								EmojiPopoverView(showEmojiView: $showEmojiView, emoji: $emoji)
//                                    .onAppear { AnalyticsManager.shared.trackEvent(.didTapOnChangeEmoji(.CreateNewModulePage)) }
//								VStack(alignment: .trailing) {
//									Spacer()
//									Button {
//										withAnimation {
//											showEmojiView.toggle()
//										}
//                                        isNeedOpenKeyboard = true
//									} label: {
//                                        Text("Готово".localize())
//											.bold()
//											.padding(EdgeInsets(top: 12, leading: 30, bottom: 12, trailing: 30))
//											.foregroundColor(themeManager.currentTheme.mainText)
//											.background {
//												RoundedRectangle(cornerRadius: 15)
//													.foregroundColor(themeManager.currentTheme.accent)
//											}
//											.opacity(0.95)
//									}
//								}
//								.padding()
//								.offset(y: -64)
//							}
//						}
                        
                        
//                        if showEmojiView {
////                            EmojiView(show: $showEmojiView, txt: $emoji)
//                            
//                            ZStack {
////                                EmojiPopoverView(showEmojiView: $showEmojiView, emoji: $emoji)
////                                    .onAppear { AnalyticsManager.shared.trackEvent(.didTapOnChangeEmoji(.CreateNewModulePage)) }
//                                VStack(alignment: .trailing) {
//                                    Spacer()
//                                    Button {
//                                        withAnimation {
//                                            showEmojiView.toggle()
//                                        }
//                                        isNeedOpenKeyboard = true
//                                    } label: {
//                                        Text("Готово".localize())
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
					.frame(width: geo.size.width, height: geo.size.height)
					.onAppear{
						withAnimation(.spring()) {
							needAnimate = true
						}
					}
				}
//			}
			.activity($showActivity)
//			.interactiveDismissDisabled(showEmojiView)
            .onChange(of: emoji) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isNeedOpenKeyboard.toggle()
                }
            }
            .onChange(of: showEmojiView) { _ in
                if !showEmojiView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.isNeedOpenKeyboard.toggle()
                    }
                }
            }
            .onAppear {
//                isFirstModuleRewardShown = false
                AnalyticsManager.shared.trackEvent(.openCreateNewModulePage)
            }
//            .overlay {
//                MCEmojiPickerRepresentableController(
//                    isPresented: $showEmojiView,
//                    selectedEmoji: $emoji,
//                    arrowDirection: .none
//                )
//                .allowsHitTesting(false)
//            }
    }
	
	private func createModule() {
		if isOnboardingMode {
			self.presentation.wrappedValue.dismiss()
		} else {
            
            let continueCreatingModule = { (addedModule: Module, needAddingToDataManager: Bool) in
                self.presentation.wrappedValue.dismiss()
                showActivity = false
                
                if needAddingToDataManager {
                    DataManager.shared.addModule(addedModule)
                }
                
                if !isFirstModuleRewardShown {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        rewardManager.showReward.toggle()
                        isFirstModuleRewardShown = true
                    }
                }
            }
            
			showActivity = true
			NetworkManager.createModule(name: moduleName, emoji: emoji) { addedModule in
//				needUpdateData.toggle()
                
                let isSelectedSomeGroup = dataManager.selectedCategoryIndex >= 0
                if isSelectedSomeGroup {
                    let selectedGroup = dataManager.groups[dataManager.selectedCategoryIndex]
                    var selectedModules = selectedGroup.modulesID
//                    newModules.append(addedModule.id)
//                    DataManager.shared.addModule(addedModule)
                    var modules = dataManager.allModules.filter { selectedModules.contains($0.id) }
                    modules.append(addedModule)
                    
                    NetworkManager.changeGroup(selectedGroup, modules: modules) { _ in
                        dataManager.groups[dataManager.selectedCategoryIndex].modulesID.append(addedModule.id)
                        dataManager.addModule(addedModule)
//                        dataManager.addToSelectedGroupModuleId(addedModule.id)
                        continueCreatingModule(addedModule, false)
                    } errorBlock: { errorText in
                        
                    }

                } else {
                    continueCreatingModule(addedModule, true)
                }
			} errorBlock: { error in
				
			}
		}
	}
}

struct CreateModuleView_Previews: PreviewProvider {
    static var previews: some View {
		CreateModuleView(needUpdateData: .constant(false), showActivity: .constant(false))
			.environmentObject(Router())
			.environmentObject(ThemeManager())
            .environmentObject(RewardManager())
            .environmentObject(DataManager.shared)
    }
}

// MARK: - EmojiPopoverView

struct EmojiPopoverView: UIViewControllerRepresentable {
	
	
	@Binding var showEmojiView: Bool
	@Binding var emoji: String
	let countForFree = 10
	
	private let viewController = MCEmojiPickerViewController()
	
	func makeUIViewController(context: Context) -> UIViewController {
		viewController.isDismissAfterChoosing = false
		return viewController
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
	
	func makeCoordinator() -> Coordinator {
		Coordinator(vc: viewController, emoji: $emoji, show: $showEmojiView)
	}
	
	class Coordinator: NSObject, MCEmojiPickerDelegate {
		@Binding var showEmojiView: Bool
		@Binding var emoji: String
		
		init(vc: MCEmojiPickerViewController, emoji: Binding<String>, show: Binding<Bool>) {
			self._emoji = emoji
			self._showEmojiView = show
			super.init()
			vc.delegate = self
		}
		
		func didGetEmoji(emoji: String) {
			self.emoji = emoji
			withAnimation {
				showEmojiView.toggle()
			}
		}
		
	}
}
