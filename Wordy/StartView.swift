//
//  StartView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI
import ApphudSDK
import Combine
import Pow

struct StartView: View {
    
    private let launchScreenAnimationDuration: Double = 1.5
	
	@EnvironmentObject var deeplinkManager: DeeplinkManager
    @EnvironmentObject var themeManager: ThemeManager
	@EnvironmentObject var router: Router
    @EnvironmentObject var rewardManager: RewardManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appVersionManager: AppVersionsManager
    
//	let authTransition = AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity)
	let authTransition = AnyTransition.opacity
	let transition = AnyTransition.opacity
	let opacityTransition = AnyTransition.opacity
    
    @Binding var isShownLoadingPage: Bool
    
    @State private var cancelable = Set<AnyCancellable>()
    
    @State var testOPen = false
    
    func test() {
        
    }
	
	var body: some View {
			ZStack {
				if router.userIsLoggedIn {
					if router.userIsAlreadyLaunched {
                        
                        //MARK: – Main Flow
						NavigationView {
                                NewModulesScreen()
                                .sheet(isPresented: $rewardManager.showReward, content: {
                                    Rewards()
                                })
                                .task {
                                    AnalyticsManager.shared.trackEvent(.openedModulesScreen)
                                    do {
                                        let expireSubscriptionDateFromServer = try await NetworkManager.getSubscriptionExpireDateFromServer()
                                        UserDefaultsManager.serverSubscrExpireDate = expireSubscriptionDateFromServer
                                        print("expire date from server: \(expireSubscriptionDateFromServer)")
                                    } catch (let error) {
                                        print("error in StartView -> .task -> try await NetworkManager.getSubscriptionExpireDateFromServer(): \(error.localizedDescription)")
                                    }
                                }
						}
						.transition(transition)
                        .accentColor(themeManager.currentTheme.mainText)
                        .onAppear {
                            if let userId = UserDefaultsManager.userID  {
                                Apphud.start(apiKey: "app_6t9G2dfKPDzUt3jifCJdTPMLbaKCPr", userID: userId)
                            }
//                            NetworkManager.updateSubscriptionInfo()
                            
//                            if !isShownLoadingPage {
//                                appVersionManager.startChecking()
//                            }
                        }
                        .navigationViewStyle(.stack)
                        
					} else {
						SelectLanguagePage()
							.transition(opacityTransition)
					}
                    
				} else {
                    //MARK: – Auth Flow
					AuthPage()
						.transition(authTransition)
				}
                
				if router.showActivityView {
					VStack {
						Spacer()
						LottieView(fileName: "loader")
							.frame(width: 200, height: 200)
						Spacer()
					}
					.ignoresSafeArea()
				}
                
                if testOPen {
                    LiquidOnboardingView(
                        intros: $appVersionManager.intros,
                        firstIntro: $appVersionManager.firstIntroForTransition,
                        isOpened: $testOPen
                    )
                    .transition(
                        .asymmetric(insertion: .move(edge: .bottom),
                                    removal: .move(edge: .bottom).combined(with: .opacity))
                    )
                    .zIndex(100)
                }
            }
            .animation(.bouncy, value: testOPen)
            .overlay(content: {
                if isShownLoadingPage {
                    LoadingPage(duration: launchScreenAnimationDuration,
                                start: $dataManager.startLoadingAnimation) {
                        isShownLoadingPage.toggle()
                    }
                                .ignoresSafeArea()
                }
            })
            .accentColor(.white)
            .onAppear {
                if (dataManager.isInitialized && !dataManager.isLoading)
                    || UserDefaultsManager.userID == nil
                    || !UserDefaultsManager.isMainScreenPopupsShown {
                    print("loading page test: все условия совпали и надо запускать анимацию")
                    dataManager.startLoadingAnimation = true
                }
            }
            .onChange(of: isShownLoadingPage, perform: { value in
                if !value {
                    appVersionManager.onOpenPage = { self.testOPen = true }
                    appVersionManager.startChecking()
                }
            })
    }
    
    private func initNotifications() {

    }
}



struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(isShownLoadingPage: .constant(true))
			.environmentObject(Router())
            .environmentObject(DataManager.shared)
            .environmentObject(DeeplinkManager())
            .environmentObject(RewardManager())
            .environmentObject(ThemeManager())
            .environmentObject(AppVersionsManager.shared)
    }
}
