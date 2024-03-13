//
//  GroupsEditingPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 28.04.2023.
//

import SwiftUI
import Pow

struct GroupsEditingPage: View {
    
    @EnvironmentObject var dataManager: DataManager
    
	@EnvironmentObject var themeManager: ThemeManager
//	@Environment(\.dismiss) private var dismiss
	
	@State var showActivity = false
	
	@State var showAlert = false
	@State var alert = (title: "", description: "")
	@State var selectedGroup = Group()
	@State var showSheet = false
	@State var selectedIndexes: [Int] = []
	@State private var groupId = ""
	@State private var needUpdateData = false
	@State var showDeleteAlert = false
	
	
	let cellHeight: CGFloat = 50
	
	var body: some View {
		ZStack {
			themeManager.currentTheme.mainBackgroundImage
				.resizable()
				.ignoresSafeArea()
            
			ScrollView {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 16)
                
				VStack(spacing: 20) {
                    HStack {
                        Text("Группы".localize())
                            .foregroundColor(themeManager.currentTheme.mainText)
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
					
					VStack {
                        ForEach(dataManager.groups, id: \.id) { group in
							HStack {
								HStack(alignment: .top, spacing: 12) {
									Image(systemName: "folder")
										.offset(y: 1)
										.foregroundColor(themeManager.currentTheme.mainText)
									Text(group.name)
										.font(.system(size: 16, weight: .regular))
										.foregroundColor(themeManager.currentTheme.mainText)
								}
								.padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
								
								Spacer()
								
								Button {
									print("delete")
									selectedGroup = group
									withAnimation {
										showDeleteAlert.toggle()
									}
								} label: {
									Image(systemName: "trash")
										.resizable()
										.foregroundColor(.red)
										.frame(width: 20, height: 20)
										.padding()
								}
							}
							.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
							.background {
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(themeManager.currentTheme.main)
							}
							.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
							.onTapGesture {
								groupId = group.id
								selectedIndexes = translateUuidies(group.modulesID)
								selectedGroup = group
								print(group.name)
								showSheet.toggle()
							}
                        }
					}
                    
                    if (dataManager.groups.count == 0) {
                        EmptyBGView()
                    }
				}
			}
		}
		.showAlert(title: alert.title, description: alert.description, isPresented: $showAlert) {
			
		}
		.activity($showActivity)
		.sheet(isPresented: $showSheet) {
			ModuleSelectPage(
                modules: $dataManager.allModules,
				isOpened: $showSheet,
				groupId: $groupId,
				needUpdate: $needUpdateData,
                groups: $dataManager.groups,
				isEditMode: .constant(true),
				selectedIndexes: $selectedIndexes
			)
		}
        .showAlert(title: "Вы действительно хотите удалить эту группу?", description: "\n" + "Это действие нельзя будет отменить".localize(), isPresented: $showDeleteAlert, titleWithoutAction: "Удалить", titleForAction: "Отменить", withoutButtons: false, okAction: { nowReallyNeedToDeleteGroup() }, repeatAction: {})
	}
	
	func nowReallyNeedToDeleteGroup() {
		showActivity = true
		NetworkManager.deleteGroup(with: selectedGroup.id, withoutUpdate: true) {
            withAnimation {
                dataManager.deleteGroup(selectedGroup.id)
            }
			self.showActivity = false
            showDeleteAlert.toggle()
		} errorBlock: { errorText in
            self.alert.title = "Упс, произошла ошибка...".localize()
			self.alert.description = errorText
			self.showActivity = false
			self.showAlert = true
		}
	}
	
	private func translateUuidies(_ uuidies: [String]) -> [Int] {
		var result: [Int] = []
		
		for uuid in uuidies {
            for (i, module) in dataManager.allModules.enumerated() {
				if module.id == uuid {
					result.append(i)
				}
			}
		}
		
		return result
	}
	
	private func showAlert(errorText: String) {
		withAnimation {
			showAlert.toggle()
		}
        alert.title = "Упс! Произошла ошибка".localize()
		alert.description = errorText
	}
}

struct GroupsEditingPage_Previews: PreviewProvider {
    static var previews: some View {
        GroupsEditingPage()
            .environmentObject(DataManager.shared)
            .environmentObject(ThemeManager())
    }
}
