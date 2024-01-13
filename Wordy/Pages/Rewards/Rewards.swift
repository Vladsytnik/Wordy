//
//  Rewards.swift
//  Wordy
//
//  Created by user on 08.01.2024.
//

import SwiftUI
import CoreHaptics
import AVFAudio

struct Rewards: View {
    
    @EnvironmentObject var rewardManager: RewardManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        switch rewardManager.rewardType {
        case .firstModule:
            firstModuleReward()
        }
    }
    
    @ViewBuilder
    func firstModuleReward() -> some View {
        FirstModuleReward()
    }
}

struct RewardCardSpacerKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        if nextValue().height > value.height {
            value = nextValue()
        }
    }
}

struct FirstModuleReward: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @State var spacerSize: CGSize = .zero
    
    @State private var needAnimate = false
    @State private var needAnimatableRotate = false
    
    @State var tapticUrl: URL?
    
    @State var hapticEngine: CHHapticEngine?
    
    @State var anim1 = false
    @State var anim2 = false
    @State var anim3 = false
    
    @State var isLight = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var levitationValue = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                Spacer()
                
                VStack {
                    Spacer()
                    
                    Text("Поздравляем!".localize())
                        .font(.title)
                        .bold()
                        .padding()
                        .padding(.horizontal)
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(themeManager.currentTheme.main)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(needAnimate ? 1 : 0)
                        .offset(y: needAnimate ? 0 : 10)
                        .animation(.spring().delay(0.2), value: needAnimate)
                    
                    Spacer()
                        .background {
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: RewardCardSpacerKey.self, value: geo.size)
                            }
                        }
                    
                    VStack(spacing: 16) {
                        Text("Ты только что создал свой первый модуль, так держать!".localize())
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(needAnimate ? 1 : 0)
                            .offset(y: needAnimate ? 0 : 10)
                            .animation(.spring().delay(0.5), value: needAnimate)
                        Text("В честь этого хотим вручить тебе первую награду, ты это заслужил!".localize())
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(needAnimate ? 1 : 0)
                            .offset(y: needAnimate ? 0 : 10)
                            .animation(.spring().delay(0.8), value: needAnimate)
                    }
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(themeManager.currentTheme.mainText)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.horizontal)
                    .overlay {
                        if anim2 {
                            LottieView(fileName: "onboarding", isLooped: false)
                                .offset(x: -70, y: 0)
                                .scaleEffect(1.7)
                        }
                        if anim3 {
                            LottieView(fileName: "onboarding", isLooped: false)
                                .offset(x: 70, y: 0)
                                .scaleEffect(1.7)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: RewardCardSpacerKey.self, value: geo.size)
                        }
                    }
                
                RewardCard()
                    .padding()
                    .padding(.horizontal)
                    .offset(y: -spacerSize.height * 0.5)
                    .opacity(!needAnimate ? 0 : 1)
                    .rotation3DEffect(
                        Angle(degrees: needAnimate ? 0 : 5),
                        axis: (x: 0.5, y: 0.0, z: 0.0)
                    )
                    .offset(y: needAnimate ? 0 : 150)
                    .animation(.interpolatingSpring(stiffness: 170, damping: 8)
                        .delay(0.3), value: needAnimate)
//                    .animation(.interpolatingSpring(stiffness: 170, damping: 8),
//                               value: needAnimatableRotate)
                    .overlay {
                        if anim1 {
                            LottieView(fileName: "onboarding", isLooped: false)
                                .scaleEffect(1.7)
                        }
                    }
                    .background {
                        if isLight {
                            LottieView(fileName: "reward")
                                .scaleEffect(2)
                                .opacity((!themeManager.currentTheme.isDark || colorScheme == .light) ? 1 : 0.1)
                        }
                    }
                    .offset(y: levitationValue ? 4 : -4)
                    .animation(.default.speed(0.2).repeatForever().delay(1.7), value: levitationValue)
                
               
                Spacer()
            }
        }
        .onPreferenceChange(RewardCardSpacerKey.self, perform: { value in
            spacerSize = value
            print("test pr: \(value)")
        })
        .onAppear{
            withAnimation(.spring()) {
                needAnimate = true
            }
            levitationValue.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                anim1.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                anim2.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                anim3.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isLight.toggle()
                }
            }
            
            do {
                hapticEngine = try CHHapticEngine()
                
                guard let path = Bundle.main.path(forResource: "haptic", ofType : "ahap") 
                else { return }
                        
                try hapticEngine?.start()
                try hapticEngine?.playPattern(from: URL(fileURLWithPath: path))
            } catch(let error) {
                print("haptic error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - RewardCard

struct RewardCardPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .init(width: 200, height: 300)
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct RewardCard: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var needAnimate = false
    
    let cornerMult = 0.09
    @State var cardSize: CGSize = .zero
    
    let contentOffset: CGFloat = 12
    
    var body: some View {
        VStack(spacing: 33) {
            Image(asset: Asset.Images.rewardFirstModule)
                .offset(y: contentOffset)
                .fixedSize(horizontal: false, vertical: false)
            
            VStack(spacing: 9) {
                Text("Награда".localize())
                    .font(.system(size: 28, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(themeManager.currentTheme.mainText)
                    .shadow(color: .white.opacity(0.4), radius: 20, x: 10.0, y: 0.0)
                    .shadow(color: .white.opacity(0.4), radius: 20, x: -10.0, y: 0.0)
                Text("- Исследователь -".localize())
                    .font(.system(size: 14, weight: .medium))
                    .opacity(0.8)
                    .foregroundColor(themeManager.currentTheme.mainText)
//                    .fixedSize(horizontal: false, vertical: true)
            }
            .offset(y: contentOffset)
        }
        .padding()
        .padding()
        .padding()
        .padding(.horizontal)
        .background {
            GeometryReader { geo in
                Color.clear
                    .preference(key: RewardCardPreferenceKey.self, value: geo.size)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: cardSize.height * cornerMult)
                .foregroundColor(themeManager.currentTheme.main)
                .overlay {
                    ZStack {
//                        if themeManager.currentTheme.isDark && colorScheme != .light {
                            themeManager.currentTheme.moduleScreenBtnsColor
                                .cornerRadius(cardSize.height * cornerMult, corners: .allCorners)
//                        } else {
//                            BackgroundView()
//                                .cornerRadius(cardSize.height * cornerMult, corners: .allCorners)
//                        }
                        
//                        Image(asset: Asset.Images.paper)
//                            .resizable()
//                            .frame(width: cardSize.width, height: cardSize.height)
//                            .cornerRadius(cardSize.height * cornerMult, corners: .allCorners)
                    }
//                    .blendMode(.softLight)
                }
                .shadow(color: .black.opacity(0.13),
                        radius: 30, x: 0, y: 0)
        }
        .overlay {
            VStack {
                HStack {
                    Image(asset: Asset.Images.rewardConfetti)
                        .rotationEffect(.degrees(-45))
                        .offset(x: 16, y: 16)
                    Spacer()
                    Image(asset: Asset.Images.rewardConfetti)
                        .rotationEffect(.degrees(45))
                        .offset(x: -16, y: 16)
                }
                Spacer()
            }
        }
        .onPreferenceChange(RewardCardPreferenceKey.self, perform: { value in
            cardSize = value
        })
        .onAppear {
            withAnimation(.spring()) {
                needAnimate = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Rewards()
        .environmentObject(RewardManager())
        .environmentObject(ThemeManager(1))
}
