//
//  LottieView.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
	let fileName: String
	
	let animationView = LottieAnimationView()
	var isLooped = true
    @EnvironmentObject var themeManager: ThemeManager
	
	func makeUIView(context: Context) -> some UIView {
		let view = UIView(frame: .zero)
		view.backgroundColor = .clear
		
		animationView.animation = .named(fileName)
		animationView.backgroundColor = .clear
		animationView.loopMode = isLooped ? .loop : .playOnce
		animationView.contentMode = .scaleAspectFit
		animationView.play()
		
		view.addSubview(animationView)
		
		animationView.translatesAutoresizingMaskIntoConstraints = false
		animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
		animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        updateColorsForTheme()
		
		return view
	}
    
    func updateColorsForTheme() {
        guard fileName.contains("loader") else { return }
        
        let ciColor = CIColor(color: UIColor(themeManager.currentTheme.accent))
        let accent = LottieColor(r: ciColor.red, g: ciColor.green, b: ciColor.blue, a: 0.8)
        let accentColorValueProvider2 = ColorValueProvider(accent)
        
        let ciColorMain = CIColor(color: UIColor(themeManager.currentTheme.accent))
        let main = LottieColor(r: ciColorMain.red, g: ciColorMain.green, b: ciColorMain.blue, a: 0.5)
        let mainColorValueProvider = ColorValueProvider(main)
        
        let ciColorMain2 = CIColor(color: UIColor(themeManager.currentTheme.accent))
        let main2 = LottieColor(r: ciColorMain2.red, g: ciColorMain2.green, b: ciColorMain2.blue, a: 0.3)
        let mainColorValueProvider2 = ColorValueProvider(main2)
        
        let keyPath = AnimationKeypath(keypath: "green ring 1.Ellipse 1.Stroke 1.Color") // главный цвет
        animationView.setValueProvider(accentColorValueProvider2, keypath: keyPath)
        
        let keyPath2 = AnimationKeypath(keypath: "flamingo ring 3.Ellipse 1.Stroke 1.Color") // хвостик
        animationView.setValueProvider(mainColorValueProvider2, keypath: keyPath2)
        let keyPath3 = AnimationKeypath(keypath: "flamingo ring 2.Ellipse 1.Stroke 1.Color") // перед хвостиком
        animationView.setValueProvider(mainColorValueProvider, keypath: keyPath3)
        let keyPath4 = AnimationKeypath(keypath: "flaming ring 1.Ellipse 1.Stroke 1.Color") // второй цвет
        animationView.setValueProvider(mainColorValueProvider, keypath: keyPath4)
        
//        animationView.logHierarchyKeypaths()
    }
	
	func updateUIView(_ uiView: UIViewType, context: Context) {
		
	}
}

