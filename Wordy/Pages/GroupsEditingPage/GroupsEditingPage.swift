//
//  GroupsEditingPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 28.04.2023.
//

import SwiftUI

struct GroupsEditingPage: View {
	
	@Environment(\.dismiss) private var dismiss
	
	let test = [
		"Хороший доктор",
		"Эйфория",
		"Черная весна",
		"Группа для изучения английского языка а также для добавления различных слов",
		"Мои слова"
	]
	
	let cellHeight: CGFloat = 50
	
	var body: some View {
		ZStack {
			Color(asset: Asset.Colors.navBarPurple)
				.ignoresSafeArea()
			ScrollView {
				VStack(spacing: 20) {
					HStack {
						BackButton {
							dismiss()
						}
						Spacer()
					}
					VStack {
						ForEach(0..<test.count) { i in
							HStack {
								Text(test[i])
									.padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
								Spacer()
								Button {
									
								} label: {
									Image(systemName: "trash")
										.foregroundColor(.red)
								}
								.padding()
							}
							.background {
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(Color(asset: Asset.Colors.moduleCardBG))
							}
							.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
						}
					}
				}
			}
		}
		.navigationBarHidden(true)
	}
}

struct GroupsEditingPage_Previews: PreviewProvider {
    static var previews: some View {
        GroupsEditingPage()
    }
}
