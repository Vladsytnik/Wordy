//
//  Modules.swift
//  Wordy
//
//  Created by Vlad Sytnik on 10.12.2022.
//

import SwiftUI
import Combine

struct Modules: View {
	
	private let columns = [GridItem(.adaptive(minimum: 150), spacing: 20) ]
	
	@State private var scrollOffset = CGFloat.zero
	@State private var isInlineNavBar = false
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
					LazyVGrid(columns: columns, spacing: 14) {
						ForEach(0...20, id: \.self) { i in
							ModuleCard(width: 170)
						}
						.listRowBackground(Color.green)
						.listStyle(.plain)
						.listRowSeparator(.hidden)
					}
					.padding()
					.padding(.top)
				}
				//				.reverseMask {
				//					VStack {
				//						Rectangle()
				////							.frame(width: geometry.size.width + 300, height: geometry.size.width / 3.6)
				//							.frame(height: geometry.safeAreaInsets.top + 10)
				////							.ignoresSafeArea()
				//							.blur(radius: 8)
				//							.offset(y: 7)
				//							.edgesIgnoringSafeArea(.top)
				//						Spacer()
				//					}
				//				}
				.navigationBarItems(trailing: Button(
					action: {
						
					}, label: {
						Image(asset: Asset.Images.settingsIcon)
					})
				)
				.toolbarBackground(.automatic, for: .navigationBar)
				.onChange(of: scrollOffset) { newValue in
					print(newValue)
					withAnimation(.easeInOut(duration: 0.1)) {
						showOrHideNavBar(value: newValue)
					}
				}
				BlurNavBar(show: $isInlineNavBar, scrollOffset: $scrollOffset)
			}
			.edgesIgnoringSafeArea(.bottom)
		}
		.background(
			Image(asset: Asset.Images.gradientBG)
				.resizable()
				.edgesIgnoringSafeArea(.all)
		)
		.navigationTitle("Модули")
	}
	
	init(){
		configNavBarStyle()
	}
	
	private func configNavBarStyle() {
		let navigationBarAppearance = UINavigationBarAppearance()
		navigationBarAppearance.backgroundColor = UIColor.clear
		navigationBarAppearance.largeTitleTextAttributes = [
			.foregroundColor: UIColor.white
		]
		navigationBarAppearance.titleTextAttributes = [
			.foregroundColor: UIColor.white,
		]
		navigationBarAppearance.configureWithTransparentBackground()
		UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
		UINavigationBar.appearance().standardAppearance = navigationBarAppearance
	}
	
	private func showOrHideNavBar(value: CGFloat) {
		if value >= 10 && isInlineNavBar == false {
			self.isInlineNavBar = true
		}
		if value <= 10 && isInlineNavBar == true {
			self.isInlineNavBar = false
		}
	}
}

struct Modules_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			Modules()
		}
	}
}

struct BlurNavBar: View {
	@Binding var show: Bool
	@Binding var scrollOffset: CGFloat
	
	var opacity: Double {
		switch scrollOffset {
		case 0...100:
			return Double(scrollOffset) / 100.0
		case 100...:
			return 1
		default:
			return 0
		}
	}
	
	var body: some View {
		GeometryReader { geo in
			VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
				.frame(height: geo.safeAreaInsets.top)
				.foregroundColor(Color(asset: Asset.Colors.navBarPurple))
				.edgesIgnoringSafeArea(.top)
				.opacity(opacity)
		}
	}
}
