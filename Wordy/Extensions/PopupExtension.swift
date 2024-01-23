//
//  PopupExtension.swift
//  Wordy
//
//  Created by user on 20.01.2024.
//

import SwiftUI

struct PopupPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: HighlightView] = [:]
    
    static func reduce(value: inout [Int: HighlightView], nextValue: () -> [Int: HighlightView]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

enum PopupDirection {
    case top, bottom
}

extension View {
    func showPopup(order: Int, title: String) -> some View {
        self
        .anchorPreference(key: PopupPreferenceKey.self, value: .bounds, transform: { anchor in
            let highlightView = HighlightView(anchor: anchor, text: title)
            return [order: highlightView]
        })
    }
    
    func popup(
        allowToShow: Binding<Bool>,
        currentIndex: Binding<Int>? = nil,
        onFinish: (() -> Void)? = nil
    ) -> some View {
        self.modifier(PopupModifier(allowToShow: allowToShow,
                                    currentInd: currentIndex ?? .constant(0),
                                    onFinish: onFinish))
    }
}

struct PopupModifier: ViewModifier {
    
    @Binding var allowToShow: Bool
    @Binding var currentInd: Int
    var onFinish: (() -> Void)?
    
    let horizontalOffset: CGFloat = 30
    let verticalOffset: CGFloat = 30
    
    let blurMult: CGFloat = 0.2
    let cornerRadiusMult: CGFloat = 0.1
    
    let direction: PopupDirection = .top
    let title = "Нажмите, чтобы поделиться с нами вашей проблемой"
    
    let titleHBgShadow: CGFloat = 30
    let titleVBgShadow: CGFloat = 10
    
    let titleOffset: CGFloat = 24
    
    @State private var order: [Int] = []
    @State private var currentIndex = 0
    @State private var isShownPopup = true
    
    @State private var IsAppeared = false
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(PopupPreferenceKey.self, perform: { value in
                order = Array(value.keys.sorted())
            })
            .overlayPreferenceValue(PopupPreferenceKey.self, { preferences in
                if order.indices.contains(currentIndex) {
                    if let highlight = preferences[order[currentIndex]], isShownPopup, allowToShow {
                        PopupV(highlight)
                    }
                }
            })
            .animation(.spring(), value: allowToShow)
    }
    
    @ViewBuilder
    private func PopupV(_ highlightView: HighlightView) -> some View {
        ZStack {
            if isDark() {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
            } else {
                Color.white.opacity(0.7)
                    .ignoresSafeArea()
            }
            
            
            GeometryReader { geo in
                let highlightRect = geo[highlightView.anchor]
                RoundedRectangle(cornerRadius: highlightRect.height * cornerRadiusMult)
                    .foregroundColor(isDark() ? .white : .black)
                    .frame(width: highlightRect.width + horizontalOffset,
                           height: highlightRect.height + verticalOffset)
                    .offset(x: highlightRect.minX - (horizontalOffset/2),
                            y: highlightRect.minY - (verticalOffset/2))
                    .blur(radius: highlightRect.height * blurMult)
                    .blendMode(.destinationOut)
                
            }
            
            
            GeometryReader { geo in
                let highlightRect = geo[highlightView.anchor]
                
                if highlightRect.minY > 200 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            PopupTitleView(highlightView)
                            Spacer()
                        }
                    }
                    .frame(height: highlightRect.minY - titleOffset)
                } else {
                    VStack {
                        HStack {
                            Spacer()
                            PopupTitleView(highlightView)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .offset(y: highlightRect.maxY + 32)
                }
            }
            
            GeometryReader { geo in
                let highlightRect = geo[highlightView.anchor]
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) {
                                currentIndex = order.count
                                finish()
                            }
                        }, label: {
                            HStack {
                                Text("Пропустить")
                                    .foregroundColor(themeManager.currentTheme.mainText)
                                    .underline()
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(isDark() ? .black : .white)
                                            .blur(radius: 5)
                                            .padding(EdgeInsets(top: -titleVBgShadow,
                                                                leading: -titleHBgShadow,
                                                                bottom: -titleVBgShadow,
                                                                trailing: -titleHBgShadow) )
                                            .opacity(0.6)
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(themeManager.currentTheme.mainText)
                            }
                        })
                        .padding()
                        .offset(y: highlightRect.minY < 16 ? highlightRect.maxY + 8 : 0)
                    }
                    Spacer()
                }
            }
        }
        .compositingGroup()
        .onTapGesture {
            if currentIndex > order.count - 1 {
                finish()
            } else {
                withAnimation(.spring()) {
                    currentIndex += 1
                    if currentIndex == order.count {
                        finish()
                    }
                }
            }
        }
        .onChange(of: currentIndex) { val in
            currentInd = val
        }
    }
    
    @ViewBuilder
    private func PopupTitleView(_ highlightView: HighlightView) -> some View {
        Text(highlightView.text)
            .font(.title)
            .foregroundColor(isDark() ? .white : .black)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(isDark() ? .black : .white)
                    .blur(radius: 20)
                    .padding(EdgeInsets(top: -titleVBgShadow,
                                        leading: -titleHBgShadow,
                                        bottom: -titleVBgShadow,
                                        trailing: -titleHBgShadow) )
                    .opacity(0.7)
            }
            .padding()
            .padding()
            .multilineTextAlignment(.center)
    }
    
    private func finish() {
        allowToShow = false
        isShownPopup = false
        onFinish?()
    }
    
    private func isDark() -> Bool {
        themeManager.currentTheme.isSupportLightTheme
        ? colorScheme != .light
        : themeManager.currentTheme.isDark
    }
}

#Preview {
    SupportView()
        .environmentObject(ThemeManager(1))
}
