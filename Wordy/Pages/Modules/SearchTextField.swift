//
//  SearchTextField.swift
//  Wordy
//
//  Created by Vlad Sytnik on 19.12.2022.
//

import SwiftUI

struct SearchTextField: View {
	
	@Binding var searchText: String
	let placeholder: String

    var body: some View {
		Color.clear
			.frame(height: 35)
			.background {
				GeometryReader { geo in
					ZStack {
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(Color(asset: Asset.Colors.searchTFBackground))
							.overlay {
								HStack {
									Image(asset: Asset.Images.searchIcon)
										.padding(.leading)
									TextField(placeholder, text: $searchText)
										.foregroundColor(.white)
										.tint(Color(asset: Asset.Colors.lightPurple))
								}
							}
					}
				}
			}
    }
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
		SearchTextField(searchText: .constant("test"), placeholder: "Search")
			.frame(width: 300)
    }
}
