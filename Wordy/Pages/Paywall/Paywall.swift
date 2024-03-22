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
    @EnvironmentObject var subscriptionManager: SubscriptionManager
	@Binding var isOpened: Bool
	@State var isOnAppear = false
	
	@State var isPurchasing = false
    
    @State var alertTitle = "Wordy.app"
    @State var alertMessage = ""
    @State var isCongratsAlertShown = false
    
    @State var isFirstOpen = false
	
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
							Text("Попробуйте подписку Wordy Pro".localize())
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
                                        isMostPopular: i == viewModel.popularIndex,
										price: viewModel.getPriceTitleFor(index: i),
										descriptionTxt: viewModel.products[i].description
									) {
										viewModel.didTapBtn(index: i)
                                        didTapBuy()
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
                            AnalyticsManager.shared.trackEvent(.didTapOnPaywallBuyBtn)
                            didTapBuy()
						} label: {
							RoundedRectangle(cornerRadius: 28)
								.frame(height: 56)
//								.foregroundColor(isNothingSelected ? .blue.opacity(0.6) : .blue)
								.foregroundColor(isNothingSelected ? themeManager.currentTheme.paywallBtnsColor.opacity(0.6) : themeManager.currentTheme.paywallBtnsColor)
								.overlay {
									Text("Попробуйте бесплатно и подпишитесь".localize())
                                        .foregroundColor(isNothingSelected ? themeManager.currentTheme.mainText.opacity(0.6) : themeManager.currentTheme.mainText)
										.font(.system(size: 18, weight: .bold))
								}
						}
						.disabled(isNothingSelected)
						.shadow(color: .white.opacity(0.3), radius: isNothingSelected ? 0 : 12)
						.padding()
						.animation(.spring(), value: isNothingSelected)
                        
                        Button(action: {
                            AnalyticsManager.shared.trackEvent(.didTapOnPaywallRestoreBtn)
                            restorePurchase()
                        }, label: {
                            Text("Возобновить покупку".localize())
                                .foregroundColor(themeManager.currentTheme.mainText.opacity(0.8))
                                .underline()
                        })
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                        .font(.system(size: 12))
						
						Rectangle()
							.foregroundColor(.clear)
							.frame(minHeight: geo.size.height > 812 ? geo.size.height * 0.15 : 0)
						
						HStack {
							Button {
                                UIApplication.shared.open(URL(string: .GlobalValues.URLS.privacy)!)
							} label: {
								Text("PRIVACY POLICY".localize())
							}
							Spacer()
							Button {
                                UIApplication.shared.open(URL(string: .GlobalValues.URLS.termsOfUse)!)
							} label: {
								Text("TERMS & CONDITIONS".localize())
							}
						}
						.font(.system(size: 12))
						.foregroundColor(themeManager.currentTheme.mainText.opacity(0.8))
						.padding()
						.offset(y: -16)
                        
                        Text("Ваша подписка автоматически продлевается на прежних условиях, если вы не отмените её минимум за 24 часа до окончания текущего периода. Вы можете в любой момент и без дополнительной оплаты отменить подписку в App Store, и она завершится в конце текущего периода.".localize())
                            .font(.system(size: 11))
                            .foregroundColor(themeManager.currentTheme.mainText.opacity(0.5))
                            .padding()
                            .multilineTextAlignment(.center)
					}
				}
			}
		}
        .onAppear {
            isOnAppear = true
            if isFirstOpen {
                isFirstOpen = false
                AnalyticsManager.shared.trackEvent(.sawPaywall)
            }
        }
        .activity($viewModel.isInProgress)
//        .alert(isPresented: $isCongratsAlertShown) {
//            let btnText = "Got it!".localize()
//            return Alert(
//                title: Text(alertTitle),
//                message: Text(alertMessage),
//                dismissButton: .default(Text(btnText), action: {
//                    closePaywall()
//                })
//            )
//        }
        .alert(isPresented: $viewModel.showAlert) {
            let btnText = "ОК".localize()
            return Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertText),
                dismissButton: .default(Text(btnText), action: {
                    if viewModel.isNeedToClosePaywall {
                        closePaywall()
                    }
                })
            )
        }
    }
    
    private func didTapBuy() {
        if let subscrObject = viewModel.getSubscriptionPeriodFor(index: viewModel.selectedIndex) {
            switch subscrObject {
            case .OneMonth:
                AnalyticsManager.shared.trackEvent(.didTapOnOneMonthPeriodBtn)
            case .OneYear:
                AnalyticsManager.shared.trackEvent(.didTapOnOneYearPeriodBtn)
            }
        }
        
        if viewModel.selectedIndex < viewModel.products.count {
            viewModel.isInProgress = true
            Task { @MainActor in
                let result = await Apphud.purchase(viewModel.getSelectedProduct(), isPurchasing: $isPurchasing)
                print("Subscr print: ", result)
                if result.success {
                    AnalyticsManager.shared.trackEvent(.subscriptionBuyProcessFinishedWithSuccess)
                    print("Subscr print: success")
                    subscriptionManager.updateDate()
                    subscriptionManager.isUserHasSubscription = true
                    viewModel.isNeedToClosePaywall = true
                    showCongratsAlert()
                } else {
                    AnalyticsManager.shared.trackEvent(.subscriptionBuyProcessFinishedWithError)
                    print("Subscr print: not success")
                }
                viewModel.isInProgress = false
            }
        }
    }
    
    func restorePurchase() {
        viewModel.isInProgress = true
        Task { @MainActor in
            let error = await Apphud.restorePurchases()
            if let error  {
                viewModel.showErrorRestore()
                print("Apphud error: restorePurchase: \(error)")
            } else if !subscriptionManager.isUserHasSubscription {
                viewModel.showErrorRestore()
            } else {
                viewModel.showSuccessRestore()
            }
            viewModel.isInProgress = false
        }
    }
    
    private func showCongratsAlert() {
//        viewModel.alertTitle = "Поздравляем, оплата прошла успешно!".localize() + "\n"
//        viewModel.alertText = "Спасибо, что поддерживаете нас! <3".localize() + "\n\n" + "Теперь вам доступны все возможности приложения без ограничений!".localize()
//        viewModel.showAlert.toggle()
        closePaywall()
    }
    
    private func closePaywall() {
        isOpened = false
    }
}

struct Paywall_Previews: PreviewProvider {
    static var previews: some View {
		Paywall(isOpened: .constant(true))
            .environmentObject(SubscriptionManager.shared)
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
						Text("популярное".localize())
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

