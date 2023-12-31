//
//  MyArrowShape.swift
//  Wordy
//
//  Created by Vlad Sytnik on 31.08.2023.
//

import SwiftUI

public struct MyArrowShape: Shape {
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		path.addLines([
			CGPoint(x: 0, y: rect.height),
			CGPoint(x: rect.width / 2, y: 0),
			CGPoint(x: rect.width, y: rect.height),
		])
		return path
	}
}

struct ArrowShape_Preview: PreviewProvider {
	static var previews: some View {
		MyArrowShape().stroke()
	}
}
