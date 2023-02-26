//
//  View + Modifiers.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI

extension View {
	func setTrailingNavBarItem(completion: @escaping () -> Void) -> some View {
		var view = TrailingNavBarItem()
		view.completion = completion
		return modifier(view)
	}
}

extension View {
	func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
	}
	
	func activity(_ show: Binding<Bool>) -> some View {
		ModifiedContent(content: self, modifier: ShowActivity(showActivity: show))
	}
}

extension View {
	func showAlert(title: String, description: String, isPresented: Binding<Bool>, titleWithoutAction: String = "ОК", titleForAction: String = "Попробовать снова", repeatAction: @escaping () -> Void) -> some View {
		return ModifiedContent(content: self, modifier: ShowAlert(showAlert: isPresented, title: title, description: description, titleWithoutAction: titleWithoutAction, titleForAction: titleForAction, repeatAction: repeatAction))
	}
}

// MARK: - TrailingNavBarItem

struct TrailingNavBarItem: ViewModifier {
	var completion: (() -> Void)?
	
	func body(content: Content) -> some View {
		content
			.navigationBarItems(
				trailing:
					Button(action: {
						completion?()
					}, label: {
						NavigationLink {
							Settings()
						} label: {
							Image(asset: Asset.Images.settingsIcon)
								.resizable()
								.frame(width: 32, height: 30)
						}
					})
			)
	}
}

// MARK: - CornerRadiusStyle

struct CornerRadiusStyle: ViewModifier {
	var radius: CGFloat
	var corners: UIRectCorner
	
	struct CornerRadiusShape: Shape {
		
		var radius = CGFloat.infinity
		var corners = UIRectCorner.allCorners
		
		func path(in rect: CGRect) -> Path {
			let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
			return Path(path.cgPath)
		}
	}
	
	func body(content: Content) -> some View {
		content
			.clipShape(CornerRadiusShape(radius: radius, corners: corners))
	}
}

// MARK: - ShowActivity

struct ShowActivity: ViewModifier {
	
	@Binding var showActivity: Bool
	
	func body(content: Content) -> some View {
		ZStack {
			content
			if showActivity {
				VStack {
					Spacer()
					LottieView(fileName: "loader")
						.frame(width: 200, height: 200)
					Spacer()
				}
				.ignoresSafeArea()
			}
		}
	}
}

struct ShowAlert: ViewModifier {
	
	@Binding var showAlert: Bool
	let title: String
	let description: String
	
	let titleWithoutAction: String
	let titleForAction: String
	
	let repeatAction: () -> Void
	
	func body(content: Content) -> some View {
		ZStack {
			content
				.zIndex(0)
				.disabled(showAlert)
				.opacity(showAlert ? 0.5 : 1)
//				.blur(radius: showAlert ? 1 : 0)
				.onTapGesture {
					if showAlert {
						withAnimation {
							showAlert.toggle()
						}
					}
				}
			if showAlert {
				Alert(
					title: title,
					description: description,
					isShow: $showAlert,
					titleWithoutAction: titleWithoutAction,
					titleForAction: titleForAction,
					repeatAction: repeatAction
				)
					.zIndex(1)
					.transition(.move(edge: .bottom))
			}
		}
	}
}

