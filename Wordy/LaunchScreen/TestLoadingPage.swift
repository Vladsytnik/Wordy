//
//  TestLoadingPage.swift
//  Wordy
//
//  Created by user on 08.03.2024.
//

import SwiftUI
import Pow

struct TestLoadingPage: View {
    
    private let launchScreenAnimationDuration: Double = 5
    @State var isShownLoadingPage = true
    @State var startLoadingAnimation = false
    
    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()
            
            if isShownLoadingPage {
                LoadingPage(duration: launchScreenAnimationDuration, start: $startLoadingAnimation)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + launchScreenAnimationDuration) {
//                withAnimation {
//                    isShownLoadingPage.toggle()
//                }
//            }
        }
    }
}


