//
//  MyTooltip.swift
//  Wordy
//
//  Created by Vlad Sytnik on 31.08.2023.
//

import SwiftUI

struct MyTooltipModifier<TooltipContent: View>: ViewModifier {
	
	// MARK: - Uninitialised properties
	var enabled: Bool
	var config: MyTooltipConfig
	var content: TooltipContent
	let appearingDelayValue: Double
	@State var isAppear: Bool = false
	
	@EnvironmentObject var themeManager: ThemeManager
	
	// MARK: - Initialisers
	
	init(
		enabled: Bool,
		config: MyTooltipConfig,
		@ViewBuilder content: @escaping () -> TooltipContent,
		appearingDelayValue: Double = 1
	) {
		self.enabled = enabled
		self.config = config
        
        self.config.enableAnimation = true
        self.config.animationOffset = 10
        self.config.animationTime = 1
        self.config.backgroundColor = Color(asset: Asset.Colors.poptipBgColor)
        self.config.borderWidth = 0
        self.config.zIndex = 1000
        self.config.contentPaddingBottom = 12
        self.config.contentPaddingTop = 12
        self.config.contentPaddingLeft = 16
        self.config.contentPaddingRight = 16
        self.config.borderRadius = 18
        self.config.shadowColor = .black.opacity(0.4)
        self.config.shadowRadius = 20
        self.config.shadowOffset = .init(x: 3, y: 20)
        
		self.content = content()
		self.appearingDelayValue = appearingDelayValue
	}
	
	// MARK: - Local state
	
	@State private var contentWidth: CGFloat = 10
	@State private var contentHeight: CGFloat = 10
	
	@State var animationOffset: CGFloat = 0
	@State var animation: Optional<Animation> = nil
	
	// MARK: - Computed properties
	
	var showArrow: Bool { config.showArrow && config.side.shouldShowArrow() }
	var actualArrowHeight: CGFloat { self.showArrow ? config.arrowHeight : 0 }
	
	var arrowOffsetX: CGFloat {
		switch config.side {
		case .bottom, .center, .top:
			return 0
		case .left:
			return (contentWidth / 2 + config.arrowHeight / 2)
		case .topLeft, .bottomLeft:
			return (contentWidth / 2
					+ config.arrowHeight / 2
					- config.borderRadius / 2
					- config.borderWidth / 2)
		case .right:
			return -(contentWidth / 2 + config.arrowHeight / 2)
		case .topRight, .bottomRight:
			return -(contentWidth / 2
					 + config.arrowHeight / 2
					 - config.borderRadius / 2
					 - config.borderWidth / 2)
		}
	}
	
	var arrowOffsetY: CGFloat {
		switch config.side {
		case .left, .center, .right:
			return 0
		case .top:
			return (contentHeight / 2 + config.arrowHeight / 2)
		case .topRight, .topLeft:
			return (contentHeight / 2
					+ config.arrowHeight / 2
					- config.borderRadius / 2
					- config.borderWidth / 2)
		case .bottom:
			return -(contentHeight / 2 + config.arrowHeight / 2)
		case .bottomLeft, .bottomRight:
			return -(contentHeight / 2
					 + config.arrowHeight / 2
					 - config.borderRadius / 2
					 - config.borderWidth / 2)
		}
	}
	
	// MARK: - Helper functions
	
	private func offsetHorizontal(_ g: GeometryProxy) -> CGFloat {
		switch config.side {
		case .left, .topLeft, .bottomLeft:
			return -(contentWidth + config.margin + actualArrowHeight + animationOffset)
		case .right, .topRight, .bottomRight:
			return g.size.width + config.margin + actualArrowHeight + animationOffset
		case .top, .center, .bottom:
			return (g.size.width - contentWidth) / 2
		}
	}
	
	private func offsetVertical(_ g: GeometryProxy) -> CGFloat {
		switch config.side {
		case .top, .topRight, .topLeft:
			return -(contentHeight + config.margin + actualArrowHeight + animationOffset)
		case .bottom, .bottomLeft, .bottomRight:
			return g.size.height + config.margin + actualArrowHeight + animationOffset
		case .left, .center, .right:
			return (g.size.height - contentHeight) / 2
		}
	}
	
	// MARK: - Animation stuff
	
	private func dispatchAnimation() {
		if (config.enableAnimation) {
			DispatchQueue.main.asyncAfter(deadline: .now() + config.animationTime) {
				self.animationOffset = config.animationOffset
				self.animation = config.animation
				DispatchQueue.main.asyncAfter(deadline: .now() + config.animationTime*0.1) {
					self.animationOffset = 0
					
					self.dispatchAnimation()
				}
			}
		}
	}
	
	// MARK: - TooltipModifier Body Properties
	
	private var sizeMeasurer: some View {
		GeometryReader { g in
			Text("")
				.onAppear {
					self.contentWidth = config.width ?? g.size.width
					self.contentHeight = config.height ?? g.size.height
				}
		}
	}
	
	private var arrowView: some View {
		guard let arrowAngle = config.side.getArrowAngleRadians() else {
			return AnyView(EmptyView())
		}
		
		return AnyView(arrowShape(angle: arrowAngle, borderColor: config.borderColor)
			.background(arrowShape(angle: arrowAngle)
				.frame(width: config.arrowWidth, height: config.arrowHeight)
				.foregroundColor(config.backgroundColor)
			).frame(width: config.arrowWidth, height: config.arrowHeight)
			.offset(x: CGFloat(Int(self.arrowOffsetX)), y: CGFloat(Int(self.arrowOffsetY))))
	}
	
	private func arrowShape(angle: Double, borderColor: Color? = nil) -> AnyView {
		switch config.arrowType {
		case .default:
			let shape = MyArrowShape()
				.rotation(Angle(radians: angle))
			if let borderColor {
				return AnyView(shape.stroke(borderColor))
			}
			return AnyView(shape)
		case .curveIn:
			let shape = MyCurveInArrowShape()
				.rotation(Angle(radians: angle))
			if let borderColor {
				return AnyView(shape.stroke(borderColor))
			}
			return AnyView(shape)
		}
	}
	
	private var arrowCutoutMask: some View {
		guard let arrowAngle = config.side.getArrowAngleRadians() else {
			return AnyView(EmptyView())
		}
		
		return AnyView(
			ZStack {
				Rectangle()
					.frame(
						width: self.contentWidth + config.borderWidth * 2,
						height: self.contentHeight + config.borderWidth * 2)
					.foregroundColor(themeManager.currentTheme.mainText)
				Rectangle()
					.frame(
						width: config.arrowWidth,
						height: config.arrowHeight + config.borderWidth)
					.rotationEffect(Angle(radians: arrowAngle))
					.offset(
						x: self.arrowOffsetX,
						y: self.arrowOffsetY)
					.foregroundColor(.black)
			}
				.compositingGroup()
				.luminanceToAlpha()
		)
	}
	
	var tooltipBody: some View {
		GeometryReader { g in
			ZStack {
				RoundedRectangle(cornerRadius: config.borderRadius, style: config.borderRadiusStyle)
					.stroke(config.borderWidth == 0 ? Color.clear : config.borderColor)
					.frame(width: contentWidth, height: contentHeight)
					.mask(self.arrowCutoutMask)
					.background(
						RoundedRectangle(cornerRadius: config.borderRadius)
							.foregroundColor(config.backgroundColor)
					)
					.shadow(color: config.shadowColor,
							radius: config.shadowRadius,
							x: config.shadowOffset.x,
							y: config.shadowOffset.y)
				
				ZStack {
					content
						.padding(config.contentPaddingEdgeInsets)
						.frame(
							width: config.width,
							height: config.height
						)
						.fixedSize(horizontal: config.width == nil, vertical: true)
				}
				.background(self.sizeMeasurer)
				.overlay(self.arrowView)
			}
			.offset(x: self.offsetHorizontal(g), y: self.offsetVertical(g))
			.animation(self.animation)
			.zIndex(config.zIndex)
			.onAppear {
				self.dispatchAnimation()
			}
			.opacity(isAppear && enabled ? 1 : 0)
			.animation(.spring().delay(appearingDelayValue), value: isAppear)
			.onAppear{
				isAppear = true
			}
		}
	}
	
	// MARK: - ViewModifier properties
	
	func body(content: Content) -> some View {
		content
			.overlay(enabled ? tooltipBody.transition(config.transition) : nil)
			.animation(.spring(), value: enabled)
	}
}

struct Tooltip_Previews: PreviewProvider {
	static var previews: some View {
		
		let side: MyTooltipSide = .top
		
		var config1 = MyDefaultTooltipConfig(side: side)
		config1.backgroundColor = .black
		
		let config2 = MyDefaultTooltipConfig(side: side)
		
		var config3 = MyDefaultTooltipConfig(side: side)
		config3.backgroundColor = .green
		config3.borderColor = .red
		
		var config4 = MyDefaultTooltipConfig(side: side)
		config4.arrowWidth = 24
		config4.arrowHeight = 8
		config4.backgroundColor = .black
		config4.arrowType = .curveIn
		
		var config5 = MyDefaultTooltipConfig(side: side)
		config5.arrowWidth = 24
		config5.arrowHeight = 8
		config5.arrowType = .curveIn
		
		var config6 = MyDefaultTooltipConfig(side: side)
		config6.arrowWidth = 24
		config6.arrowHeight = 8
		config6.backgroundColor = .green
		config6.borderColor = .red
		config6.arrowType = .curveIn
		
		return VStack {
			HStack {
				Text("Say...").mytooltip(config: config1) {
					Text("Something nice!")
						.foregroundColor(.white)
				}.padding(54)
				Text("Say...").mytooltip(config: config4) {
					Text("Something nice!")
						.foregroundColor(.white)
				}.padding(54)
			}
			HStack {
				Text("Say...").mytooltip(config: config2) {
					Text("Something nice!")
						.foregroundColor(.black)
				}.padding(54)
				Text("Say...").mytooltip(config: config5) {
					Text("Something nice!")
						.foregroundColor(.black)
				}.padding(54)
			}
			HStack {
				Text("Say...").mytooltip(config: config3) {
					Text("Something nice!")
						.foregroundColor(.black)
				}.padding(54)
				Text("Say...").mytooltip(config: config6) {
					Text("Something nice!")
						.foregroundColor(.black)
				}.padding(54)
			}
		}
		.previewDevice(PreviewDevice(rawValue: "iPhone 14"))
	}
}

public extension View {
	// Only enable parameter accessible
	func mytooltip<MyTooltipContent: View>(
		_ enabled: Bool = true,
		appearingDelayValue: Double = 1,
		@ViewBuilder content: @escaping () -> MyTooltipContent
	) -> some View {
		let config: MyTooltipConfig = MyDefaultTooltipConfig.shared
		
		return modifier(MyTooltipModifier(enabled: enabled, config: config, content: content, appearingDelayValue: appearingDelayValue))
	}
	
	// Only enable and config available
	func mytooltip<MyTooltipContent: View>(
		_ enabled: Bool = true,
		config: MyTooltipConfig,
		appearingDelayValue: Double = 1,
		@ViewBuilder content: @escaping () -> MyTooltipContent
	) -> some View {
		modifier(MyTooltipModifier(enabled: enabled, config: config, content: content, appearingDelayValue: appearingDelayValue))
	}
	
	// Enable and side are available
	func mytooltip<MyTooltipContent: View>(
		_ enabled: Bool = true,
		side: MyTooltipSide,
		appearingDelayValue: Double = 1,
		@ViewBuilder content: @escaping () -> MyTooltipContent
	) -> some View {
		var config = MyDefaultTooltipConfig.shared
		config.side = side
		
		return modifier(MyTooltipModifier(enabled: enabled, config: config, content: content, appearingDelayValue: appearingDelayValue))
	}
	
	// Enable, side and config parameters available
	func mytooltip<MyTooltipContent: View>(
		_ enabled: Bool = true,
		side: MyTooltipSide,
		config: MyTooltipConfig,
		appearingDelayValue: Double = 1,
		@ViewBuilder content: @escaping () -> MyTooltipContent
	) -> some View {
		var config = config
		config.side = side
		
		return modifier(MyTooltipModifier(enabled: enabled, config: config, content: content, appearingDelayValue: appearingDelayValue))
	}
}

// MARK: - Without `enabled: Bool`
public extension View {
	// No-parameter tooltip
	func mytooltip<TooltipContent: View>(
		appearingDelayValue: Double = 1,
		@ViewBuilder content: @escaping () -> TooltipContent
	) -> some View {
		let config = MyDefaultTooltipConfig.shared
		
		return modifier(MyTooltipModifier(enabled: true, config: config, content: content, appearingDelayValue: appearingDelayValue))
	}
	
	// Only side configurable
	func mytooltip<TooltipContent: View>(
		_ side: MyTooltipSide,
		appearingDelayValue: Double = 1,
		@ViewBuilder content: @escaping () -> TooltipContent
	) -> some View {
		var config = MyDefaultTooltipConfig.shared
		config.side = side
		
		return modifier(MyTooltipModifier(enabled: true, config: config, content: content, appearingDelayValue: appearingDelayValue))
	}
	
	// Side and config are configurable
	func mytooltip<TooltipContent: View>(
		_ side: MyTooltipSide,
		config: MyTooltipConfig,
		appearingDelayValue: Double = 1,
		@ViewBuilder content: @escaping () -> TooltipContent
	) -> some View {
		var config = config
		config.side = side
		
		return modifier(MyTooltipModifier(enabled: true, config: config, content: content, appearingDelayValue: appearingDelayValue))
	}
}
