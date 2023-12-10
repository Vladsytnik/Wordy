//
//  EmptyView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 27.09.2023.
//

import SwiftUI

struct EmptyBGView: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	
    var body: some View {
		ZStack {
			VStack {
				Spacer()
				VStack(spacing: 16) {
					Spacer()
					Text("👀")
						.font(.system(size: 48))
                    Text("There is nothing\nhere yet...".localize())
						.multilineTextAlignment(.center)
						.font(.system(size: 20, weight: .medium))
						.opacity(0.72)
						.foregroundColor(themeManager.currentTheme.mainText)
					Spacer()
				}
				.offset(y: -15)
				Spacer()
			}
		}
		.ignoresSafeArea()
    }
}

struct EmptyBGView_Previews: PreviewProvider {
    static var previews: some View {
		EmptyBGView()
			.environmentObject(ThemeManager())
    }
}
