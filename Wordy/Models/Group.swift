//
//  Group.swift
//  Wordy
//
//  Created by Vlad Sytnik on 28.03.2023.
//

import Foundation
import FirebaseDatabase

struct Group: Equatable, Codable {
	var name: String = ""
	var id: String = ""
	var modulesID: [String] = []
	var date: Date?
}

extension Group {
	static func parse(from snapshot: DataSnapshot) -> [Group]? {
		guard let data = (snapshot.value as? [String: [String: Any]]) else {
			return []
		}
		guard let dbGroupKeys = (snapshot.value as? [String: Any])?.keys else {
			return nil
		}
		
		var groups: [Group] = []
		
		for groupID in dbGroupKeys {
			var group = Group(name: (data[groupID]?["name"] as? String) ?? "nil",
								id: groupID)
			
			let date = Date().generateDate(from: data[groupID]?["date"] as? String)
			group.date = date
			
			if let modulesData = data[groupID]?["modulesID"] as? [String] {
				group.modulesID = modulesData
			}
			
			groups.append(group)
		}
		
		return groups
	}
}
