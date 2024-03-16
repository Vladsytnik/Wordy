//
//  CreateModuleCard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 23.12.2022.
//

import SwiftUI
import MCEmojiPicker


extension View {
    @ViewBuilder public func myEmojiPicker(
        isPresented: Binding<Bool>,
        selectedEmoji: Binding<String>,
        arrowDirection: MCPickerArrowDirection? = nil,
        customHeight: CGFloat? = nil,
        horizontalInset: CGFloat? = nil,
        isDismissAfterChoosing: Bool? = nil,
        selectedEmojiCategoryTintColor: UIColor? = nil,
        feedBackGeneratorStyle: UIImpactFeedbackGenerator.FeedbackStyle? = nil,
        colorScheme: ColorScheme
    ) -> some View {
        self.overlay(
            MCEmojiPickerRepresentableController(
                isPresented: isPresented,
                selectedEmoji: selectedEmoji,
                arrowDirection: arrowDirection,
                customHeight: customHeight,
                horizontalInset: horizontalInset,
                isDismissAfterChoosing: isDismissAfterChoosing,
                selectedEmojiCategoryTintColor: selectedEmojiCategoryTintColor,
                feedBackGeneratorStyle: feedBackGeneratorStyle
            )
                .allowsHitTesting(false)
                .colorScheme(colorScheme)
        )
    }
}


struct CreateModuleCard: View {
    
	@EnvironmentObject var themeManager: ThemeManager
	let width: CGFloat
	
	@Binding var needAnimate: Bool
	@Binding var showEmojiView: Bool
	@Binding var emoji: String
	@Binding var moduleName: String
    @Binding var isNeedOpenKeyboard: Bool
    
    @State var internalShowEmojiView = false
    
    var isNotAbleToChangeIcon = false
    
    var isDisabledOnboarding = false
	
	let cardName = "Games"
	let words = [
		"Dude",
		"Get on well",
		"Map",
		"Word"
	]
	var withoutKeyboard = false
	let action: () -> Void
	
	private var height: CGFloat {
		width / 0.9268
	}
    
    @Environment(\.colorScheme) var colorScheme

    @StateObject private var onboardingManager = OnboardingManager(screen: .moduleScreen,
                                                                   countOfSteps: 1)
    @State var screenWidth: CGFloat = 0
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 35.0)
				.foregroundColor(themeManager.currentTheme.main)
				.frame(width: width, height: height)
				.shadow(color: .black.opacity(0.1), radius: 8, x: 10, y: 10)
			VStack {
				Spacer()
				Button {
                    isNeedOpenKeyboard = false
                    onboardingManager.goToNextStep()
					withAnimation(.spring()) {
						UIApplication.shared.endEditing()
						showEmojiView = true
//                        internalShowEmojiView = true
					}
				} label: {
					ZStack(alignment: .topTrailing) {
						Text(emoji)
							.font(.system(size: width / 3.16666))
						Image(asset: Asset.Images.plusIcon)
//                        Image(systemName: "ellipsis.circle.fill")
							.resizable()
							.frame(width: 24, height: 24)
                            .background {
                                Circle()
                                    .foregroundColor(isDark() ? .black : .white)
                                    .frame(width: 16, height: 16)
                            }
							.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
                            .opacity(emoji == "📄" && !isNotAbleToChangeIcon ? 1 : 0)
					}
				}
                .myEmojiPicker(
                    isPresented: $showEmojiView,
                    selectedEmoji: $emoji,
                    selectedEmojiCategoryTintColor: UIColor(themeManager.currentTheme.accent),
                    colorScheme: isDark() ? .light : .dark
                )
                .mytooltip(onboardingManager.currentStepIndex == 0
                          && !UserDefaultsManager.isUserSawCreateNewModule
                           && !isDisabledOnboarding,
                           config: nil,
                           appearingDelayValue: 1.5) {
                    let text = "Нажмите для выбора эмодзи".localize()
                    TooltipView(text: text,
                                stepNumber: 0,
                                allStepCount: 1,
                                withoutSteps: true,
                                description: nil, 
                                onDisappear: {
                        UserDefaultsManager.isUserSawCreateNewModule = true
                    }) {
                        onboardingManager.goToNextStep()
                    }
                }
                .zIndex(100)
                
				Spacer()
                
				InputRoundedTextArea(
					moduleName: $moduleName,
                    needOpenKeyboard: $isNeedOpenKeyboard,
                    cardWidth: width,
					cardName: cardName,
					words: words,
					withoutKeyboard: withoutKeyboard
				) { action() }
			}
			.frame(width: width, height: height)
			.offset(y: -7)
		}
        .background {
            GeometryReader { geo in
                EmptyView()
                    .onAppear {
                        self.screenWidth = geo.size.width
                    }
            }
        }
        .onChange(of: showEmojiView, perform: { value in
            if showEmojiView {
                AnalyticsManager.shared.trackEvent(.didTapOnChangeEmoji(.CreateNewModulePage))
            }
        })
//		.offset(y: needAnimate ? 0 : 200)
	}
    
    private func isDark() -> Bool {
        themeManager.currentTheme.isSupportLightTheme
        ? colorScheme != .light
        : themeManager.currentTheme.isDark
    }
}

struct CreateModuleCard_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			Color(asset: Asset.Colors.main).ignoresSafeArea()
			CreateModuleCard(
                width: 250,
                needAnimate: .constant(false),
                showEmojiView: .constant(false),
                emoji: .constant("📄"),
                moduleName: .constant(""),
                isNeedOpenKeyboard: .constant(false)
			) {}
		}
    }
}

struct EmojiView : View {
	
	@Binding var show : Bool
	@Binding var txt : String
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject var themeManager: ThemeManager
	
	let emojiRanges = [
		(0x1F601, 0x1F64F),
		(0x2702, 0x27B0),
		(0x1F680, 0x1F6C0),
		(0x1F170, 0x1F251)
	]
	
	private let emojies = ["", "🧸", "🎀", "🎏", "📄", "🎊", "❤️", "❤️‍🔥", "💜", "🔐", "🔅", "❗️", "Ⓜ️", "👾", "🧑🏻‍💻", "🌍", "😵‍💫", "🔮"]
	
	var body : some View{
		ZStack(alignment: .topLeading) {
			ScrollView(.vertical, showsIndicators: false) {
//				VStack(spacing: 15){
//					ForEach(["🧸", "🎀"], id: \.self) { i in
//						HStack(spacing: 25){
//							ForEach(i, id: \.self){ j in
//								Button(action: {
//									self.txt = String(UnicodeScalar(j)!)
//									show.toggle()
//								}) {
//									if (UnicodeScalar(j)?.properties.isEmoji)! {
//										Text(String(UnicodeScalar(j)!)).font(.system(size: 55))
//									}
//								}
//							}
//						}
//					}
//				}
				
				LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20, content: {
					ForEach(0..<emojies.count) { i in
						ZStack {
							if i == 0 {
								Button(action: {
									withAnimation(.spring()) {
										show.toggle()
									}
								}) {
									Image(asset: Asset.Images.closeEmoji)
										.resizable()
										.frame(width: 30, height: 30)
								}
							} else {
								Button(action: {
									self.txt = emojies[i]
									withAnimation(.spring()) {
										show.toggle()
									}
								}) {
									Text(emojies[i]).font(.system(size: 55))
								}
							}
						}
					}
				})
				.padding()
			}.frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.height / 3)
//				.padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
				.background(themeManager.currentTheme.moduleCardRoundedAreaColor)
				.cornerRadius(25)
//			Button(action: {
//				self.show.toggle()
//			}) {
//				Image(systemName: "xmark").foregroundColor(themeManager.currentTheme.mainText)
//			}.padding()
		}
	}
	
	func getEmojiList() -> [[Int]] {
		var emojis : [[Int]] = []
		for k in emojiRanges {
			for i in stride(from: k.0, to: k.1, by: 4) {
				var temp : [Int] = []
				for j in i...(i + 3) {
					temp.append(j)
				}
				emojis.append(temp)
			}
		}
		return emojis
	}
}
