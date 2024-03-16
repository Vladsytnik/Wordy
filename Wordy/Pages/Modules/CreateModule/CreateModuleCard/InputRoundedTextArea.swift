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
    @Binding var needOpenKeyboard: Bool
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
                ZStack {
                    TextField("", text: $moduleName)
                        .font(.system(size: 28, weight: .bold))
                        .focused($moduleNameIsFocused)
                        .tint(themeManager.currentTheme.mainText)
                        .onSubmit {
                            guard !moduleName.isEmpty else {
                                self.presentation.wrappedValue.dismiss()
                                return
                            }
                            action()
                        }
                        .disabled(withoutKeyboard)
                    
                    HStack() {
                        Text("Модуль".localize())
                            .font(.system(size: 28, weight: .bold))
                            .opacity(moduleName.count == 0 ? 1 : 0)
                            .foregroundColor(themeManager.currentTheme.mainText.opacity(0.5))
                            .onTapGesture {
                                moduleNameIsFocused = true
                            }
                            .offset(x: 2)
                        Spacer()
                    }
                }
				Spacer()
//				HStack(alignment: .bottom) {
//					VStack(alignment: .leading, spacing: 10) {
//						Text(Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "")
//						Text((Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "") + ".app")
//					}
//					.font(.system(size: 12, weight: .medium))
//					.opacity(0.2)
//					Spacer()
//					Text("11/15")
//						.foregroundColor(Color(asset: Asset.Colors.moduleCardLightGray))
//						.opacity(0)
//				}
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
        .onChange(of: needOpenKeyboard) { val in
            if val {
                moduleNameIsFocused = true
            }
        }
	}
}

struct InputRoundedTextArea_Previews: PreviewProvider {
    static var previews: some View {
        InputRoundedTextArea(moduleName: .constant(""), 
                             needOpenKeyboard: .constant(false),
                             cardWidth: 250,
                             cardName: "Games",
                             words: [
			"Dude",
			"Get on well well well",
			"Map",
			"Word"
		]) {}
    }
}
