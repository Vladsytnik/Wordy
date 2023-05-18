//
//  OnboardingPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 11.05.2023.
//

import SwiftUI

struct OnboardingPage: View {
	
	@StateObject private var viewModel = OnboardingViewModel()
	
	private let languages = Language.getAll()
	
	var body: some View {
		ZStack {
			Color(asset: Asset.Colors.navBarPurple)
				.ignoresSafeArea()
			
			switch viewModel.screenType {
			case .languageSelection:
				ScrollView {
					VStack(spacing: 32) {
						Rectangle()
							.frame(height: 32)
							.foregroundColor(.clear)
						
						Spacer()
						
						VStack {
							HStack {
								Text("Родной")
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
								Text("Хочу выучить")
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
						Text("Выберите язык")
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
								Text("ПРОДОЛЖИТЬ")
									.fontWeight(.medium)
									.foregroundColor(.init(white: 0.9))
							}
							.offset(x: viewModel.shakeContinueBtn ? 10 : 0)
							.animation(.spring(), value: viewModel.userCanContinue)
					}
					.padding()
				}
				
				Spacer()
			default:
				Text("Hello, World!")
			}
		}
	}
}

struct LanguageSelectorView: View {
	
	let languages: [Language]
	let generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
	
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
								.foregroundColor(.white.opacity(0.8))
								.fontWeight(.bold)
						}
						if languages[i] == selectedLanguage {
							Image(systemName: "circle.fill")
								.foregroundColor(.green)
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
				.foregroundColor(.init(red: 0.1, green: 0.1, blue: 0.15))
		}
		.frame(height: isClosed ? 0 : .none)
	}
}

struct OnboardingPage_Previews: PreviewProvider {
	static var previews: some View {
		OnboardingPage()
	}
}

struct MyDivider: View {
	var body: some View {
		Rectangle()
			.frame(height: 1)
			.foregroundColor(.white.opacity(0.1))
			.padding(.leading)
			.padding(.trailing)
	}
}