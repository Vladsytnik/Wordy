//
//  SupportView.swift
//  Wordy
//
//  Created by user on 19.01.2024.
//

import SwiftUI

struct BottomPlaceholderPreference: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

enum Field: Int, Hashable {
   case mail
   case message
}

struct SupportView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var emailText = ""
    @State private var messageText = ""
    
    @State private var placeholderSize: CGSize = .zero
    @FocusState private var focusedField: Field?
    
    @State var isActivity = false
    @State var needToShowSuccess = false
    
    @State var showAlert = false
    @State var alert: (title: String, description: String) = (title: "Wordy.app", "")
    
    @State var shakeMailTextField = false
    @State var shakeMessageTextField = false
    
    @State var needToShowPopup = false
    
    @State var popupIndex = 0
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                Header()
                    .if(popupIndex == 2, transform: { v in
                        v.anchorPreference(key: PopupPreferenceKey.self, value: .bounds, transform: { anchor in
                            let highlightView = HighlightView(anchor: anchor, text: "Test 2")
                            return highlightView
                        })
                    })
                
                Spacer()
                
                VStack(spacing: 24) {
                    VStack {
                        HStack {
                            Text("Почта*".localize())
                                .foregroundColor(themeManager.currentTheme.mainText)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        TextField("", text: $emailText)
                            .focused($focusedField, equals: .mail)
                            .onSubmit {
                                focusedField = .message
                            }
                            .placeholder(when: emailText.isEmpty) {
                                Text("mail.example.com".localize())
                                    .foregroundColor(themeManager.currentTheme.mainText.opacity(0.3))
                            }
                            .padding(.horizontal)
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(isDark() ? .black.opacity(0.2) : .white.opacity(0.2))
                                    .onTapGesture {
                                        focusedField = .mail
                                    }
                            }
                            .padding(.horizontal)
                            .tint(themeManager.currentTheme.accent)
                            .offset(x: shakeMailTextField ? 20 : 0)
                            .animation(.default.repeatCount(3, autoreverses: true).speed(3), value: shakeMailTextField)
                    }
                    
                    VStack {
                        HStack {
                            Text("Сообщение*".localize())
                                .foregroundColor(themeManager.currentTheme.mainText)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        TextField("", text: $messageText)
                            .focused($focusedField, equals: .message)
                            .padding(.horizontal)
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(isDark() ? .black.opacity(0.2) : .white.opacity(0.2))
                                    .if(shakeMessageTextField, transform: { v in
                                        v.foregroundColor(.red)
                                    })
                                    .onTapGesture {
                                        focusedField = .message
                                    }
                            }
                            .padding(.horizontal)
                            .tint(themeManager.currentTheme.accent)
                            .offset(x: shakeMessageTextField ? 20 : 0)
                            .animation(.default.repeatCount(3, autoreverses: true).speed(3), value: shakeMessageTextField)
                    }
                }
                .if(popupIndex == 0, transform: { v in
                    v.anchorPreference(key: PopupPreferenceKey.self, value: .bounds, transform: { anchor in
                        let highlightView = HighlightView(anchor: anchor, text: "Test 1")
                        return highlightView
                    })
                })
                
                Button(action: {
                    sendProblemDescriptionToServer()
                }, label: {
                    Text("Отправить".localize())
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .padding()
                        .padding(.horizontal)
                        .background {
                            RoundedRectangle(cornerRadius: 21)
                                .foregroundColor(themeManager.currentTheme.main)
                        }
                })
                .if(popupIndex == 0, transform: { v in
                    v.anchorPreference(key: PopupPreferenceKey.self, value: .bounds, transform: { anchor in
                        let highlightView = HighlightView(anchor: anchor, text: "Test 0")
                        return highlightView
                    })
                })
                
                .padding()
                
                if focusedField == nil {
                    Color.clear
                        .frame(height: placeholderSize.height)
                }
                
                Spacer()
            }
            .animation(.default, value: focusedField)
            
            VStack {
                Spacer()
                
                Text("Отправляя эту форму, вы даете согласие нашей команде поддержки использовать ваш адрес электронной почты и автоматически собираемые данные об устройстве (включая версию ОС) для помощи в разрешении вашего запроса на поддержку. Информация о вашей электронной почте и устройстве будет использоваться исключительно для этой цели и не будет передана третьим лицам. Такое использование не связано с любыми согласиями, предоставленными нашей общей Политикой конфиденциальности.".localize())
//                    .if(popupIndex == 1, transform: { v in
//                        v.anchorPreference(key: PopupPreferenceKey.self, value: .bounds, transform: { anchor in
//                            let highlightView = HighlightView(anchor: anchor, text: "Test 0")
//                            return highlightView
//                        })
//                    })
                    .multilineTextAlignment(.center)
                    .foregroundColor(themeManager.currentTheme.mainText.opacity(0.5))
                    .font(.system(size: 11))
                    .padding(.horizontal)
                    .background { GeometryReader { geo in Color.clear.preference(key: BottomPlaceholderPreference.self, value: geo.size) } }
            }
            .ignoresSafeArea(.keyboard)
            
            if needToShowSuccess {
                if isDark() {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                } else {
                    Color.white.opacity(0.2)
                        .ignoresSafeArea()
                }
                
                Image(systemName: "checkmark.circle.fill")
                    .scaleEffect(2.5)
                    .foregroundColor(themeManager.currentTheme.mainText)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onPreferenceChange(BottomPlaceholderPreference.self) { val in
            self.placeholderSize = val
        }
        .activity($isActivity)
        .animation(.spring(), value: needToShowSuccess)
        .showAlert(title: alert.title, description: alert.description, isPresented: $showAlert, titleWithoutAction: "ОК", titleForAction: "", withoutButtons: true, repeatAction: {})
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                needToShowPopup = true
            }
        }
        .popup(when: needToShowPopup,
              onTap: {
            popupIndex += 1
        })
    }
    
    private func sendProblemDescriptionToServer() {
        guard isValidEmail() else {
            shakeTextField(type: .mail)
            return
        }
        
        guard !messageText.isEmpty else {
            shakeTextField(type: .message)
            return
        }
        
        focusedField = nil
        isActivity = true
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let supportDict = [
            "App Version" : "\(appVersion) (\(appBundle))",
            "Device Name" :  UIDevice.modelName,
            "OS Type" : "iOS",
            "OS Version" : "\(UIDevice.current.systemVersion)",
            "User Email:" : "\(emailText)",
            "Message:" : "\(messageText)"
        ]
        
        Task { @MainActor in
            do {
                try await NetworkManager.sendSupportRequest(withData:supportDict)
                isActivity = false
                needToShowSuccess = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            } catch(let error) {
                isActivity = false
                alert.description = "Произошла какая-то ошибка...".localize()
                showAlert.toggle()
                print("Error in SupportView: \(error)")
            }
        }
    }
    
    private func shakeTextField(type: Field) {
        let group = DispatchGroup()
        
        let workItem = DispatchWorkItem {
            withAnimation(.default.repeatCount(4, autoreverses: true).speed(6)) {
                switch type {
                case .mail:
                    self.shakeMailTextField = true
                case .message:
                    self.shakeMessageTextField = true
                }
            }
            group.leave()
        }
        
        group.enter()
        DispatchQueue.main.async(execute: workItem)
        
        group.notify(queue: .main) {
            switch type {
            case .mail:
                self.shakeMailTextField = false
            case .message:
                self.shakeMessageTextField = false
            }
        }
    }
    
    private func isValidEmail() -> Bool {
        guard !emailText.isEmpty else {
            return false
        }
        
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: emailText)
    }
    
    private func isDark() -> Bool {
        themeManager.currentTheme.isSupportLightTheme
        ? colorScheme != .light
        : themeManager.currentTheme.isDark
    }
    
    @ViewBuilder
    private func Header() -> some View {
        HStack {
            VStack(spacing: 12) {
                HStack {
                    Text("Опишите вашу проблему".localize())
                        .foregroundColor(themeManager.currentTheme.mainText)
                    .font(.title)
                    Spacer()
                }
                
                HStack {
                    Text("Или предложите идею по улучшению приложения".localize())
                        .foregroundColor(themeManager.currentTheme.mainText.opacity(0.6))
                        .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - View Extensions

extension View {
    func observeSize<K: PreferenceKey>(key: K.Type) -> some View {
        self
            .background {
                GeometryReader { geo in
                    Color.clear.preference(key: key.self, value: geo.size as! K.Value)
                }
            }
    }
}

#Preview {
    SupportView()
        .environmentObject(ThemeManager(1))
}
