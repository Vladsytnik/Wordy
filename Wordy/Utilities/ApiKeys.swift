//
//  ApiKeys.swift
//  Wordy
//
//  Created by user on 19.03.2024.
//

import Foundation

enum ApiKeys: String {
    case YandexKey = ""
    
    func value() -> String {
        return self.rawValue
    }
}
