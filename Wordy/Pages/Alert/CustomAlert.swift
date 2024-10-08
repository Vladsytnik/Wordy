//
//  Alert.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.01.2023.
//

import SwiftUI

struct CustomAlert: View {
	
	let title: String
	let description: String
	
	@Binding var isShow: Bool
	@State var scrollOffsetValue: CGFloat = 0
	
	let titleWithoutAction: String
	let titleForAction: String
	
	var withoutButtons = false
	
    var okAction: (() -> Void)?
	let repeatAction: () -> Void
	
	private let buttonsOffset: CGFloat = 30
	@EnvironmentObject var themeManager: ThemeManager
    
    @Environment(\.colorScheme) var colorScheme
	
//	@Environment(\.dismiss) var dismiss
	
	var body: some View {
//		GeometryReader { geo in
			ZStack {
				VStack {
					Spacer()
					VStack(spacing: 5) {
                        Text(title.localize())
							.multilineTextAlignment(.center)
							.foregroundColor(themeManager.currentTheme.mainText)
							.padding(EdgeInsets(top: 50, leading: 30, bottom: 0, trailing: 30))
							.font(.system(size: 28, weight: .bold))
                        Text(description.localize())
							.multilineTextAlignment(.center)
							.foregroundColor(themeManager.currentTheme.mainText)
							.font(.system(size: 20, weight: .regular))
							.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
						Rectangle()
							.frame(height: 40)
							.foregroundColor(.clear)
						Button {
                            if okAction == nil {
                                withAnimation {
                                    isShow = false
                                }
                            } else {
                                okAction?()
                            }
						} label: {
							RoundedRectangle(cornerRadius: 18)
								.foregroundColor(Color(asset: Asset.Colors.createModuleButton))
								.frame(width: 200, height: 55)
								.overlay {
                                    Text(titleWithoutAction.localize())
                                        .foregroundColor(.white)
										.font(.system(size: 16, weight: .medium))
								}
						}
						.offset(y: !withoutButtons ? buttonsOffset : -16)
//						.opacity(withoutButtons ? 0 : 1)
						if !withoutButtons {
							Button {
								withAnimation {
									isShow = false
								}
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
									repeatAction()
								}
							} label: {
								RoundedRectangle(cornerRadius: 18)
									.foregroundColor(.clear)
									.frame(width: 300, height: 55)
									.overlay {
                                        Text(titleForAction.localize())
											.foregroundColor(themeManager.currentTheme.mainText)
											.font(.system(size: 16, weight: .medium))
									}
							}
							.offset(y: buttonsOffset)
							.opacity(withoutButtons ? 0 : 1)
							.padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
						}
					}
//					.frame(width: geo.size.width)
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 0))
//					.background(themeManager.currentTheme.moduleCardRoundedAreaColor)
//                    .background(colorScheme == .light || !themeManager.currentTheme.isDark ? .white : Color(asset: Asset.Colors.poptipBgColor))
                    .background(themeManager.currentTheme.main)
					.cornerRadius(30, corners: [.topLeft, .topRight])
				}
//				.ignoresSafeArea()
			}
			.offset(y: 100 + scrollOffsetValue)
//			.frame(width: geo.size.width, height: geo.size.height)
			.gesture(
				DragGesture()
					.onEnded{ value in
						if value.translation.height > 0 {
                            withAnimation {
								isShow = false
							}
                        } else {
                            withAnimation(.spring(duration: 0.2, bounce: 0.5, blendDuration: 0.7)) {
                                scrollOffsetValue = 0
                            }
                        }
					}
                    .onChanged{
                        if $0.translation.height > 0 {
                            let yOffset = min(max($0.translation.height, 0), UIScreen.main.bounds.height) * 0.5
                            scrollOffsetValue = yOffset
                        } else {
                            scrollOffsetValue = $0.translation.height / 10
                        }
                    }
			)
//		}
	}
}

struct Alert_Previews: PreviewProvider {
    
    
    static var previews: some View {
		CustomAlert(
			title: "Wordy.app",
			description: "\nВы достигли лимита по количеству \nслов в одном модуле. \n\nМы не рекомендуем добавлять больше 15 фраз в один модуль. \n\nНо если вы все равно хотите снять все ограничения, то попробуйте \nподписку Wordy PRO \n(или создайте новый модуль, но мы вам об этом не говорили)",
			isShow: .constant(true),
			titleWithoutAction: "OK",
			titleForAction: "Попробовать снова"
		) {  }
            .environmentObject(ThemeManager())
    }
}
