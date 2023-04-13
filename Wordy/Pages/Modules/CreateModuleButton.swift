//
//  CreateModuleButton.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.12.2022.
//

import SwiftUI

struct CreateModuleButton: View {
	
	let action: () -> Void
	var text: String?
	
    var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: 20)
					.foregroundColor(Color(asset: Asset.Colors.createModuleButton))
					.shadow(color: .white.opacity(0.15), radius: 20)
				HStack {
					if text == nil {
						Image(asset: Asset.Images.addModule)
					}
					Text((text == nil ? "Создать модуль" : text) ?? "")
						.foregroundColor(.white)
						.font(.system(size: 16, weight: .medium))
				}
			}
		}
		.frame(height: 55)
    }
}

struct CreateModuleButton_Previews: PreviewProvider {
	static var previews: some View {
		CreateModuleButton() {}
			.frame(width: 300, height: 55)
			.background{
				Image(asset: Asset.Images.gradientBG)
			}
	}
}
