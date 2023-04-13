//
//  String.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import Foundation


extension String {
	
	func decodeCode() -> Int {
		var tempString = ""
		
		let findedSubstrings = matches(pattern: "Code=([0-9])+\\s", in: self)
		
		if let text = findedSubstrings.first {
			text.forEach {
				let str = String($0)
				if let _ = Int(str) {
					tempString += str
				}
			}
		}
	
		return tempString.isEmpty ? -1 : (Int(tempString) ?? -1)
	}
	
	func decodeDescription(_ inputText: String = "") -> String {
		return ErrorCodeManager.getDescription(code: decodeCode())
	}
	
	private func matches(pattern regex: String, in text: String) -> [String] {
		do {
			let regex = try NSRegularExpression(pattern: regex)
			let results = regex.matches(in: text,
										range: NSRange(text.startIndex..., in: text))
			return results.map {
				String(text[Range($0.range, in: text)!])
			}
		} catch let error {
			print("invalid regex: \(error.localizedDescription)")
			return []
		}
	}
	
	func generateCurrentDateMarker() -> String {
		let dateFormatter = DateFormatter().getDateFormatter()
		let stringDate = dateFormatter.string(from: Date())
		return stringDate
	}
	
	func generateDate(from: Date?) -> String {
		guard let from else { return "" }
		let dateFormatter = DateFormatter().getDateFormatter()
		let stringDate = dateFormatter.string(from: from)
		return stringDate
	}
}

extension String {
	func rangeOfWord(containing range: Range<String.Index>) -> Range<String.Index> {
		let start = range.lowerBound
		let end = range.upperBound
		var startOfWord = start
		while startOfWord > startIndex && !self[startOfWord].isWhitespace {
			startOfWord = index(before: startOfWord)
		}
		var endOfWord = end
		while endOfWord < endIndex && !self[endOfWord].isWhitespace {
			endOfWord = index(after: endOfWord)
		}
		return startOfWord..<endOfWord
	}
}
