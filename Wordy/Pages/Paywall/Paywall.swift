//
//  Paywall.swift
//  Wordy
//
//  Created by Vlad Sytnik on 21.06.2023.
//

import SwiftUI

struct Paywall: View {
	
	@ObservedObject var viewModel = PaywallViewModel()
	@Binding var isOpened: Bool
	
	var isNothingSelected: Bool {
		viewModel.selectedIndex == nil
	}
	
	let advantagesText = [
		"Discover and get done hundreds of lifestyle checklists",
		"Save your time: use any of our 100500 templates instead of creating new ones",
		"Synchronise all your devices"
	]
	
    var body: some View {
		ZStack {
			Color(asset: Asset.Colors.navBarPurple)
				.ignoresSafeArea()
			GeometryReader { geo in
				ScrollView {
					VStack {
						HStack(alignment: .top) {
							Text("Try Wordy Pro Subscription")
								.foregroundColor(.white)
								.font(.system(size: 32, weight: .bold))
								.padding()
							Spacer()
							CloseBtn(isOpened: $isOpened)
						}
						
						ForEach(advantagesText, id: \.self) { text in
							HStack(alignment: .top, spacing: 16) {
								Image(asset: Asset.Images.advantage)
									.padding(EdgeInsets(top: 0, leading: 16, bottom: text == advantagesText.last ? 48 : 32, trailing: 8))
								Text(text)
									.foregroundColor(.white)
								Spacer()
							}
							.padding(EdgeInsets(top: text == advantagesText.first ? 16 : 0, leading: 0, bottom: 0, trailing: 0))
						}
						
						ForEach(0..<viewModel.prices.count, id: \.self) { i in
							VStack {
								PaywallPlanBtn(
									isSelected: viewModel.selectedIndex == i,
									isMostPopular: i == 0,
									price: viewModel.prices[i].priceDescription,
									descriptionTxt: viewModel.prices[i].descriptionText ?? ""
								) {
									viewModel.didTapBtn(index: i)
								}
							}
						}
						
						Spacer()
							.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
						
						Button {
							
						} label: {
							RoundedRectangle(cornerRadius: 28)
								.frame(height: 56)
								.foregroundColor(isNothingSelected ? .blue.opacity(0.6) : .blue)
								.overlay {
									Text("CHECKOUT")
										.foregroundColor(isNothingSelected ? .white.opacity(0.6) : .white)
										.font(.system(size: 18, weight: .bold))
								}
						}
						.disabled(isNothingSelected)
						.shadow(color: .white.opacity(0.3), radius: isNothingSelected ? 0 : 12)
						.padding()
						.animation(.spring(), value: isNothingSelected)
						
						Rectangle()
							.foregroundColor(.clear)
							.frame(minHeight: geo.size.height > 812 ? geo.size.height * 0.15 : 0)
						
						HStack {
							Button {
								
							} label: {
								Text("PRIVACY POLICY")
							}
							Spacer()
							Button {
								
							} label: {
								Text("TERMS & CONDITIONS")
							}
						}
						.foregroundColor(.white.opacity(0.8))
						.padding()
					}
				}
			}
		}
    }
}

struct Paywall_Previews: PreviewProvider {
    static var previews: some View {
		Paywall(isOpened: .constant(true))
    }
}

struct CloseBtn: View {
	
	@Binding var isOpened: Bool
	
	var body: some View {
		Button {
			isOpened.toggle()
		} label: {
			Image(asset: Asset.Images.closeBtn)
		}
		.scaleEffect(1.3)
		.padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 24))
		.opacity(0.8)
	}
}

struct PaywallPlanBtn: View {
	
	var isSelected = false
	let isMostPopular: Bool
	
	let price: String
	let descriptionTxt: String
	
	var onTap: (() -> Void)?
	
	var body: some View {
		ZStack {
			HStack {
				VStack(alignment: .leading, spacing: 8) {
					Text(price)
						.font(.system(size: 20, weight: .bold))
					Text(descriptionTxt)
						.font(.system(size: 14))
				}
				Spacer()
			}
			
			if isMostPopular {
				VStack {
					HStack {
						Spacer()
						Text("most popular")
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(.white)
							.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
							.background {
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(Color(asset: Asset.Colors.lightPurple))
						}
					}
					.offset(y: -28)
					Spacer()
				}
			}
		}
		.foregroundColor(isSelected ? .white : .black)
		.background {
			RoundedRectangle(cornerRadius: 8)
				.foregroundColor(isSelected ? Color(asset: Asset.Colors.lightPurple) : .white)
				.padding(EdgeInsets(top: -16, leading: -16, bottom: -16, trailing: -16))
		}
		.padding(EdgeInsets(top: 16, leading: 32, bottom: 32, trailing: 32))
		.onTapGesture {
			onTap?()
		}
		.animation(.spring(), value: isSelected)
	}
}

