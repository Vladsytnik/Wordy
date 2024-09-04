//
//  ApiKeys.swift
//  Wordy
//
//  Created by user on 19.03.2024.
//

import Foundation

enum ApiKeys: String {
    case YandexKey = "Api-Key AQVN2DQb6-3emk_jJl-IMe7lLTmAxRBEDdH9vQu_"
    case AppHudKey = "app_6t9G2dfKPDzUt3jifCJdTPMLbaKCPr"
    case AppsFlyer = "axfubYMdYCtRH3aW6FZYUc"
    
    func value() -> String {
        return self.rawValue
    }
}
