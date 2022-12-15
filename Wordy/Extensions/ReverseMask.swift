//
//  SwiftUIView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 14.12.2022.
//

import SwiftUI

extension View {
	@available(iOS 15.0, *)
	@inlinable
	public func reverseMask<Mask: View>(
		alignment: Alignment = .center,
		@ViewBuilder _ mask: () -> Mask
	) -> some View {
		self.mask {
			Rectangle()
				.overlay(alignment: alignment) {
					mask()
						.blendMode(.destinationOut)
				}
		}
	}
}
