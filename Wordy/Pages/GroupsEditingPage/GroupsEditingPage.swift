//
//  GroupsEditingPage.swift
//  Wordy
//
//  Created by Vlad Sytnik on 28.04.2023.
//

import SwiftUI

struct GroupsEditingPage: View {
	
	@EnvironmentObject var themeManager: ThemeManager
	@Environment(\.dismiss) private var dismiss
	
	@State var showActivity = false
	@State var groups: [Group] = []
	@State var showAlert = false
	@State var alert = (title: "", description: "")
	@State var selectedGroup = Group()
	@State var showSheet = false
	@State var modules: [Module] = []
	@State var selectedIndexes: [Int] = []
	@State private var groupId = ""
	@State private var needUpdateData = false
	@State var showDeleteAlert = false
	
//	let test = [
//		"Хороший доктор",
//		"Эйфория",
//		"Черная весна",
//		"Группа для изучения английского языка а также для добавления различных слов",
//		"Мои слова"
//	]
	
	let cellHeight: CGFloat = 50
	
	var body: some View {
		ZStack {
			themeManager.currentTheme.mainBackgroundImage
				.resizable()
				.ignoresSafeArea()
			ScrollView {
				VStack(spacing: 20) {
//					HStack {
//						BackButton {
//							dismiss()
//						}
//						Spacer()
//					}
//					
//					HStack {
//						Text(LocalizedStringKey("Группы"))
//							.foregroundColor(themeManager.currentTheme.mainText)
//							.font(.system(size: 36, weight: .bold))
//							.multilineTextAlignment(.center)
//							.padding(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 0))
//						Spacer()
//					}
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 16)
					
					VStack {
						ForEach(groups, id: \.id) { group in
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
				}
			}
		}
		.showAlert(title: alert.title, description: alert.description, isPresented: $showAlert) {
			
		}
		.activity($showActivity)
//		.navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(LocalizedStringKey("Группы"))
		.onAppear {
			fetchModules()
			fetchGroups()
		}
		.onChange(of: needUpdateData) { _ in
			fetchModules()
			fetchGroups()
		}
		.sheet(isPresented: $showSheet) {
			ModuleSelectPage(
				modules: $modules,
				isOpened: $showSheet,
				groupId: $groupId,
				needUpdate: $needUpdateData,
				groups: $groups,
				isEditMode: .constant(true),
				selectedIndexes: $selectedIndexes
			)
		}
		.showAlert(title: "Вы действительно хотите удалить эту группу?", description: "Это действие нельзя будет отменить", isPresented: $showDeleteAlert, titleWithoutAction: "Отменить", titleForAction: "Удалить") {
			nowReallyNeedToDeleteModule()
		}
	}
	
	func nowReallyNeedToDeleteModule() {
		showActivity = true
		NetworkManager.deleteGroup(with: selectedGroup.id) {
			self.showActivity = false
			needUpdateData.toggle()
		} errorBlock: { errorText in
			self.alert.title = "Упс, произошла ошибка..."
			self.alert.description = errorText
			self.showActivity = false
			self.showAlert = true
		}
	}
	
	private func translateUuidies(_ uuidies: [String]) -> [Int] {
		var result: [Int] = []
		
		for uuid in uuidies {
			for (i, module) in modules.enumerated() {
				if module.id == uuid {
					result.append(i)
				}
			}
		}
		
		return result
	}
	
	private func fetchModules() {
		showActivity = true
		NetworkManager.getModules { modules in
			showActivity = false
			self.modules = modules
		} errorBlock: { errorText in
			showActivity = false
			guard !errorText.isEmpty else { return }
			showAlert(errorText: errorText)
		}
	}
	
	private func fetchGroups() {
		showActivity = true
		NetworkManager.getGroups { groups in
			showActivity = false
			self.groups = groups
		} errorBlock: { errorText in
			showActivity = false
			guard !errorText.isEmpty else { return }
			showAlert(errorText: errorText)
		}
	}
	
	private func showAlert(errorText: String) {
		withAnimation {
			showAlert.toggle()
		}
		alert.title = "Упс! Произошла ошибка"
		alert.description = errorText
	}
}

struct GroupsEditingPage_Previews: PreviewProvider {
    static var previews: some View {
        GroupsEditingPage()
    }
}
