//
//  Paywall.swift
//  Wordy
//
//  Created by Vlad Sytnik on 21.06.2023.
//

import SwiftUI
import ApphudSDK

struct Paywall: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	@ObservedObject var viewModel = PaywallViewModel()
	@Binding var isOpened: Bool
	@State var isOnAppear = false
	
	@State var isInProgress = false
	@State var isPurchasing = false
	
	var isNothingSelected: Bool {
		viewModel.selectedIndex == nil
	}
	
	/*
	 1. Разблокируйте свой творческий потенциал: бесконечное количество модулей и фраз
	 2. Погружайтесь в мир обучения без ограничений: неограниченный доступ к обучающему режиму
	 3. Личность и стиль: стилизация интерфейса на свой вкус
	 4. Настраивайте время и частоту уведомлений: (описание пока не придумал)
	 */
	
//	let advantagesText = [
//		"Разблокируйте свой творческий потенциал: бесконечное количество модулей и фраз",
//		"Погружайтесь в мир обучения без ограничений: неограниченный доступ к обучающему режиму",
//		"Личность и стиль: стилизация интерфейса на свой вкус",
//		"Настраивайте время и частоту уведомлений: (описание пока не придумал)"
//	]
    
    @Environment(\.colorScheme) var colorScheme
	
    var body: some View {
		ZStack {
            if themeManager.currentTheme.isDark {
                if colorScheme == .dark {
                    themeManager.currentTheme.darkMain
                        .ignoresSafeArea()
                } else if themeManager.currentTheme.id == "MainColor" {
                    themeManager.currentTheme.mainBackgroundImage
                        .resizable()
                        .ignoresSafeArea()
                }
            } else {
                themeManager.currentTheme.mainBackgroundImage
                    .resizable()
                    .ignoresSafeArea()
            }
				
			GeometryReader { geo in
				ScrollView {
					VStack {
						HStack(alignment: .top) {
							Text("Try Wordy Pro Subscription".localize())
								.foregroundColor(themeManager.currentTheme.mainText)
								.font(.system(size: 32, weight: .bold))
								.padding()
							Spacer()
							CloseBtn(isOpened: $isOpened)
						}
						.padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
						
						ForEach(Array(zip(viewModel.attributedAdvantages.indices, viewModel.attributedAdvantages)), id: \.0) { i, text in
							HStack(alignment: .top, spacing: 16) {
                                if themeManager.currentTheme.isDark {
                                    Image(asset: Asset.Images.advantage)
                                        .padding(EdgeInsets(top: 0, leading: 16, bottom: text == viewModel.attributedAdvantages.last ? 80 : 20, trailing: 8))
                                } else {
                                    Image(asset: Asset.Images.advantage)
                                        .renderingMode(.original)
                                        .colorMultiply(themeManager.currentTheme.accent)
                                        .padding(EdgeInsets(top: 0, leading: 16, bottom: text == viewModel.attributedAdvantages.last ? 80 : 20, trailing: 8))
                                }
								Text(text) // локализовано во viewModel
									.foregroundColor(themeManager.currentTheme.mainText)
								Spacer()
							}
							.padding(EdgeInsets(top: text == viewModel.attributedAdvantages.first ? 16 : 0, leading: 0, bottom: 0, trailing: 0))
							.opacity(isOnAppear ? 1 : 0)
							.animation(.spring().delay(Double(i) * 0.1), value: isOnAppear)
						}
						
						if viewModel.products.count > 0 {
							ForEach(0..<viewModel.products.count, id: \.self) { i in
								VStack {
									PaywallPlanBtn(
										isSelected: viewModel.selectedIndex == i,
										isMostPopular: i == 1,
										price: viewModel.getPriceTitleFor(index: i),
										descriptionTxt: viewModel.products[i].description
									) {
										viewModel.didTapBtn(index: i)
									}
								}
							}
						} else {
							RoundedRectangle(cornerRadius: 12)
								.frame(height: 75)
								.foregroundColor(themeManager.currentTheme.main)
								.overlay {
									ProgressView()
								}
								.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
							RoundedRectangle(cornerRadius: 12)
								.frame(height: 75)
								.foregroundColor(themeManager.currentTheme.main)
								.overlay {
									ProgressView()
								}
								.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
						}
						
						Spacer()
							.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
						
						Button {
							if viewModel.selectedIndex < viewModel.products.count {
								isInProgress = true
								Task { @MainActor in
									// productStruct is Product struct model from StoreKit2
									// $isPurchasing should be used only in SwiftUI apps, otherwise don't use this parameter
									let result = await Apphud.purchase(viewModel.getSelectedProduct(),
																	   isPurchasing: $isPurchasing)
									isInProgress = false
									print("Subscr print: ", result)
									if result.success {
										// handle successful purchase
										print("Subscr print: success")
										isOpened = false
									} else {
										print("Subscr print: not success")
									}
								}
							}
						} label: {
							RoundedRectangle(cornerRadius: 28)
								.frame(height: 56)
//								.foregroundColor(isNothingSelected ? .blue.opacity(0.6) : .blue)
								.foregroundColor(isNothingSelected ? themeManager.currentTheme.paywallBtnsColor.opacity(0.6) : themeManager.currentTheme.paywallBtnsColor)
								.overlay {
									Text("Try Free and subscribe".localize())
                                        .foregroundColor(isNothingSelected ? themeManager.currentTheme.mainText.opacity(0.6) : themeManager.currentTheme.mainText)
										.font(.system(size: 18, weight: .bold))
								}
						}
						.disabled(isNothingSelected)
						.shadow(color: .white.opacity(0.3), radius: isNothingSelected ? 0 : 12)
						.padding()
						.animation(.spring(), value: isNothingSelected)
						
						Rectangle()
							.foregroundColor(.clear)
							.frame(minHeight: geo.size.height > 812 ? geo.size.height * 0.15 : 0)
						
						HStack {
							Button {
								
							} label: {
								Text("PRIVACY POLICY".localize())
							}
							Spacer()
							Button {
								
							} label: {
								Text("TERMS & CONDITIONS".localize())
							}
						}
						.font(.system(size: 14))
						.foregroundColor(themeManager.currentTheme.mainText.opacity(0.8))
						.padding()
						.offset(y: -16)
					}
				}
			}
		}
		.onAppear { isOnAppear = true }
		.activity($isInProgress)
    }
}

struct Paywall_Previews: PreviewProvider {
    static var previews: some View {
		Paywall(isOpened: .constant(true))
    }
}

struct CloseBtn: View {
	
	@Binding var isOpened: Bool
    @EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		Button {
			isOpened.toggle()
		} label: {
            if themeManager.currentTheme.isDark {
                Image(asset: Asset.Images.closeBtn)
            } else {
                Image(asset: Asset.Images.closeBtn)
                    .renderingMode(.original)
                    .colorMultiply(themeManager.currentTheme.mainText)
            }
		}
		.scaleEffect(1.3)
		.padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 24))
		.opacity(0.8)
	}
}

struct PaywallPlanBtn: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	var isSelected = false
	let isMostPopular: Bool
	
	let price: String
	let descriptionTxt: String
	
	var onTap: (() -> Void)?
	
	var body: some View {
		ZStack {
			HStack {
				VStack(alignment: .leading, spacing: 8) {
					Text(price)
						.font(.system(size: 20, weight: .bold))
					Text(descriptionTxt)
						.font(.system(size: 14))
				}
				Spacer()
			}
			
			if isMostPopular {
				VStack {
					HStack {
						Spacer()
						Text("most popular".localize())
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(themeManager.currentTheme.mainText)
							.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
							.background {
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(themeManager.currentTheme.paywallBtnsColor)
						}
					}
					.offset(y: -28)
					Spacer()
				}
			}
		}
        .foregroundColor(isSelected ? themeManager.currentTheme.mainText : .black)
		.background {
			RoundedRectangle(cornerRadius: 8)
				.foregroundColor(isSelected ? themeManager.currentTheme.paywallBtnsColor : .white)
				.padding(EdgeInsets(top: -16, leading: -16, bottom: -16, trailing: -16))
		}
		.padding(EdgeInsets(top: 8, leading: 32, bottom: 32, trailing: 32))
		.onTapGesture {
			onTap?()
		}
		.animation(.spring(), value: isSelected)
	}
}

