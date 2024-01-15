//
//  TimeIntervalViewModel.swift
//  Wordy
//
//  Created by user on 21.10.2023.
//

import SwiftUI
import Combine

class TimeIntervalViewModel: ObservableObject {
    
    @Published var notificationsIsOn = false
    
    @Published var startAngle: Double = 0
    @Published var toAngle: Double = 180
    
    @Published var startProgress: CGFloat = 0
    @Published var toProgress: CGFloat = 0.5
    
    @Published var strProgress = ""
    @Published var isAfter12 = true
    
    @Published var lastStartAngleVal = 0
    @Published var lastEndAngleVal = 0
    
    @Published var timeDifference = 0
    
    @Published var isNeedToOpenModulesSelectPage = false
    
    @Published var selectedModulesCount = 0
    
    @Published var countOfNotifications = 2
    @Published var selectedModulesIndexes: [Int] = []
    @Published var selectedModules: [Module] = []
    
    @Published var notificationCountIsWrong = false
    @Published var isNight = false
    
    @Published var inProgress = false
    @Published var modules: [Module] = []
    @Published var needToCloseScreen = false
    @Published var needAnimateChanges = false
    @Published var showPaywall = false
    
    @Published var showAlert = false
    @Published var alertText = ""
    
    private var startProgressDefault: Double = 0
    private var startAngleDefault: Double = 0
    private var toAngleDefault: Double = 180
    private var toProgressDefault: Double = 0.5
    private var timeDifferenceDefault = 6
    
    private var subscriptionManager = SubscriptionManager()
    
    var cancelations = Set<AnyCancellable>()
    
    var isFromDrag = false
    
    var isOnlyOneNotification: Bool {
        !isFromDrag && countOfNotifications == 1
    }
    var needToToggleToSingleNotification = false
    
    @Published var isShowAlert = false
    @Published var showSuccessSaved = false
    @Published var isSaveInfoToServerProgress = false
    @Published var needToDismissView = false
    
    private var isPrevOn = false
    
    @Published var notificationTimes: [Date] = []
    @Published var notificationAngles: [Double] = []
    
    @Published var forceUpdateView = 0
    
    @Published var fromDatePicker = Date()
    @Published var toDatePicker = Date()
    @Published var isShowDatePicker = false
    @Published var isShowEndDatePicker = false
    
    private func updateView() {
        self.forceUpdateView += 1
        self.forceUpdateView += 1
    }
    
    func initData() {
        selectedModules = []
        
        inProgress = true
        fetchModules {
            Task { @MainActor in
                do {
                    guard let notification = try await NetworkManager.getNotificationsInfo() 
                    else {
                        self.inProgress = false
                        return
                    }
                    self.selectedModulesIndexes = self.initSelectedIndexes(from: notification.selectedModulesIds)
                    self.selectedModulesCount = self.selectedModules.count
                    self.notificationsIsOn = notification.isOn
                    self.isNight = notification.isNight
                    self.initStartEndDates(from: notification)
                    self.inProgress = false
                    self.needAnimateChanges = true
                    self.countOfNotifications = notification.notificationCount
                    self.updateNotificationsDates()
                    self.updateView()
                } catch(let error) {
                    print("Error in viewModel -> get NotificationInfo: \(error)")
                    self.inProgress = false
                }
            }
        }
        
        DoOnce.called = false
//        setStartDate(hour: 12)
        updateTimeDifference()
        
        $timeDifference
            .sink { [weak self] timeDifference in
                guard let self else { return }
                if timeDifference < self.countOfNotifications && timeDifference > 0 {
                    self.countOfNotifications = timeDifference + 1
                }
                if timeDifference == 0 && self.isFromDrag && !self.needToToggleToSingleNotification {
                    self.isFromDrag = false
                    self.needToToggleToSingleNotification = true
                    self.countOfNotifications = 1
                }
            }
            .store(in: &cancelations)
        $countOfNotifications
            .sink { [weak self] value in
                guard let self else { return }
                if (value == 1 && !self.isFromDrag) || self.needToToggleToSingleNotification {
//                    self.timeDifferenceDefault = self.timeDifference
//                    self.toAngleDefault = self.toAngle
//                    self.toProgressDefault = self.toProgress
                    
                    self.toAngle = self.startAngle
                    self.toProgress = self.startProgress
                    self.timeDifference = 0
                } else {
                    if value == 2 && self.startAngle == self.toAngle {
                        if self.timeDifferenceDefault > 1 {
                            self.toAngle = self.toAngleDefault
                            self.toProgress = self.toProgressDefault
                            self.timeDifference = self.timeDifferenceDefault
                            self.startAngle = self.startAngleDefault
                            self.startProgress = self.startProgressDefault
                            self.isNight = false
                            self.needToToggleToSingleNotification = false
                        } else {
                            // если разница меньше 1 часа
                            self.setTwoNotificationsDefaultState()
                        }
                    }
                }
            }
            .store(in: &cancelations)
        $isNight
            .sink { value in
                self.updateTimeDifference()
                self.updateTimeDifference()
            }
            .store(in: &cancelations)
        $notificationsIsOn
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] isOn in
                guard let self else { return }
                print("tttttt: \(isOn)")
                if isOn && !self.subscriptionManager.userHasSubscription() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.notificationsIsOn = false
                    }
                    self.showPaywall = true
                }
                
                self.checkNotificationAuthorization { isAllow in
                    if !isAllow && !self.isShowAlert && isOn && !self.isPrevOn {
                        self.alertText = "\n Чтобы включить уведомления, необходимо дать к ним доступ в настройках".localize()
                        withAnimation {
                            self.isShowAlert = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.notificationsIsOn = false
                        }
                    }
                    self.isPrevOn = isOn
                }
            }
            .store(in: &cancelations)
        
        $isSaveInfoToServerProgress
            .dropFirst(1)
            .sink { [weak self] val in
                if !val {
                    self?.showSuccessSaved.toggle()
                }
            }
            .store(in: &cancelations)
        
        $showSuccessSaved
            .dropFirst(1)
            .sink { [weak self] val in
                if val {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self?.showSuccessSaved.toggle()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self?.needToDismissView.toggle()
                    }
                }
            }
            .store(in: &cancelations)
        
        $isShowDatePicker
            .dropFirst()
            .sink { [weak self] val in
                guard let self else { return }
                if !val {
                    self.setStartDate(self.fromDatePicker)
                }
            }
            .store(in: &cancelations)
        
        $isShowEndDatePicker
            .dropFirst()
            .sink { [weak self] val in
                guard let self else { return }
                if !val {
                    self.setEndDate(self.toDatePicker)
                }
            }
            .store(in: &cancelations)
        
        NetworkManager.networkDelegate = self
    }
    
    func setStartDate(_ date: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        self.setStartDate(hour: hour, minutes: minutes)
    }
    
    func setEndDate(_ date: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        self.setEndDate(hour: hour, minutes: minutes)
    }
    
    func checkNotificationAuthorization(isAllow: ((Bool) -> Void)?) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Доступ к уведомлениям разрешен")
                isAllow?(true)
            case .denied:
                print("Доступ к уведомлениям запрещен")
                isAllow?(false)
            case .notDetermined:
                print("Доступ к уведомлениям не определен")
                isAllow?(false)
            default:
                break
            }
        }
    }
    
    private func setStartDate(hour: Int = 8, minutes: Int = 0) {
        let calendar = Calendar.current

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())

        dateComponents.hour = hour
        dateComponents.minute = minutes // 13:37

        if let customDate = calendar.date(from: dateComponents) {
            let angle = getAngle(from: customDate)
            isAfter12 = hour >= 12
            
            self.startAngle = isNight ? angle + 360 : angle
            self.startProgress = angle / 360
            updateTimeDifference()
        } else {
            print("Невозможно создать объект Date setStartDate.")
        }
    }
    
    private func setEndDate(hour: Int = 10, minutes: Int = 0) {
        let calendar = Calendar.current

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())

        dateComponents.hour = hour
        dateComponents.minute = minutes // 13:37

        if let customDate = calendar.date(from: dateComponents) {
            let angle = getAngle(from: customDate)
            self.toAngle = angle
            self.toProgress = angle / 360
            updateTimeDifference()
        } else {
            print("Невозможно создать объект Date setEndDate.")
        }
    }
    
    func fetchModules(onCallback: (() -> Void)?) {
        NetworkManager.getModules { modules in
            self.modules = modules
            onCallback?()
        } errorBlock: { errorText in
            guard !errorText.isEmpty else { return }
            onCallback?()
        }
    }
    
    private func initSelectedIndexes(from selectedIds: [String]) -> [Int] {
        var result: [Int] = []
        
        for (i, module) in modules.enumerated() {
            if selectedIds.contains(where: { $0 == module.id }) {
                result.append(i)
                selectedModules.append(module)
            }
        }
        
        return result
    }
    
    private func initStartEndDates(from notification: Notification) {
        if let startDate = notification.dates.first {
            self.fromDatePicker = startDate
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: startDate)
            let minutes = calendar.component(.minute, from: startDate)
            self.setStartDate(hour: hour, minutes: minutes)
        }
        if let endDate = notification.dates.last {
            self.toDatePicker = endDate
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: endDate)
            let minutes = calendar.component(.minute, from: endDate)
            self.setEndDate(hour: hour, minutes: minutes)
        }
    }
    
    func setTwoNotificationsDefaultState() {
        self.startAngle = 0
        self.startProgress = 0
        
        self.toAngle = 180
        self.toProgress = 0.5
        
        self.timeDifference = 6
        self.isNight = false
        self.needToToggleToSingleNotification = false
    }
    
    private func updateTimeDifference() {
        timeDifference = getTimeDifference()
    }
    
    func onDrag(value: DragGesture.Value, fromSlider: Bool = false) {
        
        isFromDrag = true
        // Converting Translation Into Angle
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        // Removing the button radius
        // Button Diameter = 30 | radius = 15
        let radians = atan2(vector.dy - 15, vector.dx - 15)
        
        // Converting into Angle
        var angle = radians * 180 / .pi
        if angle < 0 {
            angle = 360 + angle
        }
        
        // Progress
        let progress = angle / 360
        
            
        
        if fromSlider {
            // Update From Values
//            if Int(angle) % 15 == 0 {
            self.startAngle = angle
            self.startProgress = progress
            strProgress = "\(Int(angle)) \(radians)"
            isAfter12 = radians >= 0
            if countOfNotifications == 1 {
                self.toAngle = angle
                self.toProgress = progress
            }
//            }
        } else {
            // Update To Values
            self.toAngle = angle
            self.toProgress = progress
        }
        
        timeDifference = getTimeDifference()
    }
    
    // Returning Time Based On Drag
    func getTime(angle: Double, isStartSlider: Bool = false) -> Date {
        
        // 360 / 12 = 30
        // 12 = Hours
        let progress = angle / 30
        
        // It will be 6.05
        // 6 is hour
        // 05 is minute
        
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        // Why is 12
        // Since we're going to update time for each 5 minutes not for each minute
        // 0.1 = 5 minute
        let hour = Int(progress)
        let reminder = (progress.truncatingRemainder(dividingBy: 1) * 12).rounded()
        
        let minute = (reminder * 5) < 60 ? (reminder * 5) : 55
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        if isStartSlider {
            var tempHour = isAfter12 ? hour + 12 : hour
            if isNight {
                tempHour += 12
            }
            components.hour = tempHour
        } else {
            if countOfNotifications == 1  {
                var tempHour = isAfter12 ? hour + 12 : hour
                if isNight {
                    tempHour += 12
                }
                components.hour = tempHour
            } else {
                components.hour = hour + 12
            }
        }
//        components.hour = hour + 12
//        components.hour = hour <= 0 ? hour + 12 : hour
//        components.hour = hour + 12
        components.minute = Int(minute)
        components.second = 0
        
        let calendarDate = calendar.date(from: components)
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "YYYY MM dd hh:mm:ss"
//
//        if let calendarDate {
//            let formattedTime = formatter.string(from: calendarDate)
//            return formatter.date(from: formattedTime) ?? Date()
//        }
        
        return calendarDate ?? Date()
    }
    
    func getAngle(from date: Date, isStartSlider: Bool = false) -> Double {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        // Calculate the angle based on the hour and minute
        let hourAngle = Double(hour % 12) * 30.0 // 360 degrees / 12 hours
        let minuteAngle = Double(minute) * 0.5 // 360 degrees / 60 minutes
        
        var angle = hourAngle + minuteAngle
        
        if isStartSlider {
            // If it's the start slider, adjust the angle accordingly
            angle -= 180.0
            if angle < 0 {
                angle += 360.0
            }
        }
        
        return angle
    }
    
    func getStringTime(angle: Double, isStartSlider: Bool = false) -> String {
        
        let date = getTime(angle: angle, isStartSlider: isStartSlider)
        
        let formatter = DateFormatter()
//        formatter.dateFormat = "hh:mm aa"
        
        formatter.timeStyle = .short
        let userLocale = Locale.current
        formatter.locale = userLocale
        
        return formatter.string(from: date)
    }
    
    func getTimeDifference() -> Int {
        let calendar = Calendar.current
        let result = calendar.dateComponents([.hour],
                                             from: getTime(angle: startAngle, isStartSlider: true),
                                             to: getTime(angle: toAngle))
        
        updateNotificationsDates()
        
        return result.hour ?? 0
    }
    
    func getStartHourValue() -> Int {
        let calendar = Calendar.current
        let result = calendar.dateComponents([.hour], from: getTime(angle: startAngle))
        return result.hour ?? 0
    }
    
    func getEndHourValue() -> Int {
        let calendar = Calendar.current
        let result = calendar.dateComponents([.hour], from: getTime(angle: toAngle))
        return result.hour ?? 0
    }
    
    func userDidSelectModules(_ selectedModules: [Module]) {
        // тут неправильное кол-во модулей возвращается
        self.selectedModules = selectedModules
//        updateNotificationInfo()
    }
    
    func userDidSelectModulesIndexes(_ indexes: [Int]) {
        selectedModulesIndexes = indexes
        selectedModulesCount = indexes.count
    }
    
    func userDidUpdateNotificationCount(_ count: Int) {
        
        if count > 0 {
            guard count <= timeDifference + 1 || (count == 2 && self.startProgress == self.toProgress) else {
                shakeTextField()
                return
            }
            isFromDrag = false
            needToToggleToSingleNotification = false
            countOfNotifications = count
//            updateNotificationInfo()
        }
        
        updateNotificationsDates()
    }
    
    private func shakeTextField() {
        let group = DispatchGroup()
        
        let workItem = DispatchWorkItem {
            withAnimation(.default.repeatCount(4, autoreverses: true).speed(6)) {
                self.notificationCountIsWrong = true
            }
            group.leave()
        }
        
        group.enter()
        DispatchQueue.main.async(execute: workItem)
        
        group.notify(queue: .main) {
            self.notificationCountIsWrong = false
        }
    }
    
    private func updateNotificationsDates() {
        let notificationDates = generateNotificationsDates()
        self.notificationTimes = notificationDates
        print("notificationTimes updated: \(notificationTimes)")
        convertToAngle(dates: self.notificationTimes)
    }
    
    private func convertToAngle(dates: [Date]) {
        notificationAngles = []
        
        for date in dates {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)

            dateComponents.hour = hour
            dateComponents.minute = minutes
            
            if let customDate = calendar.date(from: dateComponents) {
                let angle = getAngle(from: customDate) // тут возможно надо делить на 360 каждый угол
                notificationAngles.append(angle)
                print("notificationAngles updated: \(notificationAngles)")
                
    //            self.startAngle = angle
    //            self.startProgress = angle / 360
            } else {
                print("Ошибка в TimeIntervalViewModel -> convertToAngle")
            }
        }
    }
    
    private func updateNotificationInfo() {
        Task { @MainActor in
            inProgress = true
            isSaveInfoToServerProgress = true
            let resultPhrases = generateRandomPhrasesFromSelectedModules()
            let notificationDates = generateNotificationsDates()
            let notification = Notification(isOn: notificationsIsOn,
                                            isNight: isNight,
                                            dates: notificationDates,
                                            notificationCount: countOfNotifications,
                                            selectedModulesIds: selectedModules.map{ $0.id },
                                            phrases: resultPhrases)
            do {
                try await NetworkManager.updateNotificationsInfo(notification: notification)
                isSaveInfoToServerProgress = false
                inProgress = false
            } catch(let error) {
                print("Error in TimeIntervalViewModel -> updateNotificationInfo: \(error)")
                inProgress = false
                isSaveInfoToServerProgress = false
            }
        }
    }
    
    func save() {
        guard subscriptionManager.userHasSubscription() else {
            showPaywall.toggle()
            return
        }
        updateNotificationInfo()
    }
    
    private func generateNotificationsDates() -> [Date] {
        let stepHour = Double(timeDifference) / Double(countOfNotifications - 1)
        var resultDates: [Date] = []
        
        let startDate = getTime(angle: startAngle, isStartSlider: true)
        let endDate = getTime(angle: toAngle)
        
        if startDate != endDate {
            let df = DateFormatter()
            let startHour = df.calendar.dateComponents([.hour], from: startDate).hour ?? 0
            let endHour = df.calendar.dateComponents([.hour], from: endDate).hour ?? 0
            
            var tempEndDate = startDate
            resultDates.append(startDate)
            var stop = false
            
            while tempEndDate < endDate && !stop && stepHour > 0 && stepHour != .infinity {
//                print("TEST DATES: tempEndDate \(tempEndDate)")
//                print("TEST DATES: Step \(stepHour)")
                
                if let date = df.calendar.date(byAdding: .second, value: toSeconds(stepHour), to: tempEndDate) {
                    tempEndDate = date
                    if resultDates.count < countOfNotifications {
                        if resultDates.count == countOfNotifications - 1 && date != endDate {
                            resultDates.append(endDate)
                        } else {
                            resultDates.append(tempEndDate)
                        }
                    }
                } else {
                    stop = true
                }
            }
        } else {
            resultDates = [startDate]
        }
        
        print("TEST DATES: Notification Dates \(resultDates)")
        return resultDates
    }
    
    private func generateRandomPhrasesFromSelectedModules() -> [Phrase] {
        var result: [Phrase] = []
        
        for module in selectedModules.shuffled() {
            let phrases = module.phrases.shuffled()
            for phrase in phrases {
                result.append(phrase)
            }
        }
        
        return result
    }
    
    private func toSeconds(_ hour: Double) -> Int {
        if hour != .infinity {
            return Int(hour * 60 * 60)
        }
        return 0
    }
    
    func userIsClosingView() {
       
    }
    
    func reset() {
        countOfNotifications = 2
        setStartDate(hour: 12)
        setEndDate(hour: 6)
        updateTimeDifference()
        isNight = false
    }
}

// MARK: - NetworkDelegate

extension TimeIntervalViewModel: NetworkDelegate {
    func networkError(_ error: NetworkError) {
        switch error {
        case .turnedOff(let errorText):
            self.alertText = errorText
            withAnimation {
                self.showAlert.toggle()
            }
        }
    }
}

struct DoOnce { static var called = false }

