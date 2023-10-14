//
//  ExampleCreatingResponse.swift
//  Wordy
//
//  Created by user on 14.10.2023.
//

import Foundation

// MARK: - Welcome
struct ExampleCreatingResponse: Codable {
    let statusCode: Int
    let body: Body
}

// MARK: - Body
struct Body: Codable {
    let ok: Bool
    let text, source, target: String
    let translations: [String]
    let examples: [Example]
}

// MARK: - Example
struct Example: Codable {
    let id: Int
    let source, target: String
}
