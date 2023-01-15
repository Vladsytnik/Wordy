//
//  DateFormatter.swift
//  Wordy
//
//  Created by Vlad Sytnik on 15.01.2023.
//

import Foundation

extension DateFormatter {
	func getDateFormatter() -> DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yy HH:mm:ss.SSS"
//		dateFormatter.dateStyle = .full
//		dateFormatter.timeStyle = .full
		return dateFormatter
	}
}
