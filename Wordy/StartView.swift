//
//  StartView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI
import ApphudSDK

struct StartView: View {
	
	@EnvironmentObject var deeplinkManager: DeeplinkManager
    @EnvironmentObject var themeManager: ThemeManager
	@EnvironmentObject var router: Router
//	let authTransition = AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity)
	let authTransition = AnyTransition.opacity
	let transition = AnyTransition.opacity
	let opacityTransition = AnyTransition.opacity
	
	var body: some View {
			ZStack {
				if router.userIsLoggedIn {
					if router.userIsAlreadyLaunched {
                        
                        //MARK: – Main Flow
						NavigationView {
//                            if #available(iOS 15.0, *) {
                                NewModulesScreen()
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
	}
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
			.environmentObject(Router())
    }
}
