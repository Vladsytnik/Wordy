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
    
    func popup(allowToShow: Binding<Bool>) -> some View {
        self
            .modifier(PopupModifier(allowToShow: allowToShow))
    }
}

struct PopupModifier: ViewModifier {
    
    @Binding var allowToShow: Bool
    
    let horizontalOffset: CGFloat = 20
    let verticalOffset: CGFloat = 20
    let blur: CGFloat = 7
    
    let cornerRadius: CGFloat = 30
    let direction: PopupDirection = .top
    let title = "Нажмите, чтобы поделиться с нами вашей проблемой"
    
    let titleHBgShadow: CGFloat = 30
    let titleVBgShadow: CGFloat = 10
    
    let titleOffset: CGFloat = 10
    
    @State private var order: [Int] = []
    @State private var currentIndex = 0
    @State private var isShownPopup = true
    
    @State private var IsAppeared = false
    
    @EnvironmentObject var themeManager: ThemeManager
    
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
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                let highlightRect = geo[highlightView.anchor]
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(.white)
                    .frame(width: highlightRect.width + horizontalOffset,
                           height: highlightRect.height + verticalOffset)
                    .offset(x: highlightRect.minX - (horizontalOffset/2),
                            y: highlightRect.minY - (verticalOffset/2))
                    .blur(radius: blur)
                    .blendMode(.destinationOut)
                
            }
            
            
            GeometryReader { geo in
                let highlightRect = geo[highlightView.anchor]
                
                if highlightRect.minY > 64 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(highlightView.text)
                                .font(.title2)
                                .foregroundColor(themeManager.currentTheme.mainText)
                            //                                .bold()
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.black)
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
                            Spacer()
                        }
                    }
                    .frame(height: highlightRect.minY - titleOffset)
                } else {
                    VStack {
                        HStack {
                            Spacer()
                            Text(highlightView.text)
                                .foregroundColor(themeManager.currentTheme.mainText)
                                .bold()
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.black)
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
                            
                        }, label: {
                            HStack {
                                Text("Пропустить")
                                    .foregroundColor(themeManager.currentTheme.mainText)
                                    .underline()
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(.black)
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
                isShownPopup = false
            } else {
                withAnimation(.spring()) {
                    currentIndex += 1
                }
            }
        }
    }
}

#Preview {
    SupportView()
        .environmentObject(ThemeManager(1))
}
