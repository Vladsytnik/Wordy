//
//  Alert.swift
//  Wordy
//
//  Created by Vlad Sytnik on 07.01.2023.
//

import SwiftUI

struct Alert: View {
	
	let title: String
	let description: String
	
	@Binding var isShow: Bool
	@State var scrollOffsetValue: CGFloat = 0
	
	let titleWithoutAction: String
	let titleForAction: String
	
	let repeatAction: () -> Void
	
//	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				VStack {
					Spacer()
					VStack(spacing: 5) {
						Text(title)
							.multilineTextAlignment(.center)
							.foregroundColor(.white)
							.padding(EdgeInsets(top: 50, leading: 30, bottom: 0, trailing: 30))
							.font(.system(size: 28, weight: .bold))
						Text(description)
							.multilineTextAlignment(.center)
							.foregroundColor(.white)
							.font(.system(size: 20, weight: .regular))
							.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
						Rectangle()
							.frame(height: 40)
							.foregroundColor(.clear)
						Button {
							withAnimation {
								isShow = false
							}
						} label: {
							RoundedRectangle(cornerRadius: 18)
								.foregroundColor(Color(asset: Asset.Colors.createModuleButton))
								.frame(width: 200, height: 55)
								.overlay {
									Text(titleWithoutAction)
										.foregroundColor(.white)
										.font(.system(size: 16, weight: .medium))
								}
						}
						Button {
							withAnimation {
								isShow = false
							}
							DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
								repeatAction()
							}
						} label: {
							RoundedRectangle(cornerRadius: 18)
								.foregroundColor(.clear)
								.frame(width: 300, height: 55)
								.overlay {
									Text(titleForAction)
										.foregroundColor(.white)
										.font(.system(size: 16, weight: .medium))
								}
						}
						.padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
					}
					.frame(width: geo.size.width)
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 0))
					.background(Color(asset: Asset.Colors.moduleCardDarkGray))
					.cornerRadius(30, corners: [.topLeft, .topRight])
				}
//				.ignoresSafeArea()
			}
			.offset(y: 100 + scrollOffsetValue)
			.frame(width: geo.size.width, height: geo.size.height)
			.gesture(
				DragGesture()
					.onEnded{ value in
						print(value.translation.height)
						if value.translation.height > 0 {
							withAnimation {
								isShow = false
							}
						}
					}
					.onChanged{ if $0.translation.height > 0 {  scrollOffsetValue = $0.translation.height }}
			)
		}
	}
}

struct Alert_Previews: PreviewProvider {
    static var previews: some View {
		Alert(
			title: "Упс! Ошибка сети",
			description: "Проверьте соединение с интернетом",
			isShow: .constant(true),
			titleWithoutAction: "OK",
			titleForAction: "Попробовать снова"
		) {  }
    }
}
