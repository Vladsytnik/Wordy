//
//  DeeplinkManager.swift
//  Wordy
//
//  Created by Vlad Sytnik on 06.10.2023.
//

import Foundation
import Combine

enum DeeplinkType {
	case openModule(moduleID: String, userID: String)
	case none
	
	func getData() -> Any? {
		switch self {
		case .openModule(let moduleID, let userID):
			return (moduleID, userID)
		case .none:
			return nil
		}
	}
}

class DeeplinkManager: ObservableObject {
	
	@Published var currentType: DeeplinkType = .none
	@Published var isOpenModuleType = false
	
	private var cancelables = Set<AnyCancellable>()
	
	func wasOpened(url: URL) {
		if url.pathComponents.count == 3 {
			let userID = url.pathComponents[1]
			let moduleID = url.pathComponents[2]
			currentType = .openModule(moduleID: moduleID,
									  userID: userID)
		}
        
        if url.queryParameters?.count == 4,
            let parameters = url.queryParameters 
        {
            if let userID = parameters["deep_link_value"],
               let moduleID = parameters["deep_link_sub1"] 
            {
                currentType = .openModule(moduleID: moduleID,
                                          userID: userID)
            }
        }
        
		updateState()
	}
	
	func updateState() {
		$currentType
			.sink(receiveValue: { deeplinkType in
				if case .openModule(_, _) = self.currentType {
					self.isOpenModuleType = true
				} else {
					self.isOpenModuleType = false
				}
			})
			.store(in: &cancelables)
	}
	
}

// MARK: Extensions

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
