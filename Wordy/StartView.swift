//
//  StartView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI

struct StartView: View {
	
	@EnvironmentObject var router: Router
	let authTransition = AnyTransition.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)).combined(with: .opacity)
	let transition = AnyTransition.move(edge: .bottom)
	
	var body: some View {
		NavigationView {
			ZStack {
				if router.userIsLoggedIn {
					Modules()
						.transition(transition)
				} else {
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
//			.transition(.slide)
		}
		.environmentObject(router)
	}
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
			.environmentObject(Router())
    }
}