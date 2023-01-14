//
//  UIApplication + hideKeyboard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 08.01.2023.
//

import UIKit

extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
