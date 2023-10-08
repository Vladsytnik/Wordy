//
//  OnboardingPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 11.05.2023.
//

import SwiftUI

struct SelectLanguagePage: View {
	
	@StateObject private var viewModel = SelectLanguageViewModel()
	@EnvironmentObject var router: Router
	let slideTransition = AnyTransition.move(edge: .leading)
	@EnvironmentObject var themeManager: ThemeManager
	@Environment(\.dismiss) private var dismiss
	
	var isFromSettings = false
	
	private let languages = Language.getAll().sorted(by: { $0.getTitle() < $1.getTitle() })
	
	var body: some View {
		if !isFromSettings {
			NavigationView {
				ZStack {
					themeManager.currentTheme.darkMain
						.ignoresSafeArea()
					ZStack {
						ScrollView {
							VStack(spacing: 32) {
								Rectangle()
									.frame(height: 32)
									.foregroundColor(.clear)
								
								Spacer()
								
								VStack {
									HStack {
										Text(LocalizedStringKey("Родной"))
											.foregroundColor(.init(white: 0.9))
											.font(.system(size: 24, weight: .bold))
										Spacer()
									}
									.padding()
									LanguageSelectorView(languages: languages,
														 selectedLanguage: $viewModel.nativeSelectedLanguage)
									.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
								}
								
								VStack {
									HStack {
										Text(LocalizedStringKey("Хочу выучить"))
											.foregroundColor(.init(white: 0.9))
											.font(.system(size: 24, weight: .bold))
										Spacer()
									}
									.padding()
									LanguageSelectorView(languages: languages,
														 selectedLanguage: $viewModel.learnSelectedLanguage)
									.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
								}
								
								Spacer()
								
								Rectangle()
									.frame(height: 64)
									.foregroundColor(.clear)
							}
						}
						
						VStack {
							HStack {
								Text(LocalizedStringKey("Выберите язык"))
									.foregroundColor(.init(white: 0.9))
									.font(.system(size: 32, weight: .bold))
								Spacer()
							}
							.background{
								VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
									.padding(EdgeInsets(top: -300, leading: -100, bottom: -12, trailing: -100))
							}
							.padding()
							Spacer()
						}
						
						VStack {
							Spacer()
							
							Button {
								viewModel.goNext()
							} label: {
								RoundedRectangle(cornerRadius: 20)
									.frame(width: 250, height: 64)
									.foregroundColor(viewModel.userCanContinue ? Color(asset: Asset.Colors.answer4) : Color(asset: Asset.Colors.answer1))
									.shadow(color: .white.opacity(0.1), radius: 8, x: 0, y: 2)
									.overlay{
										Text(LocalizedStringKey("ПРОДОЛЖИТЬ"))
											.fontWeight(.medium)
											.foregroundColor(.init(white: 0.9))
									}
									.offset(x: viewModel.shakeContinueBtn ? 10 : 0)
									.animation(.spring(), value: viewModel.userCanContinue)
							}
							.padding()
							.disabled(!viewModel.userCanContinue)
						}
						
						Spacer()
					}
				}
				.showAlert(title: viewModel.alert.title,
						   description: viewModel.alert.description,
						   isPresented: $viewModel.showAlert,
						   repeatAction: {})
				.onChange(of: viewModel.showOnboardingPage) { newValue in
					withAnimation {
						router.userIsAlreadyLaunched = true
					}
				}
			}
		} else {
			ZStack {
				if themeManager.currentTheme.isDark {
					themeManager.currentTheme.darkMain
						.ignoresSafeArea()
				} else {
					themeManager.currentTheme.mainBackgroundImage
						.resizable()
						.edgesIgnoringSafeArea(.all)
				}
				
				ZStack {
					ScrollView {
						VStack(spacing: 16) {
//							Rectangle()
//								.frame(height: 32)
//								.foregroundColor(.clear)
							
//							Spacer()
							
//							HStack {
//								BackButton {
//									dismiss()
//								}
//								Spacer()
//							}
							
//							HStack {
//								Text(LocalizedStringKey("Язык"))
//									.foregroundColor(themeManager.currentTheme.mainText)
//									.font(.system(size: 36, weight: .bold))
//									.multilineTextAlignment(.center)
//									.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
//								Spacer()
//							}
							
							VStack {
								HStack {
									Text(LocalizedStringKey("Родной"))
										.foregroundColor(themeManager.currentTheme.mainText)
										.font(.system(size: 24, weight: .bold))
									Spacer()
								}
								.padding()
								LanguageSelectorView(languages: languages,
													 selectedLanguage: $viewModel.nativeSelectedLanguage)
								.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
							}
							
							VStack {
								HStack {
									Text(LocalizedStringKey("Хочу выучить"))
										.foregroundColor(themeManager.currentTheme.mainText)
										.font(.system(size: 24, weight: .bold))
									Spacer()
								}
								.padding()
								LanguageSelectorView(languages: languages,
													 selectedLanguage: $viewModel.learnSelectedLanguage)
								.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
							}
							
							Spacer()
							
							Rectangle()
								.frame(height: 64)
								.foregroundColor(.clear)
						}
					}
					
//					VStack {
//						HStack {
//							Text(LocalizedStringKey("Выберите язык"))
//								.foregroundColor(.init(white: 0.9))
//								.font(.system(size: 32, weight: .bold))
//							Spacer()
//						}
//						.background{
//							VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
//								.padding(EdgeInsets(top: -300, leading: -100, bottom: -12, trailing: -100))
//						}
//						.padding()
//						Spacer()
//					}
					
					VStack {
						Spacer()
						
						Button {
							UserDefaultsManager.nativeLanguage = viewModel.nativeSelectedLanguage
							UserDefaultsManager.learnLanguage = viewModel.learnSelectedLanguage
							dismiss()
						} label: {
							RoundedRectangle(cornerRadius: 20)
								.frame(width: 250, height: 64)
								.foregroundColor(viewModel.userCanContinue ? themeManager.currentTheme.answer4 : themeManager.currentTheme.answer1)
								.shadow(color: .white.opacity(0.1), radius: 8, x: 0, y: 2)
								.overlay{
									Text(LocalizedStringKey("СОХРАНИТЬ"))
										.fontWeight(.bold)
										.foregroundColor(themeManager.currentTheme.mainText)
								}
								.offset(x: viewModel.shakeContinueBtn ? 10 : 0)
								.animation(.spring(), value: viewModel.userCanContinue)
						}
						.padding()
						.disabled(!viewModel.userCanContinue)
					}
					
					Spacer()
				}
			}
//			.navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(LocalizedStringKey("Язык"))
			.showAlert(title: viewModel.alert.title,
					   description: viewModel.alert.description,
					   isPresented: $viewModel.showAlert,
					   repeatAction: {})
			.onChange(of: viewModel.showOnboardingPage) { newValue in
				withAnimation {
					router.userIsAlreadyLaunched = true
				}
			}
		}
	}
}

struct LanguageSelectorView: View {
	
	let languages: [Language]
	let generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
	@EnvironmentObject var themeManager: ThemeManager
	
	@State var selectedIndex: Int? = nil
	@State var isClosed = false
	@Binding var selectedLanguage: Language?
	
	var body: some View {
		VStack(alignment: .leading) {
			ForEach(0..<languages.count, id: \.self) { i in
				Button {
					generator?.impactOccurred()
					selectedIndex = i
					selectedLanguage = languages[i]
				} label: {
					HStack {
						HStack(spacing: 16) {
							Text(languages[i].getIcon())
							Text(languages[i].getTitle())
								.foregroundColor(themeManager.currentTheme.mainText)
								.fontWeight(.bold)
						}
						if languages[i] == selectedLanguage {
							Image(systemName: "circle.fill")
                                .foregroundColor(themeManager.currentTheme.mainText)
								.scaleEffect(0.5)
						}
						Spacer()
					}
				}
				.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
				if languages[i] != languages.last {
					MyDivider()
				}
			}
		}
		.padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
		.background{
			RoundedRectangle(cornerRadius: 12)
				.foregroundColor(themeManager.currentTheme.main)
		}
		.frame(height: isClosed ? 0 : .none)
	}
}

struct SelectLanguagePage_Previews: PreviewProvider {
	static var previews: some View {
		SelectLanguagePage()
	}
}

struct MyDivider: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
	var body: some View {
		Rectangle()
			.frame(height: 1)
            .foregroundColor(themeManager.currentTheme.mainText.opacity(0.1))
			.padding(.leading)
			.padding(.trailing)
	}
}
