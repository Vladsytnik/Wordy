//
//  Animations.swift
//  Wordy
//
//  Created by user on 24.03.2024.
//

import SwiftUI

struct ShakeAnimation: AnimatableModifier {
    @Binding var isAnimatable: Bool
    
    let times: CGFloat = 1
    let amplitude: CGFloat = 2

    func body(content: Content) -> some View {
        content
            .rotationEffect(isAnimatable ? Angle(degrees: Double(amplitude) * sin(Double(times) * .pi * 2)) : .degrees(0))
    }
}

extension View {
    func shake(isAnimatable: Binding<Bool>) -> some View {
        self.modifier(ShakeAnimation(isAnimatable: isAnimatable))
    }
}

class Animations {
    static let customSheet: Animation = .spring(duration: 0.3, bounce: 0.3, blendDuration: 0.9)
}
