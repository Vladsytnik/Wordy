//
//  StartView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI

struct StartView: View {
	
	@StateObject var router = Router()
	
	var body: some View {
		NavigationView {
			ZStack {
				if router.userIsLoggedIn {
					Modules()
				} else {
					AuthPage()
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
			.transition(.slide)
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
