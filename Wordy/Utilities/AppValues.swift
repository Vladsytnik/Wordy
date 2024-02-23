//
//  AppValues.swift
//  Wordy
//
//  Created by user on 23.02.2024.
//

import Foundation
import FirebaseRemoteConfig

enum ValueKey: String {
    case LearningModeCountForFree
    case TestValue
}

class AppValues {
    
    static let shared = AppValues()
    
    var loadingDoneCallback: (() -> Void)?
    
    var learningModeCountForFree: Int {
        self.int(forKey: ValueKey.LearningModeCountForFree.rawValue)
    }
    var testValue: String {
        self.str(forKey: ValueKey.TestValue.rawValue)
    }
    
    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }
    
    private func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            ValueKey.LearningModeCountForFree.rawValue : 5,
            ValueKey.TestValue.rawValue : "Test"
        ]
        
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    private func fetchCloudValues() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 43200
        RemoteConfig.remoteConfig().configSettings = settings
        
#if DEBUG
        activateDebugMode()
#endif
        
        RemoteConfig.remoteConfig().fetch { [weak self] _, error in
            if let error = error {
                print("Remote config: произошла ошибка – \(error)")
                return
            }
            
            RemoteConfig.remoteConfig().activate { _, _ in
                print("Remote config: данные получены из firebase")
                self?.printInfo()
            }
            
            DispatchQueue.main.async {
                self?.loadingDoneCallback?()
            }
        }
    }
    
    // MARK: - Helper methods
    
    private func int(forKey key: String) -> Int {
        RemoteConfig.remoteConfig().configValue(forKey: key).numberValue.intValue
    }
    
    private func str(forKey key: String) -> String {
        RemoteConfig.remoteConfig().configValue(forKey: key).stringValue ?? "nil"
    }
    
    private func printInfo() {
        let allRemoteKeys = RemoteConfig.remoteConfig().allKeys(from: .remote)
        
        print("Remote config: полученные данные:")
        for (i, key) in allRemoteKeys.enumerated() {
            let value = RemoteConfig.remoteConfig().configValue(forKey: key)
            print("Remote config: \(i)) \(key) = \(value.stringValue ?? "nil")")
        }
    }
    
    private func activateDebugMode() {
        let settings = RemoteConfigSettings()
        // WARNING: Don't actually do this in production!
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
    }
}
