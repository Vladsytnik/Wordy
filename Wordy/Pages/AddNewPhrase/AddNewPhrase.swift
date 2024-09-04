//
//  AddNewPhrase.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.01.2023.
//

import SwiftUI
import Combine
import SwiftUITooltip

struct AddNewPhrase: View {
	
	@Binding var module: Module
	
	@State private var nativeText = ""
	@State private var translatedText = ""
	@State private var exampleText = ""
	
	@Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = AddNewPhraseViewModel()
	@EnvironmentObject var themeManager: ThemeManager
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State var isShowLimitAlert = false
    @State var isShowPaywall = false
    
    init(module: Binding<Module>) {
        self._module = module
        viewModel.module = module.wrappedValue
    }
    
	var body: some View {
        ZStack {
            ZStack {
                if themeManager.currentTheme.isDark {
                    themeManager.currentTheme.darkMain
                        .ignoresSafeArea()
                } else {
                    themeManager.currentTheme.mainBackgroundImage
                        .resizable()
                        .ignoresSafeArea()
                }
                VStack(spacing: 20) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Отменить".localize())
                                .foregroundColor(themeManager.currentTheme.mainText)
                                .font(.system(size: 20, weight: .medium))
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
                        Spacer()
                    }
                    
                    CustomTextField(
                        id: 0,
                        placeholder: "Фраза",
                        text: $nativeText,
                        enableFocuse: true,
                        isFirstResponder: $viewModel.textFieldOneIsActive,
                        closeKeyboard: $viewModel.closeKeyboards,
                        language: UserDefaultsManager.learnLanguage,
                        additionalLangString: UserDefaultsManager.learnLanguage == nil ? "" : "(\(UserDefaultsManager.learnLanguage!.getTitle()))",
                        onSubmit: { id in
                            viewModel.textFieldTwoIsActive = true
                        }
                    )
                    .onTapGesture {
                        viewModel.didTapTextField(index: 0)
                    }
                    .offset(x: !viewModel.nativePhraseIsEmpty ? 0 : 10)
                    
                    CustomTextField(
                        id: 1,
                        placeholder: "Перевод",
                        text: $translatedText,
                        enableFocuse: false,
                        isFirstResponder: $viewModel.textFieldTwoIsActive,
                        closeKeyboard: $viewModel.closeKeyboards,
                        language: UserDefaultsManager.nativeLanguage,
                        additionalLangString: UserDefaultsManager.nativeLanguage == nil ? "" : "(\(UserDefaultsManager.nativeLanguage!.getTitle()))",
                        onSubmit: { id in
                            if viewModel.wasTappedAddExample {
                                viewModel.textFieldThreeIsActive = true
                            }
                        }
                    )
                    .onTapGesture {
                        viewModel.didTapTextField(index: 1)
                    }
                    .offset(x: !viewModel.translatedPhraseIsEmpty ? 0 : 10)
                    .overlay {
                        if translatedText.count == 0 && !viewModel.isTranslationEnable() {
                            NonWorkableAiIcon {
                                let descr = "\nДля текущего модуля вы достигли лимита по количеству автоматического перевода" + "\n\nЧтобы получить полный доступ ко всем возможностям приложения – оформите подписку"
                                viewModel.alert = ("Wordy".localize(), descr.localize())
                                showLimitAlert()
                            }
                        }
                    }
                    
                    if viewModel.showAutomaticTranslatedView {
                        ZStack {
                            HStack() {
                                HStack {
                                    Text(viewModel.automaticTranslatedText)
                                        .foregroundColor(themeManager.currentTheme.mainText)
                                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                        .background {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(themeManager.currentTheme.accent)
                                                BadgeBackground(color: themeManager.currentTheme.accent)
                                            }
                                        }
                                        .onTapGesture {
                                            AnalyticsManager.shared.trackEvent(.didTapOnAutogeneratedTranslate)
                                            viewModel.onboardingManager.goToNextStep()
                                            translatedText = viewModel.automaticTranslatedText
                                            viewModel.showAutomaticTranslatedView = false
                                        }
                                    
                                    Button {
                                        viewModel.showAutomaticTranslatedView = false
                                    } label: {
                                        Image(asset: Asset.Images.plusIcon)
                                            .rotationEffect(.degrees(45))
                                    }
                                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                                }
                                Spacer()
                            }
                            
                            HStack {
                                Color.clear
                                    .frame(width: 10, height: 5)
                                    .mytooltip(viewModel.onboardingIndex == 0
                                               && !UserDefaultsManager.userAlreaySawTranslate
                                               ,
                                               side: .bottomRight,
                                               offset: 16,
                                               config: viewModel.tooltipConfig,
                                               appearingDelayValue: 0.5) {
                                        let text = "Нажмите, чтобы применить".localize()
                                        let descr = "Без подписки доступно \n".localize() + "\(viewModel.countOfFreeTranslateUsing)" + " перевода".localize()
                                        TooltipView(text: text,
                                                    stepNumber: 0,
                                                    allStepCount: 0,
                                                    withoutSteps: true,
                                                    description: viewModel.isAutotransaltingFree ? nil : descr,
                                                    onDisappear: {
                                            UserDefaultsManager.userAlreaySawTranslate = true
                                        }) {
                                            viewModel.onboardingManager.goToNextStep()
                                        }
                                    }
                                Spacer()
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .zIndex(200)
                        
                    }
                    
                    if viewModel.wasTappedAddExample {
                        
                        //MARK: - Examples Text Field
                        
                        CustomTextField(
                            id: 2,
                            placeholder: "Пример",
                            text: $exampleText,
                            enableFocuse: false,
                            isFirstResponder: $viewModel.textFieldThreeIsActive,
                            closeKeyboard: $viewModel.closeKeyboards,
                            language: UserDefaultsManager.learnLanguage
                        )
                        .onTapGesture {
                            viewModel.didTapTextField(index: 2)
                        }
                        .offset(x: !viewModel.examplePhraseIsEmpty ? 0 : 10)
                        .overlay {
                            if exampleText.count == 0 && !viewModel.isExampleGeneratingEnable() {
                                NonWorkableAiIcon {
                                    let descr = "\nДля текущего модуля вы достигли лимита по количеству автоматических генераций примеров" + "\n\nЧтобы получить полный доступ ко всем возможностям приложения – оформите подписку"
                                    viewModel.alert = ("Wordy".localize(), descr.localize())
                                    showLimitAlert()
                                }
                            }
                        }
                        
                        //MARK: - Generated Examples section
                        
                        if viewModel.isShowCreatedExample {
                            HStack() {
                                HStack {
                                    Text(viewModel.examples[viewModel.exampleIndex])
                                        .foregroundColor(themeManager.currentTheme.mainText)
                                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                        .background {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(themeManager.currentTheme.accent)
                                                BadgeBackground(color: themeManager.currentTheme.accent)
                                            }
                                        }
                                        .onTapGesture {
                                            AnalyticsManager.shared.trackEvent(.didTapOnAutogeneratedExample)
                                            viewModel.onboardingManager.goToNextStep()
                                            exampleText = viewModel.examples[viewModel.exampleIndex]
                                            viewModel.isShowCreatedExample = false
                                        }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Button {
                                            viewModel.isShowCreatedExample = false
                                        } label: {
                                            Image(asset: Asset.Images.plusIcon)
                                                .rotationEffect(.degrees(45))
                                        }
                                        .padding(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 0))
                                        
                                        if viewModel.examples.count > 1 {
                                            Button {
                                                viewModel.showNextExampleDidTap()
                                            } label: {
                                                Image(systemName: "arrow.left.arrow.right.circle.fill")
                                                    .resizable()
                                                    .frame(width: 21, height: 21)
                                                    .foregroundColor(themeManager.currentTheme.mainText)
                                            }
                                            .padding(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 0))
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .mytooltip((viewModel.onboardingIndex == 1
                                        || viewModel.onboardingIndex == 2)
                                       && !UserDefaultsManager.userAlreaySawExample
                                       ,
                                       side: .top,
                                       offset: 0,
                                       config: viewModel.tooltipConfig,
                                       appearingDelayValue: 0.5) {
                                let text = "Нажмите, чтобы применить".localize()
                                let descr = "Без подписки доступно \n".localize() + "\(viewModel.countOfFreeExampleGeneratingUsing) " + "генерации примеров".localize()
                                TooltipView(text: text,
                                            stepNumber: 0,
                                            allStepCount: 0,
                                            withoutSteps: true,
                                            description: descr,
                                            onDisappear: {
                                    UserDefaultsManager.userAlreaySawExample = true
                                    UserDefaultsManager.userAlreaySawAddExampleBtn = true
                                }) {
                                    UserDefaultsManager.userAlreaySawExample = true
                                    viewModel.onboardingManager.goToNextStep()
                                }
                            }
                                       .zIndex(viewModel.onboardingManager.currentStepIndex == 1 || viewModel.onboardingManager.currentStepIndex == 2 ? 300 : 100)
                        }
                    } else {
                        HStack {
                            ZStack {
                                HStack {
                                    Button {
                                        viewModel.wasTappedAddExample.toggle()
                                        AnalyticsManager.shared.trackEvent(.didTapAddExample(.CreateNewPhrasePage))
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            viewModel.didTapTextField(index: 2)
                                        }
                                    } label: {
                                        Text("Добавить пример".localize())
                                            .foregroundColor(themeManager.currentTheme.mainText)
                                            .font(.system(size: 14, weight: .regular))
                                    }
                                    .zIndex(100)
                                    .background {
                                        VStack {
                                            Spacer()
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(themeManager.currentTheme.mainText)
                                        }
                                        .offset(y: 6)
                                    }
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: viewModel.showAutomaticTranslatedView ? 0 : 30, trailing: 0))
                                    
                                    Spacer()
                                }
                                
                                
                                HStack {
                                    Color.clear
                                        .frame(width: 10, height: 5)
                                        .mytooltip(viewModel.onboardingIndex == 1
                                                   && !UserDefaultsManager.userAlreaySawAddExampleBtn
                                                   ,
                                                   side: .bottomRight,
                                                   offset: 0,
                                                   config: viewModel.tooltipConfig,
                                                   appearingDelayValue: 0.5) {
                                            let text = "Добавьте пример \nиспользования новой фразы".localize()
                                            let descr = "ИИ автоматически сгенерирует контекст и предложит несколько вариантов на выбор".localize()
                                            TooltipView(text: text,
                                                        stepNumber: 0,
                                                        allStepCount: 0,
                                                        withoutSteps: true,
                                                        description: nil,
                                                        onDisappear: {
                                                UserDefaultsManager.userAlreaySawAddExampleBtn = true
                                            }) {
                                                UserDefaultsManager.userAlreaySawAddExampleBtn = true
                                                viewModel.onboardingManager.goToNextStep()
                                            }
                                        }
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                        .opacity(0.9)
                        .zIndex(viewModel.onboardingManager.currentStepIndex == 0 ? 100 : 300)
                    }
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: viewModel.showAutomaticTranslatedView ? 0 : 30)
                    
                    if viewModel.isActivityProccess {
                        LottieView(fileName: "addWordLoader")
                            .frame(width: 80, height: 80)
                            .offset(y: -30)
                            .transition(.scale)
                    } else {
                        Button {
                            viewModel.onboardingManager.goToNextStep()
                            addPhraseToModule()
                        } label: {
                            HStack {
                                Image(uiImage: UIImage(systemName: "checkmark") ?? UIImage())
                                    .renderingMode(.template)
                                    .foregroundColor(themeManager.currentTheme.mainText)
                                Text("Добавить".localize())
                                    .foregroundColor(themeManager.currentTheme.mainText)
                                    .font(.system(size: 20, weight: .medium))
                            }
                        }
                        .zIndex(100)
                        .transition(.scale)
                    }
                    Spacer()
                }
                .onSubmit {
                    return
                }
                .padding()
            }
            .animation(.spring(), value: viewModel.showAutomaticTranslatedView)
            .animation(.spring(), value: viewModel.isShowCreatedExample)
            .animation(.spring(), value: viewModel.wasTappedAddExample)
            
            .offset(y: viewModel.swipeOffsetValue)
            .gesture(
                DragGesture().onEnded{ value in
                    print(value.translation.height)
                    if value.translation.height > 0 {
                        dismiss()
                    }
                }
            )
            .showAlert(title: viewModel.alert.title, description: viewModel.alert.description, isPresented: $viewModel.showAlert) {
                addPhraseToModule()
            }
            .onChange(of: viewModel.showAlert) { newValue in
                if !newValue {
                    viewModel.textFieldOneIsActive = false
                    viewModel.textFieldTwoIsActive = false
                }
            }
            if viewModel.isActivityProccess {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white.opacity(0.00001))
            }
        }
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
        .onAppear {
            viewModel.module = module
            
            viewModel.nativePhrase = nativeText
            viewModel.translatedPhrase = translatedText
            viewModel.examplePhrase = exampleText
            
            viewModel.isUserHasSubscription = subscriptionManager.isUserHasSubscription
            
            viewModel.countOfTranslatesDict = UserDefaultsManager.countOfTranslatesInModules
            viewModel.countOfGeneratingExamplesDict = UserDefaultsManager.countOfGeneratingExamplesInModules
//            UserDefaultsManager.userAlreaySawExample = false
//            UserDefaultsManager.userAlreaySawTranslate = false
//            UserDefaultsManager.userAlreaySawAddExampleBtn = false
        }
        .onDisappear(perform: {
            UserDefaultsManager.countOfTranslatesInModules = viewModel.countOfTranslatesDict
            UserDefaultsManager.countOfGeneratingExamplesInModules = viewModel.countOfGeneratingExamplesDict
        })
		.onChange(of: viewModel.nativePhrase) { newValue in
			self.nativeText = newValue
		}
		.onChange(of: viewModel.translatedPhrase) { newValue in
			self.translatedText = newValue
		}
		.onChange(of: viewModel.examplePhrase) { newValue in
			self.exampleText = newValue
		}
		.onChange(of: nativeText) { newValue in
			viewModel.userDidWriteNativeText(newValue)
		}
        .onChange(of: subscriptionManager.isUserHasSubscription) { newValue in
            viewModel.isUserHasSubscription = newValue
        }
        .showAlert(title: viewModel.alert.title,
                   description: viewModel.alert.description,
                   isPresented: $isShowLimitAlert,
                   titleWithoutAction: "Попробовать",
                   titleForAction: "Понятно",
                   withoutButtons: false) {
            isShowLimitAlert = false
            isShowPaywall.toggle()
        } repeatAction: {
//            isShowLimitAlert.toggle()
        }
        .sheet(isPresented: $isShowPaywall, content: {
            Paywall(isOpened: $isShowPaywall)
        })
	}
    
    private func showLimitAlert() {
        withAnimation {
            isShowLimitAlert.toggle()
        }
    }
	
	private func addPhraseToModule() {
		viewModel.addWordToCurrentModule(
			native: nativeText,
			translated: translatedText,
			example: exampleText,
			success: {
				dismiss()
			})
	}
    
    @ViewBuilder
    private func NonWorkableAiIcon(callback: (() -> Void)?) -> some View {
        HStack {
            Spacer()
            
            Button {
                callback?()
            } label: {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(themeManager.currentTheme.mainText)
                    .opacity(0.5)
                    .scaleEffect(1.1)
                    .padding()
            }
        }
        .offset(x: -2, y: -6)
        .offset(x: 6)
    }
}

struct AddNewPhrase_Previews: PreviewProvider {
	static var previews: some View {
		AddNewPhrase(
            module: .constant(.init())
		)
        .environmentObject(ThemeManager())
        .environmentObject(AddNewPhraseViewModel())
        .environmentObject(SubscriptionManager.shared)
	}
}

struct CustomTextField: View {
	
    let id: Int
	let placeholder: String
	
	@Binding var text: String
	let enableFocuse: Bool
	@Binding var isFirstResponder: Bool
	@Binding var closeKeyboard: Bool
	var language: Language? = .eng
	var isNotLanguageTextField = false
	var additionalLangString = ""
	@EnvironmentObject var themeManager: ThemeManager
    
    var onSubmit: ((Int) -> Void)?
	
	let fontSize: CGFloat = 20
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState var isFocused: Bool
	
	var body: some View {
		VStack {
			ZStack(alignment: .leading) {
				HStack(spacing: 4) {
                    Text(placeholder.localize())
                        .foregroundColor(themeManager.currentTheme.mainText.opacity(0.3))
						.font(.system(size: fontSize, weight: .medium))
						.opacity(text.isEmpty ? 1 : 0)
					
					Text(additionalLangString)
						.foregroundColor(themeManager.currentTheme.mainText.opacity(0.3))
						.font(.system(size: fontSize, weight: .medium))
						.opacity(text.isEmpty ? 1 : 0)
				}
				HStack {
					if isNotLanguageTextField {
						TextField("", text: $text, onCommit: {
							return
						})
						.foregroundColor(themeManager.currentTheme.mainText)
						.tint(themeManager.currentTheme.mainText)
						.font(.system(size: fontSize, weight: .medium))
						.focused($isFocused)
						.keyboardType(.default)
					} else {
                        ZStack {
                            LanguageTextField(id: id, placeholder: "",
                                              text: $text,
                                              isFirstResponder: _isFocused,
                                              language: language, onSubmit: { id in
                                self.onSubmit?(id)
                            })
                            .foregroundColor(themeManager.currentTheme.mainText)
                            .tint(themeManager.currentTheme.mainText)
                            .font(.system(size: fontSize, weight: .medium))
                            .focused($isFocused)
//                            .keyboardType(.twitter)
                            .keyboardType(.default)
                        }
					}
					if text.count > 0 && isFocused {
						Button {
							text = ""
						} label: {
                            if themeManager.currentTheme.isDark {
                                Image(asset: Asset.Images.plusIcon)
                                    .rotationEffect(.degrees(45))
                                    .opacity(isFocused ? 1 : 0)
                            } else {
                                Image(asset: Asset.Images.plusIcon)
                                    .renderingMode(.template)
                                    .colorMultiply(themeManager.currentTheme.mainText)
                                    .rotationEffect(.degrees(45))
                                    .opacity(isFocused ? 1 : 0)
                            }
						}
					}
				}
			}
			.onSubmit {
                onSubmit?(id)
				return
			}
			.onAppear {
				isFocused = enableFocuse ? true : false
			}
			.onChange(of: isFirstResponder) { newValue in
				if isFirstResponder {
					isFocused = true
				}
			}
			.onChange(of: closeKeyboard) { newValue in
				isFocused = false
			}
			Rectangle()
				.foregroundColor(isFocused ? themeManager.currentTheme.mainText.opacity(1) : themeManager.currentTheme.mainText.opacity(0.2))
				.frame(height: 1)
				.animation(.default, value: isFocused)
		}
	}
}

struct LanguageTextField: UIViewRepresentable {
	
    let id: Int
	var placeholder: String?
	@Binding var text: String
	@FocusState var isFirstResponder: Bool
	var language: Language?
    @EnvironmentObject var themeManager: ThemeManager
    
    var onSubmit: ((Int) -> Void)?
	
	func makeUIView(context: Context) -> UILanguageTextField {
		let langTextField = UILanguageTextField(textLanguage: language)
        langTextField.textColor = UIColor(themeManager.currentTheme.mainText)
		langTextField.delegate = context.coordinator
        langTextField.tintColor = UIColor(themeManager.currentTheme.mainText)
		if isFirstResponder {
			langTextField.becomeFirstResponder()
		} else {
			langTextField.resignFirstResponder()
		}
		langTextField.placeholder = NSLocalizedString(placeholder ?? "", comment: "")
		return langTextField
	}
	
	func updateUIView(_ uiView: UILanguageTextField, context: Context) {
		uiView.text = text
		uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
		uiView.setContentCompressionResistancePriority(.required, for: .vertical)
		uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject, UITextFieldDelegate {
        
        let id: Int
		let parent: LanguageTextField
        var onSubmit: ((Int) -> Void)?
		
		init(_ parent: LanguageTextField) {
            self.id = parent.id
			self.parent = parent
            self.onSubmit = parent.onSubmit
		}
		
		func textFieldDidChangeSelection(_ textField: UITextField) {
			parent.text = textField.text ?? ""
		}
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onSubmit?(id)
            return textField.resignFirstResponder()
        }
	}
}

class UILanguageTextField: UITextField {
	
	private var textLanguage: String?
	
	convenience init(textLanguage: Language? = nil) {
		self.init(frame: .zero)
		self.textLanguage = textLanguage?.getLangCode()
	}
	
	override var textInputMode: UITextInputMode? {
		for tim in UITextInputMode.activeInputModes {
			if tim.primaryLanguage == textLanguage {
				return tim
			}
			if textLanguage == "en-US"
				&& (tim.primaryLanguage == "en-UK"
					|| tim.primaryLanguage == "en-GB"
					|| tim.primaryLanguage == "en-AU"
					|| tim.primaryLanguage == "en-CA"
					|| tim.primaryLanguage == "en-IN"
					|| tim.primaryLanguage == "en-SG") {
				return tim
			}
		}
		return super.textInputMode
	}
}
