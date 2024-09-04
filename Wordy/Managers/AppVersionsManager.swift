//
//  AppVersionsManager.swift
//  Wordy
//
//  Created by user on 13.06.2024.
//

import SwiftUI

import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseDatabase

@MainActor
class AppVersionsManager: ObservableObject {
    
    var onOpenPage: (() -> Void)?
    
    static let shared = AppVersionsManager()
    
    @Published var isNeedToShowNewVersionUpdatesScreen = false
    
    @Published var intros: [Intro] = []
    @Published var firstIntroForTransition: Intro = .init()
    
    private var currentVersion: String? {
        if let info = Bundle.main.infoDictionary,
           let currentVersion = info["CFBundleShortVersionString"] as? String {
            return currentVersion
        }
        return nil
    } 
    
    private init() {}
    
    func startChecking() {
        
        #if DEBUG
//        UserDefaults.standard.set("1.2", forKey: "LastAppVersion")
        #endif
        
        let isNewVersionInstalled = isUserUpdated()
        updateLastVersionToCurrent()
        
        if isNewVersionInstalled, let currentVersion {
            print("App Versions Test: Is User Updated App")
            
            Task.detached(priority: .background) {
                do {
                    try await self.loadUpdatedOnboardingContent(forVersion: currentVersion)
                } catch(let error) {
                    print("App Versions Test: Firebase fetching ERROR: \(error.localizedDescription)")
                }
            }
        } else {
            print("App Versions Test: NOT UPDATED")
        }
    }
    
    private func loadUpdatedOnboardingContent(forVersion version: String) async throws {
        let ref = NetworkManager.ref
        
        let pyVersion = version.replacingOccurrences(of: ".", with: "_")
        
        let snapshot = try await ref.child("AppVersions").child(pyVersion).getData()
        intros = []
        
        if let value = snapshot.value as? [String: [String: Any]]
        {
            addFirstTemplatePage()
            
            for features in value.keys {
                if let featureProperties = value[features] {
                    let title = featureProperties["title"] as? String
                    let descr = featureProperties["description"] as? String
                    
                    var resImg: UIImage?
                    
                    if let imgDataStr = featureProperties["image"] as? String,
                       let data = Data(base64Encoded: imgDataStr)
                    {
                        resImg = UIImage(data: data)
                    }
                    
                    let strIndex = String(features.last ?? "0")
                    let index = (Int(strIndex) ?? -1) + 1
                    
                    addIntro(title: title, descr: descr, img: resImg, sortIndex: index)
                }
            }
            
            intros.sort(by: { $0.sortingIndex < $1.sortingIndex })
            showNewsOnboardingIfNeeded()
        }
    }
    
    private func addFirstTemplatePage() {
        let intro = Intro(
            title: "А у нас новое обновление!".localize(),
            description: "Свайпните влево, чтобы посмотреть, что нового добавили в этот релиз.".localize()
        )
        intros.append(intro)
        firstIntroForTransition = intro
    }
    
    private func addIntro(title: String?, descr: String?, img: UIImage?, sortIndex: Int? = nil) {
        guard let title, let descr else { return }
        intros.append(.init(title: title, description: descr, img: img, sortingIndex: sortIndex ?? 0))
    }
    
    private func showNewsOnboardingIfNeeded() {
        if intros.count > 1 {
            Task { @MainActor in
                onOpenPage?()
            }
        }
    }
    
    private func isUserUpdated() -> Bool {
        if let lastAppVersion = UserDefaults.standard.string(forKey: "LastAppVersion") {
            print("App Versions Test: current: \(currentVersion ?? "nil")")
            print("App Versions Test: last: \(lastAppVersion)")
            
            if let currentVersion  {
                return currentVersion != lastAppVersion
            }
        } else {
            print("App Versions Test: last: nil")
        }
        
        return false
    }
    
    private func updateLastVersionToCurrent() {
        if let info = Bundle.main.infoDictionary,
           let currentVersion = info["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.set(currentVersion, forKey: "LastAppVersion")
        }
    }
}


