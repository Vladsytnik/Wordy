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
	
    func generateCurrentDateMarker(withSecondOffset: Int? = nil) -> String {
		let dateFormatter = DateFormatter().getDateFormatter()
        var date = Date()
        if let second = withSecondOffset {
            date = Calendar.current.date(byAdding: .second, value: second, to: date) ?? Date()
        }
		let stringDate = dateFormatter.string(from: date)
		return stringDate
	}
	
	func generateCurrentDateMarkerInUTC0() -> String {
		let utcTimeZone = TimeZone(abbreviation: "UTC")
		
		let dateFormatter = DateFormatter().getDateFormatter()
		dateFormatter.timeZone = utcTimeZone
		let stringDate = dateFormatter.string(from: Date())
		return stringDate
	}
	
	func generateDateMarkerInUTC0(withHour hours: Int, and minutes: Int) -> String? {
		let utcTimeZone = TimeZone(abbreviation: "UTC")
		let calendar = Calendar.current
		
		let hour: Int = hours
		let minute: Int = minutes
		
		var dateComponents = DateComponents()
		dateComponents.hour = hour
		dateComponents.minute = minute
		
		let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
		
		let dateFormatter = DateFormatter().getDateFormatter()
		dateFormatter.timeZone = utcTimeZone
		
		guard let date else { return nil }
		
		let stringDate = dateFormatter.string(from: date)
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
    
    static var localizedCounter = 0
    static var localizedUniqs: [String: Int?] = [:]
    
    func localize() -> String {
        let localizedString = NSLocalizedString(self, comment: "")
        let string = String(format: localizedString, self)
        logLocalizedInfo(original: self, localizedString: string)
        return string
    }
    
    func localize(forLang langCode: String) -> String {
        let preferredLanguage = langCode
        let path = Bundle.main.path(forResource: preferredLanguage, ofType: "lproj")
        
        if let path = path, let bundle = Bundle(path: path) {
            let localizedString = NSLocalizedString(self, bundle: bundle, comment: "")
            let string = String(format: localizedString, self)
            logLocalizedInfo(original: self, localizedString: string)
            return string
        }

        // по дефолту возвращаем на англ
        return self.localize(forLang: "en")
    }
    
    func logLocalizedInfo(original: String, localizedString: String) {
        // работает корректно только когда айфон не на русском языке
        // лучше чтобы был не английский, и не русский
        if String.localizedCounter == 0 {
            print("lclzd: -- Фразы, проходящие через локализацию: -- ")
            String.localizedCounter+=1
        }
        
        let exceptionWords = [
            "Design",
            "Test PRO Subscription",
            "Wordy.app",
            "OK"
        ]
        
        if String.localizedUniqs[original] == nil {
            if localizedString == original && !exceptionWords.contains(where: { $0 == localizedString }) {
                // Локализация не найдена
                print("lclzd: NOT FOUND: \(original)")
            } else {
                print("lclzd: \(original)")
            }
            
            String.localizedUniqs[original] = 1
        }
    }
}

// MARK: - String Constants

extension String {
    static let KeychainServiceKey = "auth_token"
    static let KeychainAccountKey = "wordy"
}
