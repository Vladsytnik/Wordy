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
	
//	let module: Module
	@Binding var modules: [Module]
	@Binding var filteredModules: [Module]
	@Binding var searchText: String
    
    var index = 0
	
	@State private var nativeText = ""
	@State private var translatedText = ""
	@State private var exampleText = ""
	
	@Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = AddNewPhraseViewModel()
	@EnvironmentObject var themeManager: ThemeManager
    
   
	
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
						placeholder: "Фраза",
						text: $nativeText,
						enableFocuse: true,
						isFirstResponder: $viewModel.textFieldOneIsActive,
						closeKeyboard: $viewModel.closeKeyboards,
						language: UserDefaultsManager.learnLanguage,
						additionalLangString: UserDefaultsManager.learnLanguage == nil ? "" : "(\(UserDefaultsManager.learnLanguage!.getTitle()))"
					)
					.onTapGesture {
						viewModel.didTapTextField(index: 0)
					}
					.offset(x: !viewModel.nativePhraseIsEmpty ? 0 : 10)
					
					CustomTextField(
						placeholder: "Перевод",
						text: $translatedText,
						enableFocuse: false,
						isFirstResponder: $viewModel.textFieldTwoIsActive,
						closeKeyboard: $viewModel.closeKeyboards,
						language: UserDefaultsManager.nativeLanguage,
						additionalLangString: UserDefaultsManager.nativeLanguage == nil ? "" : "(\(UserDefaultsManager.nativeLanguage!.getTitle()))"
					)
					.onTapGesture {
						viewModel.didTapTextField(index: 1)
					}
					.offset(x: !viewModel.translatedPhraseIsEmpty ? 0 : 10)
					
					if viewModel.showAutomaticTranslatedView {
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
                                        viewModel.onboardingManager.goToNextStep()
										translatedText = viewModel.automaticTranslatedText
										viewModel.showAutomaticTranslatedView = false
									}
                                    .mytooltip(viewModel.onboardingIndex == 0
                                               && !UserDefaultsManager.userAlreaySawTranslate
                                               ,
                                               side: .bottomRight,
                                               offset: 0,
                                               config: viewModel.tooltipConfig,
                                               appearingDelayValue: 0.5) {
                                        let text = "Нажмите, чтобы применить".localize()
                                        let descr = "Без подписки доступно \n\(viewModel.countOfFreeApiUsing) переводов".localize()
                                        TooltipView(text: text,
                                                    stepNumber: 0,
                                                    allStepCount: 0,
                                                    withoutSteps: true,
                                                    description: descr,
                                                    onDisappear: {
                                            UserDefaultsManager.userAlreaySawTranslate = true
                                        }) {
                                            viewModel.onboardingManager.goToNextStep()
                                        }
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
						.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .zIndex(200)
						
					}
					
					if viewModel.wasTappedAddExample {
                        
                        //MARK: - Examples Text Field
                        
						CustomTextField(
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
                                let descr = "Без подписки доступно".localize() + " \n\(viewModel.countOfFreeApiUsing) " + "генераций примеров".localize()
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
							Button {
								viewModel.wasTappedAddExample.toggle()
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
                                    UserDefaultsManager.isUserSawCreateNewPhrase = true
                                }) {
                                    viewModel.onboardingManager.goToNextStep()
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
			.onChange(of: viewModel.modules, perform: { newValue in
				self.modules = newValue
			})
			.onChange(of: viewModel.filteredModules, perform: { newValue in
				self.filteredModules = newValue
			})
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
            viewModel.modules = modules
            viewModel.searchedText = searchText
            viewModel.filteredModules = filteredModules
            viewModel.index = index
            
            viewModel.nativePhrase = nativeText
            viewModel.translatedPhrase = translatedText
            viewModel.examplePhrase = exampleText
            
//            UserDefaultsManager.userAlreaySawExample = false
//            UserDefaultsManager.userAlreaySawTranslate = false
//            UserDefaultsManager.userAlreaySawAddExampleBtn = false
        }
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
}

struct AddNewPhrase_Previews: PreviewProvider {
	static var previews: some View {
		AddNewPhrase(
			modules: .constant([.init()]),
            filteredModules: .constant([]),
            searchText: .constant(""),
            index: 0
		)
        .environmentObject(ThemeManager())
        .environmentObject(AddNewPhraseViewModel())
	}
}

struct CustomTextField: View {
	
	let placeholder: String
	
	@Binding var text: String
	let enableFocuse: Bool
	@Binding var isFirstResponder: Bool
	@Binding var closeKeyboard: Bool
	var language: Language? = .eng
	var isNotLanguageTextField = false
	var additionalLangString = ""
	@EnvironmentObject var themeManager: ThemeManager
	
	let fontSize: CGFloat = 20
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState var isFocused: Bool
	
	var body: some View {
		VStack {
			ZStack(alignment: .leading) {
				HStack(spacing: 4) {
					Text(LocalizedStringKey(placeholder))
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
						.keyboardType(.twitter)
					} else {
                        ZStack {
                            LanguageTextField(placeholder: "",
                                              text: $text,
                                              isFirstResponder: _isFocused,
                                              language: language)
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
	
	var placeholder: String?
	@Binding var text: String
	@FocusState var isFirstResponder: Bool
	var language: Language?
    @EnvironmentObject var themeManager: ThemeManager
	
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
		let parent: LanguageTextField
		
		init(_ parent: LanguageTextField) {
			self.parent = parent
		}
		
		func textFieldDidChangeSelection(_ textField: UITextField) {
			parent.text = textField.text ?? ""
		}
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
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
