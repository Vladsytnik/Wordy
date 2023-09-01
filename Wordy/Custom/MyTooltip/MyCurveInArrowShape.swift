//
//  MyCurveInArrowShape.swift
//  Wordy
//
//  Created by Vlad Sytnik on 31.08.2023.
//

import SwiftUI

public struct MyCurveInArrowShape: Shape {
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: CGPoint(x: 0, y: rect.height))
		path.addQuadCurve(
			to: CGPoint(x: rect.width / 2, y: 0),
			control: CGPoint(x: rect.width * 0.4, y: rect.height)
		)
		path.addQuadCurve(
			to: CGPoint(x: rect.width, y: rect.height),
			control: CGPoint(x: rect.width * 0.6, y: rect.height)
		)
		return path
	}
}

struct CurveInArrowShape_Preview: PreviewProvider {
	static var previews: some View {
		MyCurveInArrowShape().stroke()
	}
}
