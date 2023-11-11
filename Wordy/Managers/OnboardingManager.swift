//
//  OnboardingManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 31.08.2023.
//

import SwiftUI

struct OnboardingStep {
	let number: Int
	var stepDescription: String?
}

enum ScreenType {
	case modules
    case moduleScreen
}

struct Holder { static var called = false }

class OnboardingManager: ObservableObject {
	
	@Published private(set) var isShow = true
	@Published private(set) var isOnboardingMode = true
	@Published private(set) var onboardingHasFinished = false
	
	private let currentScreen: ScreenType
	private let animationDuration: Double = 2.5
	
	var countOfSteps = 0
	@Published var currentStepIndex = 0
	
	init(screen: ScreenType, countOfSteps: Int) {
		self.currentScreen = screen
		self.countOfSteps = countOfSteps
//		if !Holder.called {
//			Holder.called = true
//			UserDefaultsManager.isFirstLaunchOfModulesPage = true
//		}
	}
	
	// MARK: - Methods
	
	func goToNextStep() {
        switch currentScreen {
        case .modules:
            if UserDefaultsManager.isNotFirstLaunchOfModulesPage {
                return
            }
        case .moduleScreen:
            break;
        }
		
		currentStepIndex += 1
		if currentStepIndex == countOfSteps {
			onboardingHasFinished = true
			DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
				self.finish()
			}
		}
	}
	
	func finish() {
		if currentStepIndex != countOfSteps {
			currentStepIndex = countOfSteps - 1
			goToNextStep()
			return
		}
		withAnimation {
			onboardingHasFinished = false
		}
        
        switch currentScreen {
        case .modules:
            UserDefaultsManager.isNotFirstLaunchOfModulesPage = true
        case .moduleScreen:
            break
        }
        
		isShow = false
		isOnboardingMode = false
		objectWillChange.send()
		currentStepIndex = 0
	}
}
