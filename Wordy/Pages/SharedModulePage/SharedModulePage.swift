//
//  SharedModulePage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 06.10.2023.
//

import SwiftUI
import Combine

struct SharedModulePage: View {
	
	@Binding var needUpdateData: Bool
	@Binding var showActivity: Bool
	
	@State private var needAnimate = false
	@State var showEmojiView = false
	@State var moduleName = ""
	@State var emoji = "📄"
	@State var phrases: [Phrase] = []
	
	@State var disableClosing = false
	@State var onAppear = false
	@State var didTapOnEmoji = false
	let screenFullHeight: CGFloat
	
	@EnvironmentObject var router: Router
	@Environment(\.presentationMode) var presentation
	@EnvironmentObject var themeManager: ThemeManager
	@EnvironmentObject var deeplinkManager: DeeplinkManager
	@State var isNeedToShowTitle = false
	
	var body: some View {
		Color.clear
			.background {
				GeometryReader { geo in
					ZStack {
//						themeManager.currentTheme.main
//							.ignoresSafeArea()
                        BackgroundView()
                        VStack(spacing: geo.size.height < 812 ? 8 : 40) {
//							VStack(alignment: .leading) {
							if (isNeedToShowTitle) {
								Text(LocalizedStringKey("Вам прислали \nновый модуль 👇"))
									.foregroundColor(themeManager.currentTheme.mainText)
									.font(.system(size: 38, weight: .bold))
									.padding(EdgeInsets(top: 52, leading: 0, bottom: 0, trailing: 0))
//									.scaleEffect((geo.size.height > (screenFullHeight / 2 + 50))
//												 ? (screenFullHeight / geo.size.height)
//												 : 0)
//									.opacity(screenFullHeight / geo.size.height)
								//								.offset(y: needAnimate ? 0 : 100)
								//								Text(LocalizedStringKey("\(moduleName)"))
								////									.foregroundColor(themeManager.currentTheme.mainText)
								//									.font(.system(size: 24, weight: .medium))
								//									.foregroundColor(themeManager.currentTheme.accent)
								//							}
								//							.padding()
							}
							
							Spacer()
							
							// Card
							
							if UIScreen.main.bounds.height < 812 {
								CreateModuleCard(
									width: geo.size.width - 164,
									needAnimate: $needAnimate,
									showEmojiView: $showEmojiView,
									emoji: $emoji,
									moduleName: $moduleName,
                                    isNeedOpenKeyboard: .constant(false),
                                    isDisabledOnboarding: true,
                                    withoutKeyboard: true
								) {
									createModule()
								}
								.shadow(radius: 19)
							} else {
								CreateModuleCard(
									width: ((geo.size.width - 250) + geo.size.height * 0.1),
									needAnimate: $needAnimate,
									showEmojiView: $showEmojiView,
									emoji: $emoji,
									moduleName: $moduleName,
                                    isNeedOpenKeyboard: .constant(false),
                                    isDisabledOnboarding: true,
									withoutKeyboard: true
								) {
									createModule()
								}
								.shadow(radius: 19)
								.ignoresSafeArea()
								.rotation3DEffect(
									Angle(degrees: onAppear ? 0 : 5),
									axis: (x: 0.5, y: 0.0, z: 0.0)
								)
								.offset(y: onAppear ? 0 : -10)
								.animation(.interpolatingSpring(stiffness: 170,
																damping: 8)
									.delay(0.3),
										   value: onAppear)
							}
							
							Spacer()
							
							// Button
							
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
                                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                                    }
									Text(LocalizedStringKey("Принять"))
										.foregroundColor(themeManager.currentTheme.mainText)
										.font(.system(size: 18, weight: .bold))
										.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
								}
								.frame(height: 50)
								.padding(EdgeInsets(top: 6, leading: 32, bottom: 6, trailing: 32))
								.background(themeManager.currentTheme.moduleCreatingBtn)
								.cornerRadius(17)
								//								.offset(y: needAnimate ? 0 : 300)
							}
							
							Spacer()
						}
					}
//					.frame(width: geo.size.width, height: geo.size.height)
					.onAppear{
						withAnimation(.spring()) {
							needAnimate = true
						}
					}
					.onChange(of: geo.size.height) { newValue in
						isNeedToShowTitle = newValue >= screenFullHeight - 100
					}
				}
			}
			.task {
				showActivity = true
				guard let (moduleID, userID) = deeplinkManager.currentType.getData() as? (String, String)
				else { return }
				NetworkManager.getModule(with: moduleID,
										 fromUser: userID) { module in
					showActivity = false
					emoji = module.emoji
					moduleName = module.name
					phrases = module.phrases
				} errorBlock: { error in
					showActivity = false
				}
				
			}
			.activity($showActivity)
//			.interactiveDismissDisabled(showEmojiView)
			.onAppear {
//				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					onAppear = true
//				}
			}
			.onChange(of: showEmojiView) { newValue in
				
			}
			.animation(.default, value: isNeedToShowTitle)
	}
	
	private func createModule() {
		showActivity = true
		NetworkManager.createModule(name: moduleName, emoji: emoji, phrases: phrases) { successResult in
			needUpdateData.toggle()
			self.presentation.wrappedValue.dismiss()
		} errorBlock: { error in

		}
	}
}

struct SharedModulePage_Previews: PreviewProvider {
	static var previews: some View {
		CreateModuleView(needUpdateData: .constant(false), showActivity: .constant(false))
			.environmentObject(Router())
			.environmentObject(ThemeManager())
			.environmentObject(DeeplinkManager())
	}
}
