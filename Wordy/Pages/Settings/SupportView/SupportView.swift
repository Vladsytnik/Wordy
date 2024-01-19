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
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                Header()
                
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

#Preview {
    SupportView()
        .environmentObject(ThemeManager(1))
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
                .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
            self
        }
    }
}

public extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPhone14,4":                              return "iPhone 13 mini"
            case "iPhone14,5":                              return "iPhone 13"
            case "iPhone14,2":                              return "iPhone 13 Pro"
            case "iPhone14,3":                              return "iPhone 13 Pro Max"
            case "iPhone14,7":                              return "iPhone 14"
            case "iPhone14,8":                              return "iPhone 14 Plus"
            case "iPhone15,2":                              return "iPhone 14 Pro"
            case "iPhone15,3":                              return "iPhone 14 Pro Max"
            case "iPhone14,6":                              return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "AudioAccessory5,1":                       return "HomePod mini"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
