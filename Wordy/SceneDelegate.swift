//
//  SceneDelegate.swift
//  Wordy
//
//  Created by user on 19.03.2024.
//

import UIKit

class WordySceneDelegate: NSObject, UIWindowSceneDelegate {
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        SubscriptionManager.shared.forceUpdateSubscriptionInfo()
        AppValues.shared.fetchCloudValues()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        //
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
}
