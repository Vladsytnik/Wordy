//
//  RoundedTextArea.swift
//  Wordy
//
//  Created by Vlad Sytnik on 12.12.2022.
//

import SwiftUI

struct RoundedTextArea: View {
	
	let cardWidth: CGFloat
	let cardName: String
	var firstWord: String {
		module.phrases.count > 0 ? module.phrases.reversed()[0].nativeText : ""
	}
	var secondWord: String {
		module.phrases.count > 1 ? module.phrases.reversed()[1].nativeText : ""
	}
	var countOfPhrases: Int {
		module.phrases.count
	}
	@Binding var module: Module
	@EnvironmentObject var themeManager: ThemeManager
	
	private var width: CGFloat {
		cardWidth / 1.12592593
	}
	private var height: CGFloat {
		cardWidth / 1.94871
	}
	
	var body: some View {
		ZStack {
            Background(width: width, height: height)
            VStack(alignment: .leading) {
                if module.isSharedByTeacher {
                    HStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "network")
                                .scaleEffect(0.7)
                                .foregroundColor(themeManager.currentTheme.mainText)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .padding(EdgeInsets(top: -2, leading: -2, bottom: -2, trailing: -2))
                                .foregroundColor(themeManager.currentTheme.moduleCardRoundedAreaColor)
                        }
                        
                        Spacer()
                    }
                    .padding(EdgeInsets(top: -12, leading: 0, bottom: -30, trailing: 0))
                }
                
				Text(cardName)
					.font(.system(size: 18, weight: .bold))
					.bold()
                
				Spacer()
                
				if countOfPhrases > 1 {
					HStack() {
						VStack(alignment: .leading, spacing: 4) {
							Text(firstWord)
							Text(secondWord)
						}
						.font(.system(size: 9, weight: .medium))
						Spacer()
						Text("\(countOfPhrases)/15")
							.foregroundColor(themeManager.currentTheme.moduleCardMainTextColor)
//                            .foregroundColor(.white)
							.fixedSize()
					}
				} else {
					HStack() {
						Text("\(countOfPhrases)/15")
							.foregroundColor(themeManager.currentTheme.moduleCardMainTextColor)
//                            .foregroundColor(.white)
						Spacer()
					}
				}
			}
			.foregroundColor(themeManager.currentTheme.moduleCardMainTextColor)
//            .foregroundColor(.white)
			.offset(y: -5)
			.padding()
		}
		.frame(
			width: width,
			height: height
		)
	}
}

struct RoundedTextArea_Previews: PreviewProvider {
	static var previews: some View {
		RoundedTextArea(cardWidth: 150, cardName: "Games", module: .constant(.init()))
	}
}

struct Background: View {
	
	let width: CGFloat
	let height: CGFloat
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		Rectangle()
			.frame(
				width: width,
				height: height
			)
			.foregroundColor(themeManager.currentTheme.moduleCardRoundedAreaColor)
			.cornerRadius(10, corners: [.topLeft, .topRight])
			.cornerRadius(30, corners: [.bottomLeft, .bottomRight])
	}
}
