//
//  Notification.swift
//  Wordy
//
//  Created by user on 16.11.2023.
//

import Foundation

struct Notification: Codable {
    var isOn: Bool
    let isNight: Bool
    let dates: [Date]
    let notificationCount: Int
    var selectedModulesIds: [String]
    let phrases: [Phrase]
}
