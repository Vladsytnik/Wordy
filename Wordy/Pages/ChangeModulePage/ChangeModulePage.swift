//
//  CreateModuleView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 23.12.2022.
//

import SwiftUI
import MCEmojiPicker

struct ChangeModulePage: View {
    
    let module: Module
    @Binding var moduleName: String
    @Binding var emoji: String
    
    @State var currentModuleName: String = ""
    @State var currentEmoji: String = ""
    
//    @Binding var needUpdateData: Bool
    @State var showActivity: Bool = false
    
    @State private var needAnimate = false
    @State var showEmojiView = false
    
    var isOnboardingMode = false
    @State var disableClosing = false
//    let action: () -> Void
    
    @EnvironmentObject var router: Router
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var isNeedOpenKeyboard = false
    
    var body: some View {
//        Color.clear
//            .background {
                GeometryReader { geo in
                    ZStack {
                        BackgroundView()
                        
                        VStack(spacing:  UIScreen.main.bounds.height < 812 ? 16 : 40) {
//                            Text("Новый модуль".localize())
//                                .foregroundColor(themeManager.currentTheme.mainText)
//                                .font(.system(size: 38, weight: .bold))
//                                .padding(EdgeInsets(top: UIScreen.main.bounds.height < 812 ? 16 : 52, leading: 0, bottom: 0, trailing: 0))
////                                .offset(y: needAnimate ? 0 : 100)
                            ///
                            ///
                            
                            Spacer()
                            
                            if UIScreen.main.bounds.height < 812 {
                                CreateModuleCard(
                                    width: geo.size.width - 164,
                                    needAnimate: $needAnimate,
                                    showEmojiView: $showEmojiView,
                                    emoji: $currentEmoji,
                                    moduleName: $currentModuleName,
                                    isNeedOpenKeyboard: $isNeedOpenKeyboard
                                ) {
                                    createModule()
                                }
                                .shadow(radius: 19)
                            } else {
                                CreateModuleCard(
                                    width: geo.size.width - 200,
                                    needAnimate: $needAnimate,
                                    showEmojiView: $showEmojiView,
                                    emoji: $currentEmoji,
                                    moduleName: $currentModuleName,
                                    isNeedOpenKeyboard: $isNeedOpenKeyboard
                                ) {
                                    createModule()
                                }
                                .shadow(radius: 19)
                                .ignoresSafeArea()
                                .rotation3DEffect(
                                    Angle(degrees: needAnimate ? 0 : 5),
                                    axis: (x: 0.5, y: 0.0, z: 0.0)
                                )
                                .offset(y: needAnimate ? 0 : -10)
                                .animation(.interpolatingSpring(stiffness: 170,
                                                                damping: 8)
                                    .delay(0.3),
                                           value: needAnimate)
                            }
                            
                            // MARK: - Button
                            
                            Button {
                                guard !currentModuleName.isEmpty else { return }
                                createModule()
                            } label: {
                                HStack(spacing: 12) {
                                    if themeManager.currentTheme.isDark {
                                        Image(asset: Asset.Images.addModuleCheckMark)
                                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                                    } else {
                                        Image(asset: Asset.Images.addModuleCheckMark)
                                            .renderingMode(.template)
                                            .colorMultiply(themeManager.currentTheme.mainText)
//                                            .opacity(themeManager.currentTheme.isDark ? 1 : 0.75)
                                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                                    }
                                    
                                    Text("Сохранить".localize())
                                        .foregroundColor(themeManager.currentTheme.mainText)
                                        .font(.system(size: 18, weight: .bold))
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                                }
                                .frame(height: 50)
                                .padding(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24))
                                .background(themeManager.currentTheme.moduleCreatingBtn)
                                .cornerRadius(17)
//                                .offset(y: needAnimate ? 0 : 300)
                            }
                            
                            Spacer()
                        }
                        if showEmojiView {
//                            EmojiView(show: $showEmojiView, txt: $emoji)
                            ZStack {
                                EmojiPopoverView(showEmojiView: $showEmojiView, emoji: $currentEmoji)
                                VStack(alignment: .trailing) {
                                    Spacer()
                                    Button {
//                                        withAnimation {
                                            showEmojiView.toggle()
//                                        }
//                                        isNeedOpenKeyboard = true
                                    } label: {
                                        Text("Готово".localize())
                                            .bold()
                                            .padding(EdgeInsets(top: 12, leading: 30, bottom: 12, trailing: 30))
                                            .foregroundColor(themeManager.currentTheme.mainText)
                                            .background {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .foregroundColor(themeManager.currentTheme.accent)
                                            }
                                            .opacity(0.95)
                                    }
                                }
                                .padding()
                                .offset(y: -64)
                            }
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .onAppear{
                        withAnimation(.spring()) {
                            needAnimate = true
                        }
                    }
                }
//            }
            .activity($showActivity)
            .interactiveDismissDisabled(showEmojiView)
            .onChange(of: currentEmoji) { _ in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.isNeedOpenKeyboard.toggle()
//                }
            }
            .onAppear {
                currentEmoji = emoji
                currentModuleName = moduleName
            }
    }
    
    private func createModule() {
        guard currentEmoji != emoji || currentModuleName != moduleName else {
            presentation.wrappedValue.dismiss()
            return
        }
        
        showActivity = true
        Task { @MainActor in
            do {
                let isSuccess = try await NetworkManager.updateModuleWith(id:module.id, emoji:currentEmoji, name: currentModuleName)
                if isSuccess {
                    emoji = currentEmoji
                    moduleName = currentModuleName
                    presentation.wrappedValue.dismiss()
                }
                showActivity = false
            } catch (let errorText) {
                print("Error in ChangeModulePage -> \(errorText.localizedDescription)")
                showActivity = false
            }
        }
    }
}

struct ChangeModulePage_Previews: PreviewProvider {
    static var previews: some View {
        CreateModuleView(needUpdateData: .constant(false), showActivity: .constant(false))
            .environmentObject(Router())
            .environmentObject(ThemeManager())
    }
}

