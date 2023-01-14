//
//  Date.swift
//  Wordy
//
//  Created by Vlad Sytnik on 14.01.2023.
//

import Foundation

extension Date {	
	static func generateCurrentDateMarker() -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .full
		dateFormatter.timeStyle = .full
		let stringDate = dateFormatter.string(from: Date())
		return dateFormatter.date(from: stringDate) ?? Date()
	}
	
	static func generateDate(from: String?) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .full
		dateFormatter.dateStyle = .full
		let date = dateFormatter.date(from: from ?? "")
		return date ?? Date()
	}
}
