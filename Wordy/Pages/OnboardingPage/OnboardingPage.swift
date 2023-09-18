//
//  OnboardPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.05.2023.
//

import SwiftUI

struct OnboardingPage: View {
	
	@EnvironmentObject var router: Router
	@State var currentPageIndex = 1
	
	var body: some View {
		ZStack {
			Color(asset: Asset.Colors.darkMain)
				.ignoresSafeArea()
			PageControl(numberOfPages: 3, currentPage: $currentPageIndex)
		}
		.navigationBarHidden(true)
		.onAppear{
			//			router.userIsAlreadyLaunched = true
		}
	}
}

struct OnboardingPagePage_Previews: PreviewProvider {
	static var previews: some View {
		OnboardingPage()
			.environmentObject(Router())
	}
}

struct PageControl: UIViewRepresentable {
	
	var numberOfPages: Int
	@Binding var currentPage: Int
	@EnvironmentObject var themeManager: ThemeManager
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeUIView(context: Context) -> UIPageControl {
		let control = UIPageControl()
		control.numberOfPages = numberOfPages
		control.pageIndicatorTintColor = UIColor.lightGray
		control.currentPageIndicatorTintColor = UIColor(themeManager.currentTheme().accent)
		control.addTarget(
			context.coordinator,
			action: #selector(Coordinator.updateCurrentPage(sender:)),
			for: .valueChanged)
		
		return control
	}
	
	func updateUIView(_ uiView: UIPageControl, context: Context) {
		uiView.currentPage = currentPage
	}
	
	class Coordinator: NSObject {
		var control: PageControl
		
		init(_ control: PageControl) {
			self.control = control
		}
		@objc
		func updateCurrentPage(sender: UIPageControl) {
			control.currentPage = sender.currentPage
		}
	}
}
