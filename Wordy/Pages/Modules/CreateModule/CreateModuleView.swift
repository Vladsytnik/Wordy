//
//  CreateModuleView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 23.12.2022.
//

import SwiftUI
import MCEmojiPicker

struct CreateModuleView: View {
	
	@Binding var needUpdateData: Bool
	@Binding var showActivity: Bool
	@State private var needAnimate = false
	@State var showEmojiView = false
	@State var moduleName = ""
	@State var emoji = "📄"
//	let action: () -> Void
	
	@EnvironmentObject var router: Router
	@Environment(\.presentationMode) var presentation
	
    var body: some View {
		Color.clear
			.background {
				GeometryReader { geo in
					ZStack {
						Color(asset: Asset.Colors.moduleCardBG).ignoresSafeArea()
						VStack(spacing: 40) {
							Text("Новый модуль")
								.foregroundColor(.white)
								.font(.system(size: 38, weight: .bold))
								.padding(EdgeInsets(top: 52, leading: 0, bottom: 0, trailing: 0))
								.offset(y: needAnimate ? 0 : 100)
							CreateModuleCard(
								width: geo.size.width - 200,
								needAnimate: $needAnimate,
								showEmojiView: $showEmojiView,
								emoji: $emoji,
								moduleName: $moduleName
							) {
								createModule()
							}
								.shadow(radius: 19)
							Button {
								guard !moduleName.isEmpty else { return }
								createModule()
							} label: {
								HStack(spacing: 12) {
									Image(asset: Asset.Images.addModuleCheckMark)
									Text("Добавить")
										.foregroundColor(.white)
										.font(.system(size: 18, weight: .bold))
								}
								.frame(width: geo.size.width - 200, height: 50)
								.background(Color(asset: Asset.Colors.addModuleButtonBG))
								.cornerRadius(17)
								.offset(y: needAnimate ? 0 : 300)
							}
							Spacer()
						}
						if showEmojiView {
//							EmojiView(show: $showEmojiView, txt: $emoji)
							EmojiPopoverView(showEmojiView: $showEmojiView, emoji: $emoji)
						}
					}
					.onAppear{
						withAnimation(.spring()) {
							needAnimate = true
						}
					}
				}
			}
			.activity($showActivity)
    }
	
	private func createModule() {
		showActivity = true
		NetworkManager.createModule(name: moduleName, emoji: emoji) { successResult in
			needUpdateData.toggle()
			self.presentation.wrappedValue.dismiss()
		} errorBlock: { error in

		}
	}
}

struct CreateModuleView_Previews: PreviewProvider {
    static var previews: some View {
		CreateModuleView(needUpdateData: .constant(false), showActivity: .constant(false))
			.environmentObject(Router())
    }
}

// MARK: - EmojiPopoverView

struct EmojiPopoverView: UIViewControllerRepresentable {
	
	
	@Binding var showEmojiView: Bool
	@Binding var emoji: String
	
	private let viewController = MCEmojiPickerViewController()
	
	func makeUIViewController(context: Context) -> UIViewController {
		viewController.isDismissAfterChoosing = false
		return viewController
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
	
	func makeCoordinator() -> Coordinator {
		Coordinator(vc: viewController, emoji: $emoji, show: $showEmojiView)
	}
	
	class Coordinator: NSObject, MCEmojiPickerDelegate {
		@Binding var showEmojiView: Bool
		@Binding var emoji: String
		
		init(vc: MCEmojiPickerViewController, emoji: Binding<String>, show: Binding<Bool>) {
			self._emoji = emoji
			self._showEmojiView = show
			super.init()
			vc.delegate = self
		}
		
		func didGetEmoji(emoji: String) {
			self.emoji = emoji
			withAnimation {
				showEmojiView.toggle()
			}
		}
	}
}