//
//  ErrorCodeManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 16.12.2022.
//

import Foundation

struct ErrorCodeManager {
	static func getDescription(code: Int) -> String {
		switch code {
		case 17008:
			return "некорректный формат введенных данных"
		case 17007:
			return "пользователь с таким логином уже существует"
		case 17026:
			return "пароль должен содержать больше 5 символов"
		case 17009:
			return "неверный пароль"
		case 17011:
			return "пользователя с таким логином не существует"
		case 17005:
			return "аккаунт удален или заблокирован"
		default:
			return "код ошибки – \(code)"
		}
	}
}
