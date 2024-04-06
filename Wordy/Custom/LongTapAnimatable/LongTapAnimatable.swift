//
//  LongTapAnimatable.swift
//  Wordy
//
//  Created by user on 23.03.2024.
//

import SwiftUI

extension View {
    func longTapAnimatableModifier(onTap: @escaping () -> Void, onLongTap: @escaping () -> Void) -> some View {
        ModifiedContent(content: self, modifier: LongTapAnimatableModifier(onTap: onTap, onLongTap: onLongTap))
    }
}

final class CADisplayLinkManager {
    
    private var animationTimer: CADisplayLink? = nil
    
    private var startTime: CFTimeInterval?
    private var endTime: CFTimeInterval?
    
    var onTick: (() -> Void)?
    
    func initialize(withDuration animationDuration: Double) {
        
        startTime = CACurrentMediaTime()
        endTime = startTime! + animationDuration

        
        animationTimer = CADisplayLink(target: self, selector: #selector(timerTick))
        animationTimer?.add(to: .main, forMode: .common)
    }
    
    @objc private func timerTick() {
        guard let endTime = endTime else {
            return
        }
        
        let now = CACurrentMediaTime()
        
        if now >= endTime {
            animationTimer?.isPaused = true
            animationTimer?.invalidate()
            animationTimer = nil
        }
        
        onTick?()
        print("animationTimer tick")
    }
    
    func stop() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

struct LongTapAnimatableModifier: ViewModifier {
    

    @State private var scaleEffect: CGFloat = 1
    @State private var opacity: Double = 1
    
    var onTap: (() -> Void)
    var onLongTap: (() -> Void)
    
    @State var animationTimer: CADisplayLink? = nil
    
    let timerManager = CADisplayLinkManager()
    let longTapDuration = 0.6
    let scaleCoefficient = 0.0015
    let opacityCoefficient = 0.015
    
    func body(content: Content) -> some View {
        content
//            .simultaneousGesture(LongPressGesture().onChanged { _ in
//                print(">> long press")
//            })
//            .simultaneousGesture(LongPressGesture().onEnded { _ in
//                print(">> long press ended")
//            })
            .onTapGesture {
//                withAnimation() {
//                    scaleEffect = 0.9
//                }
//                withAnimation(.default.delay(0.1)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    scaleEffect = 1
                    opacity = 1
                }
//                }
                onTap()
            }
            .onLongPressGesture(minimumDuration: longTapDuration) {
                print("onLongPressGesture")
                onLongTap()
            } onPressingChanged: { isChanged in
                if isChanged {
                    // Start Long Tap Or Just Tap
                    startLongTapAnimation()
                    print("onLongPressGesture isChanged = true")
                } else {
                    // Finish Long Tap Or Just Tap
                    stopLongTapAnimation()
                    withAnimation(.interpolatingSpring(duration: 0.2, bounce: 0.4, initialVelocity: 0.8)) {
                        opacity = 1
                        scaleEffect = 1
                    }
                    print("onLongPressGesture isChanged = false")
                }
            }
            .scaleEffect(scaleEffect)
//            .opacity(opacity)
    }
    
    func startLongTapAnimation() {
        timerManager.initialize(withDuration: longTapDuration)
        timerManager.onTick = {
            scaleEffect -= scaleCoefficient
            opacity -= opacityCoefficient
        }
    }
    
    func stopLongTapAnimation() {
        timerManager.stop()
    }
}
