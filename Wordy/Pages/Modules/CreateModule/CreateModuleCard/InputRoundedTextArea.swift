//
//  InputRoundedTextArea.swift
//  Wordy
//
//  Created by Vlad Sytnik on 23.12.2022.
//

import SwiftUI

struct InputRoundedTextArea: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	@Binding var moduleName: String
	@FocusState private var moduleNameIsFocused: Bool
	@Environment(\.presentationMode) var presentation
	
	let cardWidth: CGFloat
	let cardName: String
	let words: [String?]
	
	var withoutKeyboard = false
	
	private var width: CGFloat {
		cardWidth / 1.12592593
	}
	private var height: CGFloat {
		cardWidth / 1.94871
	}
	
	let action: () -> Void

	var body: some View {
		ZStack {
			Background(width: width, height: height)
			VStack(alignment: .leading) {
				TextField(LocalizedStringKey("Модуль"), text: $moduleName)
					.font(.system(size: 28, weight: .bold))
					.focused($moduleNameIsFocused)
					.tint(.white)
					.onSubmit {
						guard !moduleName.isEmpty else {
							self.presentation.wrappedValue.dismiss()
							return
						}
//						NetworkManager.createModule(name: moduleName)
						action()
					}
					.disabled(withoutKeyboard)
				Spacer()
				HStack(alignment: .bottom) {
					VStack(alignment: .leading, spacing: 10) {
						Text(Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "")
						Text((Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "") + ".app")
					}
					.font(.system(size: 12, weight: .medium))
					.opacity(0.2)
					Spacer()
					Text("11/15")
						.foregroundColor(Color(asset: Asset.Colors.moduleCardLightGray))
						.opacity(0.3)
				}
			}
			.foregroundColor(themeManager.currentTheme.mainText)
			.offset(y: -5)
			.padding()
		}
		.frame(
			width: width,
			height: height
		)
		.onAppear{
			if !withoutKeyboard {
				//			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				moduleNameIsFocused = true
				//			}
			}
		}
	}
}

struct InputRoundedTextArea_Previews: PreviewProvider {
    static var previews: some View {
		InputRoundedTextArea(moduleName: .constant(""), cardWidth: 250, cardName: "Games", words: [
			"Dude",
			"Get on well well well",
			"Map",
			"Word"
		]) {}
    }
}
