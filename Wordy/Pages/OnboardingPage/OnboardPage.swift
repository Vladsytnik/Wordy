//
//  OnboardPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.05.2023.
//

import SwiftUI

struct OnboardingPage: View {
    var body: some View {
		ZStack {
			Color(asset: Asset.Colors.navBarPurple)
				.ignoresSafeArea()
		}
		.navigationBarHidden(true)
    }
}

struct OnboardingPage_Previews: PreviewProvider {
    static var previews: some View {
		OnboardingPage()
    }
}
