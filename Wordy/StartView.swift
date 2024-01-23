//
//  StartView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI
import ApphudSDK
import Combine

struct StartView: View {
	
	@EnvironmentObject var deeplinkManager: DeeplinkManager
    @EnvironmentObject var themeManager: ThemeManager
	@EnvironmentObject var router: Router
    @EnvironmentObject var rewardManager: RewardManager
//	let authTransition = AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity)
	let authTransition = AnyTransition.opacity
	let transition = AnyTransition.opacity
	let opacityTransition = AnyTransition.opacity
    
//    @StateObject var viewModel = StartViewModel()
    
    @State private var cancelable = Set<AnyCancellable>()
    
    func test() {
        
    }
	
	var body: some View {
			ZStack {
				if router.userIsLoggedIn {
					if router.userIsAlreadyLaunched {
                        
                        //MARK: – Main Flow
						NavigationView {
//                            if #available(iOS 15.0, *) {
                                NewModulesScreen()
                                .sheet(isPresented: $rewardManager.showReward, content: {
                                    Rewards()
                                })
//                                .overlay {
//                                    EmptyView()
//                                        .showAlert(title: "Wordy.app", description: viewModel.alertText, isPresented: $viewModel.showAlert, withoutButtons: true, repeatAction: {})
//                                }
//                            } else {
//                                Modules()
//                            }
						}
						.transition(transition)
                        .accentColor(themeManager.currentTheme.mainText)
                        .onAppear {
                            if let userId = UserDefaultsManager.userID  {
                                Apphud.start(apiKey: "app_6t9G2dfKPDzUt3jifCJdTPMLbaKCPr", userID: userId)
                            }
//                            NetworkManager.updateSubscriptionInfo()
                        }
                        
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
			}
		.environmentObject(router)
		.accentColor(.white)
        .task {
            do {
                let expireSubscriptionDateFromServer = try await NetworkManager.getSubscriptionExpireDateFromServer()
                UserDefaultsManager.serverSubscrExpireDate = expireSubscriptionDateFromServer
//                UserDefaultsManager.userHasTestSubscription = SubscriptionManager().userHasServerSubscription()
                print("expire date from server: \(expireSubscriptionDateFromServer)")
            } catch (let error) {
                print("error in StartView -> .task -> try await NetworkManager.getSubscriptionExpireDateFromServer(): \(error.localizedDescription)")
            }
//            UserDefaultsManager.userHasTestSubscription =
        }
//        .onChange(of: viewModel.showAlert) { _ in
//            print("Test init view model - changed")
//        }
	}
    
    private func initNotifications() {
//        NotificationCenter.default.publisher(for: NSNotification.Name("reward"), object: nil)
//            .sink { notif in
//                if let rewardType = notif.object as? RewardType {
//                    notificationObserver.showReward(ofType: rewardType)
//                }
//            }
//            .store(in: &cancelable)
    }
}



struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
			.environmentObject(Router())
    }
}
