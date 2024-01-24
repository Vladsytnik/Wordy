//
//  ReviewView.swift
//  Wordy
//
//  Created by user on 05.01.2024.
//

import SwiftUI
import StoreKit


struct SizePreferenceKey: PreferenceKey { // 1
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct ReviewPreferenceKey: PreferenceKey { // 1
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}


struct ReviewView: View {
    
    @Binding var isOpened: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @AppStorage("isReviewBtnDidTap") private var isReviewDidTap = false
    
    @State private var btnSize: CGSize = .zero
    @State private var reviewSize: CGSize = .zero
    
    var cornerMult = 0.13
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("А знаете ли вы, что?".localize())
                    .font(.title2)
                Text("Ничего не радует разработчиков сильнее, чем хороший отзыв в App Store :)".localize())
            }
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(themeManager.currentTheme.mainText)
            
            
            VStack {
                Button(action: {
                    #warning("Надо как выйдет в аппстор перекидывать в отзывы вместо открытия экрана оценки")
                    isReviewDidTap = true
                    DispatchQueue.main.async {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                            isOpened.toggle()
                        }
                    }
                }, label: {
                    Text("Оставить отзыв".localize())
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .padding()
                        .padding(.horizontal)
                        .padding(.horizontal)
                        .background {
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: SizePreferenceKey.self, value: geo.size) // 2
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: self.btnSize.height / 2)
                                .foregroundColor(themeManager.currentTheme.accent)
                        }
                })
                
                Button(action: {
                    withAnimation {
                        isOpened.toggle()
                    }
                }, label: {
                    Text("Пусть разработчики грустят".localize())
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .font(.callout)
                })
                .padding(.vertical)
            }
        }
        .background(content: {
            GeometryReader{ geo in
                Color.clear
                    .preference(key: ReviewPreferenceKey.self, value: geo.size)
            }
        })
        .onPreferenceChange(ReviewPreferenceKey.self, perform: { value in
            self.reviewSize = value
        })
        .onPreferenceChange(SizePreferenceKey.self) { newSize in // 3
            btnSize = newSize
        }
        .padding(.vertical)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: reviewSize.height * cornerMult)
                .foregroundColor(themeManager.currentTheme.main)
        }
        .padding(.horizontal)
        .offset(y: -50)
    }
}

#Preview {
    ReviewView(isOpened: .constant(true))
        .environmentObject(ThemeManager(0))
}
