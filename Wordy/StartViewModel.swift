//
//  StartViewModel.swift
//  Wordy
//
//  Created by user on 23.11.2023.
//

import SwiftUI

class StartViewModel: ObservableObject {
    
    @Published var showAlert = false
    @Published var alertText = ""
    
    func initData() {
        NetworkManager.networkDelegate = self
        
        print("Test init view model")
    }
    
}

extension StartViewModel: NetworkDelegate {
    func networkError(_ error: NetworkError) {
        DispatchQueue.main.async {
            switch error {
            case .turnedOff:
                self.alertText = "\nУпс, кажется, нет подключения к интернету"
                withAnimation {
                    self.showAlert.toggle()
                }
            }
        }
    }
}
