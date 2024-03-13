//
//  Array + Extensions.swift
//  Wordy
//
//  Created by user on 12.03.2024.
//

import Foundation

extension Array where Self == [Module] {
    func getRandomPhrases() -> [Phrase] {
        var result: [Phrase] = []
        
        for module in self.shuffled() {
            let phrases = module.phrases.shuffled()
            for phrase in phrases {
                result.append(phrase)
            }
        }
        
        return result
    }
}
