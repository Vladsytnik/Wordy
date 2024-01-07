//
//  View + Modifiers.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI

extension View {
	func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
		overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
	}
}

extension View {
    func setTrailingNavBarItem(disabled: Bool = false, completion: @escaping () -> Void) -> some View {
        var view = TrailingNavBarItem(disabled: disabled)
		view.completion = completion
		return modifier(view)
	}
}

extension View {
	func animateSelected(isSelected: Binding<Bool>, index: Int, selectedCardIndex: Binding<Int>) -> some View {
		ModifiedContent(content: self, modifier: CardFlipModifier(index: index, isFlipped: isSelected, selectedCardIndex: selectedCardIndex))
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
    func showAlert(title: String, description: String, isPresented: Binding<Bool>, titleWithoutAction: String = "ОК".localize(), titleForAction: String = "Попробовать снова".localize(), withoutButtons: Bool = false, okAction: (() -> Void)? = nil, repeatAction: @escaping () -> Void) -> some View {
        return ModifiedContent(content: self, modifier: ShowAlert(showAlert: isPresented, title: title, description: description, titleWithoutAction: titleWithoutAction, titleForAction: titleForAction, withoutButtons: withoutButtons, okAction: okAction,  repeatAction: repeatAction))
	}
}

// MARK: - TrailingNavBarItem

struct TrailingNavBarItem: ViewModifier {
	
	var disabled: Bool
	var completion: (() -> Void)?
    
    
    @EnvironmentObject var themeManager: ThemeManager
	
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
                                .renderingMode(.template)
                                .colorMultiply(themeManager.currentTheme.mainText)
                                .opacity(themeManager.currentTheme.isDark ? 1 : 0.8)
								.frame(width: 32, height: 30)
						}
						.disabled(disabled)
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
				.disabled(showActivity)
			if showActivity {
				VStack {
					Spacer()
//					LottieView(fileName: "loader")
//						.frame(width: 200, height: 200)
                    LottieView(fileName: "loader2")
                        .frame(width: 60, height: 60)
					Spacer()
				}
				.ignoresSafeArea()
			}
		}
	}
}

struct ShowAlert: ViewModifier {
	
	@Binding var showAlert: Bool
	@EnvironmentObject var themeManager: ThemeManager
	let title: String
	let description: String
	
	let titleWithoutAction: String
	let titleForAction: String
	var withoutButtons = false
	
    var okAction: (() -> Void)?
	let repeatAction: () -> Void
    
	
	func body(content: Content) -> some View {
		ZStack {
			content
				.zIndex(0)
				.disabled(showAlert)
//				.opacity(showAlert ? 0.5 : 1)
//				.blur(radius: showAlert ? 1 : 0)
				.onTapGesture {
					if showAlert {
						withAnimation {
							showAlert.toggle()
						}
					}
				}
			if showAlert {
				if themeManager.currentTheme.isDark {
					Color.black.opacity(0.5)
						.ignoresSafeArea()
						.onTapGesture {
							if showAlert {
								withAnimation {
									showAlert.toggle()
								}
							}
						}
				} else {
					Color.white.opacity(0.5)
						.ignoresSafeArea()
						.onTapGesture {
							if showAlert {
								withAnimation {
									showAlert.toggle()
								}
							}
						}
				}
				
				Alert(
					title: title,
					description: description,
					isShow: $showAlert,
					titleWithoutAction: titleWithoutAction,
					titleForAction: titleForAction,
					withoutButtons: withoutButtons,
                    okAction: okAction,
					repeatAction: repeatAction
				)
					.zIndex(1)
//					.transition(.move(edge: .bottom))
                    .transition(.move(edge: .bottom).animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)))
//                    .offset(y: showAlert ? 0 : 500)
			}
		}
//        .animation(.spring, value: showAlert)
	}

}

struct CardFlipModifier: ViewModifier {
	
	let index: Int
	@Binding var isFlipped: Bool
	@Binding var selectedCardIndex: Int
	
	func body(content: Content) -> some View {
		content
			.rotation3DEffect(
				Angle(degrees: isFlipped ? 360 : 0),
				axis: (x: 0.0, y: 1.0, z: 0.0)
			)
			.animation(
				Animation.spring()
			)
			.onTapGesture {
				if index == selectedCardIndex {
					selectedCardIndex = -1
				}
				selectedCardIndex = index
				withAnimation(
					Animation.interpolatingSpring(stiffness: 200, damping: 20)
				) {
					self.isFlipped.toggle()
				}
			}
			.scaleEffect(isFlipped ? 1.05 : 1)
	}
}

struct CategoryLongTapModifier: ViewModifier {
	
//	private let timer = Timer
	@State private var scaleEffect: CGFloat = 1
	
	func body(content: Content) -> some View {
		content
//			.simultaneousGesture(LongPressGesture().onChanged { _ in
//				print(">> long press")
//			})
//			.simultaneousGesture(LongPressGesture().onEnded { _ in
//				print(">> long press ended")
//			})
			.onLongPressGesture(minimumDuration: 0.5) {
				
			} onPressingChanged: { isChanged in
				if isChanged {
					withAnimation(.easeInOut(duration: 0.5)) {
						scaleEffect = 0.95
					}
                    
				} else {
					scaleEffect = 1
				}
					
			}
			.scaleEffect(scaleEffect)

	}
}

struct EdgeBorder: Shape {
	var width: CGFloat
	var edges: [Edge]
	
	func path(in rect: CGRect) -> Path {
		var path = Path()
		for edge in edges {
			var x: CGFloat {
				switch edge {
				case .top, .bottom, .leading: return rect.minX
				case .trailing: return rect.maxX - width
				}
			}
			
			var y: CGFloat {
				switch edge {
				case .top, .leading, .trailing: return rect.minY
				case .bottom: return rect.maxY - width
				}
			}
			
			var w: CGFloat {
				switch edge {
				case .top, .bottom: return rect.width
				case .leading, .trailing: return width
				}
			}
			
			var h: CGFloat {
				switch edge {
				case .top, .bottom: return width
				case .leading, .trailing: return rect.height
				}
			}
			path.addRect(CGRect(x: x, y: y, width: w, height: h))
		}
		return path
	}
}

extension View {
	func showInputTextPopover(show: Binding<Bool>) -> some View {
		ModifiedContent(content: self, modifier: ShowInputTextPopover(show: show))
	}
}

struct ShowInputTextPopover: ViewModifier {
	
	@EnvironmentObject var themeManager: ThemeManager
	@Binding var show: Bool
	@State var text = ""
	
	func body(content: Content) -> some View {
		ZStack {
			content
				.zIndex(0)
				.disabled(show)
				.opacity(show ? 0.5 : 1)
				.onTapGesture {
					if show {
						withAnimation {
							text = ""
							show.toggle()
						}
					}
				}
			if show {
				VStack {
					Spacer()
					InputTextField(
						placeholder: .constant("Example"),
						text: $text,
						needOpen: .constant(true),
						isFirstResponder: .constant(false),
						closeKeyboard: .constant(false),
						onReturn: {
							text = ""
							show.toggle()
						}
					)
					.padding()
					.background {
						ZStack {
							themeManager.currentTheme.main
								.padding(EdgeInsets(top: -32, leading: 0, bottom: 0, trailing: 0))
								.cornerRadius(12, corners: [.topLeft, .topRight])
								.edgesIgnoringSafeArea(.bottom)
						}
					}
				}
				.zIndex(1)
				.transition(.move(edge: .bottom))
			}
		}
	}
}

struct InputTextField: View {
	
	@Binding var placeholder: String
	@Binding var text: String
	@Binding var needOpen: Bool
	@Binding var isFirstResponder: Bool
	@Binding var closeKeyboard: Bool
	@EnvironmentObject var themeManager: ThemeManager
	
	let fontSize: CGFloat = 20
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState var isFocused: Bool
	
	var onReturn: (() -> Void)?
	var onUserDoesntKnow: (() -> Void)?
	
	var body: some View {
		VStack {
			ZStack(alignment: .leading) {
				Text(placeholder)
					.foregroundColor(.white.opacity(0.3))
					.font(.system(size: fontSize, weight: .medium))
					.opacity(text.isEmpty ? 1 : 0)
				HStack {
					TextField("", text: $text, onCommit: {
						onReturn?()
					})
					.foregroundColor(themeManager.currentTheme.mainText)
					.tint(.white)
					.font(.system(size: fontSize, weight: .medium))
					.focused($isFocused)
					if text.count > 0 && isFocused {
						Button {
							text = ""
						} label: {
							Image(asset: Asset.Images.plusIcon)
								.rotationEffect(.degrees(45))
								.opacity(isFocused ? 1 : 0)
						}
					}
				}
			}
			.onAppear {
				isFocused = true
			}
			Rectangle()
				.foregroundColor(.white.opacity(1))
				.frame(height: 1)
		}
	}
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
