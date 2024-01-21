//
//  PopupExtension.swift
//  Wordy
//
//  Created by user on 20.01.2024.
//

import SwiftUI

struct PopupPreferenceKey: PreferenceKey {
    static var defaultValue: HighlightView?
    
    static func reduce(value: inout HighlightView?, nextValue: () -> HighlightView?) {
        value = nextValue()
    }
}

enum PopupDirection {
    case top, bottom
}

extension View {
    func popup(
        when shouldShow: Bool,
        onTap: @escaping (() -> Void)
    ) -> some View {
        self
            .overlayPreferenceValue(PopupPreferenceKey.self, { preferences in
                
                let horizontalOffset: CGFloat = 10
                let verticalOffset: CGFloat = 10
                let cornerRadius: CGFloat = 30
                let direction: PopupDirection = .top
                let title = "Нажмите, чтобы поделиться с нами вашей проблемой"
                
                let titleHBgShadow: CGFloat = 30
                let titleVBgShadow: CGFloat = 10
                
                let titleOffset: CGFloat = 10
                
                if shouldShow {
                    ZStack {
//                        Color.black.opacity(0.5)
//                            .ignoresSafeArea()
                        
                        GeometryReader { geometry in
                            preferences.map {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundColor(.white)
                                    .frame(width: geometry[$0.anchor].width + horizontalOffset,
                                           height: geometry[$0.anchor].height + verticalOffset)
                                    .offset(x: geometry[$0.anchor].minX - (horizontalOffset/2),
                                            y: geometry[$0.anchor].minY - (verticalOffset/2))
//                                    .blur(radius: 10)
                            }
                        }
                        
//                        .blendMode(.destinationOut)
                        
//                        GeometryReader { geometry in
//                            preferences.map { highlightView in
//                                VStack {
//                                    Spacer()
//                                    HStack {
//                                        Spacer()
//                                        Text(highlightView.text)
//                                            .foregroundColor(.white)
//                                            .background {
//                                                RoundedRectangle(cornerRadius: 12)
//                                                    .foregroundColor(.black)
//                                                    .blur(radius: 20)
//                                                    .padding(EdgeInsets(top: -titleVBgShadow, leading: -titleHBgShadow, bottom: -titleVBgShadow, trailing: -titleHBgShadow) )
//                                                    .opacity(0.7)
//                                            }
//                                            .padding()
//                                            .padding()
//                                            .multilineTextAlignment(.center)
//                                        Spacer()
//                                    }
//                                }
//                                .frame(height: geometry[highlightView.anchor].minY - titleOffset)
//                            }
//                        }
                        
                    }
                    .compositingGroup()
                    .onTapGesture {
                        withAnimation {
                            onTap()
                        }
                    }
                }
            })
            .animation(.spring(), value: shouldShow)
    }
}

#Preview {
    SupportView()
        .environmentObject(ThemeManager(1))
}
