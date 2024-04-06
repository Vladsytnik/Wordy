//
//  DataManager.swift
//  Wordy
//
//  Created by user on 24.02.2024.
//

import SwiftUI

final class DataManager: ObservableObject {
    
    static let shared = DataManager()
    
    @Published var modules: [Module] = []
    @Published var groups: [Group] = []
    @Published var isLoading = false
    @Published var selectedCategoryIndex = -1
    
    @Published var allModules: [Module] = [] {
        didSet {
            applyFilterText()
        }
    }
    
    @Published private var allGroups: [Group] = []
    
    @Published var isMockData = false
    private var networkProcesses: [Int] = []
    private var filterText = ""
    
    @Published var isInitialized = false
    @Published var startLoadingAnimation = false
    
    var onLoadingPageUpdate: (() -> Void)?
    
    private let dispatchGroup = DispatchGroup()
    
    private init() {
        loadFromServer()
    }
    
    func filter(withText text: String) {
        filterText = text
        applyFilterText()
    }
    
    func addToSelectedGroupModuleId(_ id: String) {
        self.objectWillChange.send()
        groups[selectedCategoryIndex].modulesID.append(id)
    }
    
    func applyFilterText() {
        let isSelectedSomeGroup = selectedCategoryIndex >= 0
        let isFiltering = filterText.count > 0
        let allModulesTemp = isMockData ? MockDataManager().modules : allModules
        
        if isSelectedSomeGroup && isFiltering {
            guard selectedCategoryIndex < groups.count else { return }
            let selectedGroup = groups[selectedCategoryIndex]
            modules = allModulesTemp.filter{
                selectedGroup.modulesID.contains($0.id)
                && $0.name.contains(filterText)
            }
        } else if isFiltering {
            modules = allModulesTemp.filter{ $0.name.contains(filterText) }
        } else if isSelectedSomeGroup {
            guard selectedCategoryIndex < groups.count else { return }
            let selectedGroup = groups[selectedCategoryIndex]
            modules = allModulesTemp.filter{ selectedGroup.modulesID.contains($0.id) }
        } else {
            modules = allModulesTemp
        }
    }
    
    func sortAllModules() {
        allModules.sort(by: { $0.date ?? Date() > $1.date ?? Date() })
    }
    
    // MARK: - Modules Manipulations
    
    func addModule(_ module: Module) {
        allModules.append(module)
        sortAllModules()
    }
    
    func deleteModule(withId moduleId: String) {
        allModules.removeAll(where: { $0.id == moduleId })
        sortAllModules()
    }
    
    func replaceModule(_ module: Module) {
        let findedModuleIndex = allModules.firstIndex(where: { $0.id == module.id }).map{ Int($0) }
        if let findedModuleIndex {
            allModules.remove(at: findedModuleIndex)
            var tempModule = module
            tempModule.phrases.sort(by: AppConstants.phrasesSortingValue)
            allModules.append(tempModule)
            sortAllModules()
        }
    }
    
    // вызывать после того как обновили notification объект
    func updateModulesStates(from notification: Notification) {
        Task.detached(priority: .userInitiated) { [allModules] in
            let moduleIds = notification.selectedModulesIds
            var tempAllModules: [Module] = []
            
            for module in allModules {
                var tempModule = module
                tempModule.isNotificationTurnedOn = moduleIds.contains(module.id)
                tempAllModules.append(tempModule)
            }
        
            Task { @MainActor [tempAllModules] in
                self.allModules = tempAllModules
            }
        }
    }
    
    func deselectAllModules() {
        allModules.indices.forEach { allModules[$0].isSelected = false }
    }
    
    func selectModule(withId moduleId: String) {
        let findedModuleIndex = allModules.firstIndex(where: { $0.id == moduleId }).map{ Int($0) }

        if let findedModuleIndex {
            allModules[findedModuleIndex].isSelected.toggle()
        }
    }
    
    func delete(modules modulesForDeletion: [Module]) {
        let modulesIds = modulesForDeletion.map { $0.id }
        allModules.removeAll(where: { modulesIds.contains($0.id) })
    }
    
    func resetNotificationState(for moduleId: String) {
        let findedModuleIndex = allModules.firstIndex(where: { $0.id == moduleId }).map{ Int($0) }
        let findedModuleIndex2 = modules.firstIndex(where: { $0.id == moduleId }).map{ Int($0) }
        if let findedModuleIndex {
            var module = allModules[findedModuleIndex]
            module.isNotificationTurnedOn = false
            replaceModule(module)
        }
        if let findedModuleIndex2 {
            var module = modules[findedModuleIndex2]
            modules[findedModuleIndex2].isNotificationTurnedOn = false
            replaceModule(module)
        }
    }
    
//    func addPhrase(_ phrase: Phrase, toModuleWithId moduleId: String) {
//        let findedModule = allModules.first(where: { $0.id == moduleId })
//        if var findedModule {
//            var temp = findedModule
//            temp.phrases.append(phrase)
//            let test1 = temp.phrases
//            temp.phrases.sort(by: AppConstants.phrasesSortingValue)
//            let test2 = temp.phrases
////            findedModule.phrases.append(phrase)
//            findedModule = temp
//        }
//    }
    
    func addNewGroup(_ group: Group) {
//        groups.append(group)
//        allGroups.append(group)
        sortGroups()
    }
    
    func replaceGroup(with changedGroup: Group, withNilDate: Bool = false) {
        let findedGroupIndex = allGroups.firstIndex(where: { $0.id == changedGroup.id || ($0.date == nil && withNilDate == true) }).map{ Int($0) }
        let findedGroupIndex2 = groups.firstIndex(where: { $0.id == changedGroup.id || ($0.date == nil && withNilDate == true) }).map{ Int($0) }

        if let findedGroupIndex {
            allGroups.remove(at: findedGroupIndex)
            allGroups.append(changedGroup)
        } else {
            allGroups.append(changedGroup)
        }
        if let findedGroupIndex2 {
            groups.remove(at: findedGroupIndex2)
            groups.append(changedGroup)
        } else {
            groups.append(changedGroup)
        }
        sortGroups()
    }
    
    func deleteGroup(_ groupId: String) {
        var index: Int?
        
        for (i, group) in groups.enumerated() {
            if group.id == groupId {
                index = i
                break;
            }
        }
        
        if let index {
            var tempGroups = Array(groups)
            _ = tempGroups.remove(at: index)
            allGroups = tempGroups
            groups = tempGroups
            sortGroups()
        }
    }
    
    func sortGroups() {
        groups.sort(by: AppConstants.groupsSortingValue)
        allGroups.sort(by: AppConstants.groupsSortingValue)
    }
    
    func deletePhrase(withId phraseId: String, inModuleWithId moduleId: String) {
        var index: Int?
        var moduleIndex: Int?
        
        for (i, module) in allModules.enumerated() {
            if module.id == moduleId {
                for (j, phrase) in module.phrases.enumerated() {
                    if phrase.id == phraseId {
                        index = j
                        moduleIndex = i
                        break;
                    }
                }
            }
        }
        
        if let index, let moduleIndex {
            var tempModules = Array(allModules)
            _ = tempModules[moduleIndex].phrases.remove(at: index)
            allModules = tempModules
        }
        
//        let findedModule = allModules.first(where: { $0.id == moduleId })
//        if var findedModule {
//            var temp = findedModule
//            temp.phrases.removeAll(where: { $0.id == phraseId })
////            findedModule.phrases.append(phrase)
//            findedModule = temp
//        }
    }
    
    // MARK: - Loading And Set Data
 
    func forceLoadFromServer() {
        loadFromServer()
    }
    
    private func loadFromServer() {
        dispatchGroup.notify(queue: DispatchQueue.global()) { [weak self] in
            print("loading page test: загрузка данных закончилась")
            DispatchQueue.main.async {
                self?.isInitialized = true
                self?.onLoadingPageUpdate?()
                print("loading page test: isInitialized = \(self?.isInitialized)")
            }
        }
        print("loading page test: loadFromServer")
        loadModules()
        loadGroups()
    }
    
    private func loadModules() {
        dispatchGroup.enter()
        addLoadingProcess()
        NetworkManager.getModules { modules in
            Task { @MainActor in
                self.deleteLoadingProcess()
                self.leaveAsyncGroup()
                guard !self.isMockData else { return }
                self.modules = modules
                self.allModules = modules
                self.applyFilterText()
                print("loading page test: загрузились модули")
            }
        } errorBlock: { [weak self] errorText in
            print("loading page test: ошибка модулей")
            self?.deleteLoadingProcess()
            self?.leaveAsyncGroup()
            guard !errorText.isEmpty else { return }
        }
    }
    
    private func loadGroups() {
        dispatchGroup.enter()
        addLoadingProcess()
        NetworkManager.getGroups { groups in
            Task { @MainActor in
                self.deleteLoadingProcess()
                self.leaveAsyncGroup()
                print("loading page test: загрузились группы")
                guard !self.isMockData else { return }
                self.groups = groups
                self.allGroups = groups
            }
        } errorBlock: { [weak self] errorText in
            print("loading page test: ошибка групп")
            self?.deleteLoadingProcess()
            self?.leaveAsyncGroup()
            guard !errorText.isEmpty else { return }
        }
    }
    
    private func leaveAsyncGroup() {
        self.dispatchGroup.leave()
    }
    
    private func addLoadingProcess() {
        networkProcesses.append(0)
        updateLoadingState()
    }
    
    private func deleteLoadingProcess() {
        networkProcesses.removeLast()
        updateLoadingState()
    }
    
    private func updateLoadingState() {
        Task { @MainActor in
            isLoading = networkProcesses.count > 0
            print("loading page test: isLoading = \(isLoading)")
            if !isLoading {
                self.onLoadingPageUpdate?()
            }
        }
    }
    
    func setMockData() {
        Task { @MainActor in
            isMockData = true
            modules = MockDataManager().modules
//            allModules = MockDataManager().modules
            groups = MockDataManager().groups
//            allGroups = MockDataManager().groups
        }
    }
    
    func setRealData() {
        if isMockData {
            selectedCategoryIndex = -1
        }
        
        guard filterText.count == 0 else { return }
        Task { @MainActor in
            isMockData = false
            modules = allModules
            groups = allGroups
            applyFilterText()
        }
    }
    
    func clearFilters() {
        modules = allModules
    }
}
