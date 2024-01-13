//
//  RewardManager.swift
//  Wordy
//
//  Created by user on 09.01.2024.
//

import SwiftUI

enum RewardType {
    case firstModule
}

class RewardManager: ObservableObject {
    
    @Published var showReward = false
    
    var rewardType: RewardType = .firstModule
    
    func showReward(ofType: RewardType) {
        showReward.toggle()
    }
    
}
