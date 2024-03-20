//
//  AddNewPhraseViewModel.swift
//  Wordy
//
//  Created by Vlad Sytnik on 08.01.2023.
//

import SwiftUI
import Combine

class AddNewPhraseViewModel: ObservableObject {
	
	@Published var nativePhrase = ""
	@Published var translatedPhrase = ""
	@Published var examplePhrase = ""
	
	@Published var textFieldOneIsActive = true
	@Published var textFieldTwoIsActive = false
	@Published var textFieldThreeIsActive = false
	
	@Published var swipeOffsetValue: CGFloat = 0
	
	@Published var isActivityProccess = false
	@Published var showAlert = false
	
	@Published var nativePhraseIsEmpty = false
	@Published var translatedPhraseIsEmpty = false
	@Published var examplePhraseIsEmpty = false
	
	@Published var wasTappedAddExample = false
	
	@Published var showAutomaticTranslatedView = false
	@Published var automaticTranslatedText = ""
	@Published var servicedNativeText = ""
    
    @Published var examples: [String] = []
    @Published var exampleIndex = 0
    @Published var isShowCreatedExample = false
    
    @Published var onboardingManager = OnboardingManager(screen: .createNewPhraseScreen, countOfSteps: 3)
    @Published var tooltipConfig = MyDefaultTooltipConfig()
    
    @Published var onboardingIndex = 0
    
    @Published var isUserHasSubscription = false
    
    @Published var submittedTextFields = [0, 0, 0]
    
    let countOfFreeApiUsing = 3
	
	private var cancellable = Set<AnyCancellable>()
	private var networkTask: Task<(), Never>?
    
    private var isFirstLaunch = false
	
	var alert = (title: "Упс! Произошла ошибка...".localize(), description: "")
    
    var countOfGeneratingExamplesDict: [String: Int] = [:]
    var countOfTranslatesDict: [String: Int] = [:]
	
    var module: Module = .init()
	
	@Published var closeKeyboards = false
    
//    @Published var isTranslationEnable = false
//    @Published var isExampleGeneratingEnable = false
	
	init() {
        getTooltipConfig()
        
		$servicedNativeText
			.removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { if $0.count > 0 {
                self.getTranslatedText(from: $0)
                }
            }
            .store(in: &cancellable)
		$automaticTranslatedText
			.receive(on: DispatchQueue.main)
			.sink { text in
				if text.count > 0 && !self.showAutomaticTranslatedView {
					self.showAutomaticTranslatedView = true
				}
			}
			.store(in: &cancellable)
        $wasTappedAddExample
            .sink { isShowExample in
                if isShowExample {
                    self.createExamples()
                }
            }
            .store(in: &cancellable)
        
//        $textFieldOneIsActive
//            .sink { val in
//                if !val {
//                    self.textFieldTwoIsActive.toggle()
//                }
//            }
//            .store(in: &cancellable)
        
        #if targetEnvironment(simulator)
        self.examples = [
            "Apple gave people what they wanted.",
            "Clearly Apple engineers have considered this.",
            "Apple has made various MacOS programs send files to Apple servers without asking permission."
        ]
        #else
          // your real device code
        #endif
        
        if !UserDefaultsManager.isNewPhraseScreenLaunched {
            isFirstLaunch = true
//            wasTappedAddExample = true
        }
        
        self.tooltipConfig.enableAnimation = true
        self.tooltipConfig.animationOffset = 10
        self.tooltipConfig.animationTime = 2
        self.tooltipConfig.backgroundColor = Color(asset: Asset.Colors.poptipBgColor)
        self.tooltipConfig.borderWidth = 0
        self.tooltipConfig.zIndex = 1000
        self.tooltipConfig.contentPaddingBottom = 12
        self.tooltipConfig.contentPaddingTop = 12
        self.tooltipConfig.contentPaddingLeft = 16
        self.tooltipConfig.contentPaddingRight = 16
        self.tooltipConfig.borderRadius = 18
        self.tooltipConfig.shadowColor = .black.opacity(0.4)
        self.tooltipConfig.shadowRadius = 20
        self.tooltipConfig.shadowOffset = .init(x: 3, y: 20)
        self.tooltipConfig.enableAnimation = true
        self.tooltipConfig.margin = 0
	}
    
    func zIndex() -> Double {
        switch onboardingManager.currentStepIndex {
        case 0:
            return 200
        default:
            return 200
        }
    }
    
    func getTooltipConfig() {
        onboardingManager.$currentStepIndex.sink { [weak self] val in
            self?.onboardingIndex = val
        }
        .store(in: &cancellable)
    }
    
    func createExamples() {
        guard isExampleGeneratingEnable() else {
            return
        }
        
        print("createExamples: method entry")
        Task { @MainActor in
            do {
                if servicedNativeText.count > 1 {
                    print("createExamples: before request")
                    let examples = try await NetworkManager.createExamples(with: servicedNativeText)
                    updateGeneratingExamplesCount()
                    if examples.count > 0 {
                        self.examples = examples
                        isShowCreatedExample = true
                    }
                }
            } catch (let error) {
                print("Error in AddNewPhraseViewModel -> createExamples: \(error)")
            }
        }
    }
    
    func showNextExampleDidTap() {
        if exampleIndex < examples.count - 1 {
            exampleIndex += 1
        } else {
            exampleIndex = 0
        }
    }
	
	// MARK: - Translating logic
	
	func getTranslatedText(from text: String) {
        guard text.count > 1 else { return }
        guard isTranslationEnable() else {
            return
        }
        
		networkTask?.cancel()
		networkTask = Task { @MainActor in
			do {
				automaticTranslatedText = try await NetworkManager.translate(from: text)
                updateTranslatedCount()
                if wasTappedAddExample {
                    self.createExamples()
                }
			} catch(let error) {
				print("Error on translating text api: \(error.localizedDescription)")
			}
		}
	}
    
    func userDidntSeeAddExampleBtn() -> Bool {
        return !UserDefaultsManager.userAlreaySawAddExampleBtn
    }
    
    private func updateTranslatedCount() {
        if let count = countOfTranslatesDict[self.module.id] {
            countOfTranslatesDict[self.module.id] = count + 1
        } else {
            countOfTranslatesDict[self.module.id] = 1
        }
    }
    
    private func updateGeneratingExamplesCount() {
        if let count = countOfGeneratingExamplesDict[self.module.id] {
            countOfGeneratingExamplesDict[self.module.id] = count + 1
        } else {
            countOfGeneratingExamplesDict[self.module.id] = 1
        }
    }
	
	func userDidWriteNativeText(_ text: String) {
		servicedNativeText = text
	}
	
	func didTapTextField(index: Int) {
		textFieldOneIsActive = index == 0
		textFieldTwoIsActive = index == 1
		textFieldThreeIsActive = index == 2
	}
    
    func isExampleGeneratingEnable() -> Bool {
        // ИЗ ЗА ЭТОГО МЕТОДА ПАДАЕТ (хз почему, мб из за UserDefaultsManager)
        let isEnabled = (countOfGeneratingExamplesDict[self.module.id] ?? 0 < countOfFreeApiUsing
                         && !module.acceptedAsStudent)
                 || isUserHasSubscription
        return isEnabled
    }
    
    func isTranslationEnable() -> Bool {
        // ИЗ ЗА ЭТОГО МЕТОДА  ПАДАЕТ (хз почему, мб из за UserDefaultsManager)
//        print("Translate test count: for module \(self.module.id) \(viewModel.countOfTranslatesDict[self.module.id])")
        let isEnabled = (countOfTranslatesDict[self.module.id] ?? 0 < countOfFreeApiUsing
                         && !module.acceptedAsStudent)
                 || isUserHasSubscription
        return isEnabled
   }
	
	func addWordToCurrentModule(native: String, translated: String, example: String, success: @escaping () -> Void) {
		nativePhrase = native
		translatedPhrase = translated
		examplePhrase = example
		
		guard !nativePhrase.isEmpty && !translatedPhrase.isEmpty else {
			shakeTextField()
			return
		}
		
		changeActivityState(toProccess: true)
		
		var existingPhrases = module.getPhrasesAsDictionary()
		existingPhrases.append([
			Constants.nativeText: nativePhrase,
			Constants.translatedText: translatedPhrase,
			Constants.date: String().generateCurrentDateMarker(),
			Constants.example: examplePhrase
		])
		
		let newPhrase = [
			Constants.nativeText: nativePhrase,
			Constants.translatedText: translatedPhrase,
			Constants.date: String().generateCurrentDateMarker(),
			Constants.example: examplePhrase
		]
		
		let queue = DispatchQueue(label: "sytnik.wordy.addWordTo")
		
		queue.async {
			NetworkManager.addNewPhrase(newPhrase, to: self.module.id) { [weak self] in
				guard let self = self else { return }
				
//				NetworkManager.getModules { modules in
					self.changeActivityState(toProccess: false)
//                    self.modules = modules
					success()
//				} errorBlock: { errorText in
//					self.changeActivityState(toProccess: false)
//					self.alert.description = errorText
//					self.showAlertNow()
//				}
				
				
			} errorBlock: { [weak self] errorText in
				guard let self else { return }
				self.changeActivityState(toProccess: false)
				self.alert.description = errorText
				self.showAlertNow()
				return
			}
		}
	}
	
	private func changeActivityState(toProccess: Bool) {
		withAnimation {
			if toProccess {
				self.isActivityProccess = true
			} else {
				self.isActivityProccess = false
			}
		}
	}
	
	private func showAlertNow() {
		DispatchQueue.main.async {
			withAnimation {
				self.showAlert = true
			}
		}
	}
	
	private func shakeTextField() {
		let group = DispatchGroup()
		
		let workItem = DispatchWorkItem {
			withAnimation(.default.repeatCount(4, autoreverses: true).speed(6)) {
				self.nativePhraseIsEmpty = self.nativePhrase.isEmpty
				self.translatedPhraseIsEmpty = self.translatedPhrase.isEmpty
			}
			group.leave()
		}
		
		group.enter()
		DispatchQueue.main.async(execute: workItem)
		
		group.notify(queue: .main) {
			self.nativePhraseIsEmpty = false
			self.translatedPhraseIsEmpty = false
		}
	}
}
