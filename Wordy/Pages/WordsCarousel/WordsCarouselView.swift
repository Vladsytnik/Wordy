//
//  WordsCarouselView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 08.02.2023.
//

import SwiftUI

struct WordsCarouselView: View {
	
	@State private var scrollOffset = CGFloat.zero
	@ObservedObject var viewModel = WordsCarouselViewModel()
	@Binding var modules: [Module]
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		ZStack {
			Image(asset: Asset.Images.gradientBG)
				.resizable()
				.ignoresSafeArea()
			VStack {
				VStack {
					HStack {
						BackButton {
							dismiss()
						}
						Spacer()
					}
					Text("\(viewModel.selectedWordIndex + 1)/\(viewModel.phrases.count)")
						.foregroundColor(.white)
						.font(.system(size: 40, weight: .bold))
						.padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
				}
				Spacer()
				
				TabView(selection: $viewModel.selectedWordIndex) {
					ForEach(0..<viewModel.phrases.count, id: \.self) { i in
						CarouselCard(phrase: viewModel.phrases[viewModel.phrases.count - 1 - i])
							.padding(.leading)
							.padding(.trailing)
							.tag(i)
						
					}
				}
				.tabViewStyle(.page(indexDisplayMode: .never))
				
				Spacer(minLength: 50)
				LearnModuleButton {
					
				}
				.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
			}
		}
		.onChange(of: viewModel.modules) { newValue in
			modules = newValue
		}
		.navigationBarBackButtonHidden()
		.onChange(of: scrollOffset) { newValue in
			print(newValue)
		}
	}
	
	init(modules: Binding<[Module]>, moduleIndex: Int, selectedWordIndex: Int) {
		self._modules = modules
		viewModel.modules = modules.wrappedValue
		viewModel.index = moduleIndex
		viewModel.selectedWordIndex = selectedWordIndex
	}

	
}

struct CarouselCard: View {
	
	var phrase: Phrase
	
	var body: some View {
		VStack {
			SpeachButton()
			Spacer()
			MainText(phrase: phrase)
			Spacer()
			Button {
				
			} label: {
				Text("УДАЛИТЬ")
					.font(.system(size: 16, weight: .bold))
					.foregroundColor(.white.opacity(0.82))
			}
		}
		.background{
			Image(asset: Asset.Images.carouselBG)
				.resizable()
				.padding(EdgeInsets(top: -24, leading: -24, bottom: -24, trailing: -24))
		}
		.padding(EdgeInsets(top: 24, leading: 32, bottom: 24, trailing: 32))
	}
	
}

struct WordsCarouselView_Previews: PreviewProvider {
    static var previews: some View {
		WordsCarouselView(modules: .constant([
			Module(name: "Test",
				   emoji: "👻",
				   id: "400",
				   date: Date(),
				   phrases: [
					Phrase(nativeText: "Test", translatedText: "Test", date: Date()),
					Phrase(nativeText: "Test", translatedText: "Test", date: Date()),
					Phrase(nativeText: "Test", translatedText: "Test", date: Date()),
					Phrase(nativeText: "Test", translatedText: "Test", date: Date())
				   ])
		]), moduleIndex: 0, selectedWordIndex: 0)
    }
}

fileprivate struct SpeachButton: View {
	var body: some View {
		HStack {
			Spacer()
			Button {
				
			} label: {
				Image(asset: Asset.Images.speach)
					.resizable()
					.frame(width: 32, height: 32)
			}
		}
	}
}

fileprivate struct MainText: View {
	
	var phrase: Phrase
	
	var body: some View {
		VStack(spacing: 32) {
			VStack(spacing: 10) {
				Text(phrase.nativeText)
					.foregroundColor(.white)
					.font(.system(size: 32, weight: .bold))
					.multilineTextAlignment(.center)
					.minimumScaleFactor(0.5)
				Text(phrase.translatedText)
					.foregroundColor(Color(asset: Asset.Colors.descrWordOrange))
					.font(.system(size: 18, weight: .medium))
					.multilineTextAlignment(.center)
					.minimumScaleFactor(0.5)
			}
			Text("Get on well with my friend i write now somthing for example yeah i know that it is nothing")
				.foregroundColor(.white)
				.font(.system(size: 18))
				.multilineTextAlignment(.center)
				.minimumScaleFactor(0.6)
		}
	}
}
