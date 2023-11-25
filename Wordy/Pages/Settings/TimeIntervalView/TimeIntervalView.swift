//
//  TimeIntervalView.swift
//  Wordy
//
//  Created by user on 21.10.2023.
//

import SwiftUI

class EvilStateObject: ObservableObject {
    var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { _ in
            if Int.random(in: 1...5) == 1 {
                self.objectWillChange.send()
            }
        }
    }
}



struct TimeIntervalView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = TimeIntervalViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var sucessGenerator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .soft)
    
    
    var body: some View {
       
        GeometryReader { geo in
            if UIScreen.main.bounds.height >= 812 {
                VStack(alignment: .center) {
                    
                    Spacer()
                    
                    // MARK: – From & To
                    
                    HStack(spacing: 25) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                title: { Text("From") },
                                icon: { Image(systemName: "bell.fill") }
                            )
                            .font(.callout)
                            
                            Text("\(viewModel.getStringTime(angle: viewModel.startAngle, isStartSlider: true))")
                                .font(.title2.bold())
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                title: {  Text("To") },
                                icon: { Image(systemName: "bell.slash.fill") }
                            )
                            .font(.callout)
                            
                            Text("\(viewModel.getStringTime(angle: viewModel.toAngle))")
                                .font(.title2.bold())
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .foregroundColor(themeManager.currentTheme.mainText)
                    .padding()
                    .background(themeManager.currentTheme.mainText.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .padding()
                    
                    Spacer()
                    
                    // MARK: – Clock Slider
                    
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(themeManager.currentTheme.main.opacity(0.1))
                                .frame(width: geo.size.width / 1.5,
                                       height: geo.size.width / 1.5)
                                .shadow(radius: 40)
                            
                            TimeSlider(diameter: (geo.size.width / 1.5) - Double(40))
                                .frame(width: geo.size.width / 1.5,
                                       height: geo.size.width / 1.5)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    
                    // MARK: - Buttons
                    
                    let spaceBetweenButtons: CGFloat = 8
                    let cornerRadius: CGFloat = 18
                    let bgColor = themeManager.currentTheme.isDark ?
                    ((themeManager.currentTheme.id == "MainColor" && colorScheme == .dark) ? themeManager.currentTheme.mainGray : themeManager.currentTheme.moduleCardRoundedAreaColor) :
                    themeManager.currentTheme.moduleCardRoundedAreaColor
                    let blurEffect = VisualEffectView(effect: UIBlurEffect(style: .regular))
                    let bgOpacity: Double = 1
                    
                    //MARK: Status
                    
                    VStack(spacing: 0) {
                        HStack {
                            Toggle("Notifications",
                                   isOn: $viewModel.notificationsIsOn)
                            .toggleStyle(.switch)
                            .padding(.horizontal)
                            .padding(EdgeInsets(top: 12, leading: 0, bottom: 6, trailing: 0))
                            .foregroundColor(themeManager.currentTheme.mainText)
                        }
                        .background {
                            Rectangle().cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                                .foregroundColor(bgColor)
                                .opacity(bgOpacity)
                        }
                        .padding(.horizontal)
                        .onTapGesture {
                            //                        viewModel.notificationsIsOn.toggle()
                        }
                        
                        //MARK: Count
                        
                        VStack {
                            Divider()
                            HStack {
                                HStack(spacing: spaceBetweenButtons) {
                                    Text("Count per day:  ")
                                        .foregroundColor(themeManager.currentTheme.mainText)
                                    Text("\(viewModel.countOfNotifications)")
                                        .offset(x: !viewModel.notificationCountIsWrong ? 0 : 3)
                                        .font(.title3)
                                        .foregroundColor(themeManager.currentTheme.mainText)
                                }
                                Spacer()
                                
                                
                                
                                HStack {
                                    Button {
                                        //                                    viewModel.countOfNotifications = viewModel.countOfNotifications > 0 ? viewModel.countOfNotifications - 1 : 0
                                        viewModel.userDidUpdateNotificationCount(viewModel.countOfNotifications - 1)
                                    } label: {
                                        Text("–")
                                            .foregroundColor(themeManager.currentTheme.mainText)
                                            .bold()
                                            .padding(.trailing)
                                            .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                                    }
                                    
                                    Rectangle()
                                        .frame(width: 0.5)
                                        .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                                        .foregroundColor(.secondary)
                                    
                                    Button {
                                        //                                    viewModel.countOfNotifications += 1
                                        viewModel.userDidUpdateNotificationCount(viewModel.countOfNotifications + 1)
                                    } label: {
                                        Text("+")
                                            .foregroundColor(themeManager.currentTheme.mainText)
                                            .bold()
                                            .padding(.leading)
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12))
                                    }
                                }
                                .frame(height: 25)
                                .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(lineWidth: 0.4)
                                        .foregroundColor(.black.opacity(0.2))
                                        .shadow(radius: 4)
                                }
                            }
                            
                            Divider()
                        }
                        .padding(.horizontal)
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        .background {
                            Rectangle().cornerRadius(cornerRadius, corners: [])
                                .foregroundColor(bgColor)
                                .opacity(bgOpacity)
                        }
                        .padding(.horizontal)
                        
                        //MARK: Modules
                        
                        HStack {
                            HStack(spacing: spaceBetweenButtons) {
                                Text("Modules: ")
                                Text("\(viewModel.selectedModulesCount)")
                                    .font(.title3)
                            }
                            .padding(.horizontal)
                            .foregroundColor(themeManager.currentTheme.mainText)
                            
                            Spacer()
                            
                            HStack(spacing: 0) {
                                Button {
                                    viewModel.isNeedToOpenModulesSelectPage = true
                                } label: {
                                    Text("SELECT")
                                        .foregroundColor(themeManager.currentTheme.mainText)
                                        .padding(.horizontal)
                                }
                            }
                            .frame(height: 25)
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .background {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(lineWidth: 0.4)
                                    .foregroundColor(.black.opacity(0.2))
                                    .shadow(radius: 4)
                            }
                            .padding(.trailing)
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 12, trailing: 0))
                        .background {
                            Rectangle().cornerRadius(cornerRadius, corners: [.bottomLeft, .bottomRight])
                                .foregroundColor(bgColor)
                                .opacity(bgOpacity)
                        }
                        .padding(.horizontal)
                        .onTapGesture {  }
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(alignment: .center) {
                        
                        Spacer()
                        
                        // MARK: – From & To
                        
                        HStack(spacing: 25) {
                            VStack(alignment: .leading, spacing: 8) {
                                Label(
                                    title: { Text("From") },
                                    icon: { Image(systemName: "bell.fill") }
                                )
                                .font(.callout)
                                
                                Text("\(viewModel.getStringTime(angle: viewModel.startAngle, isStartSlider: true))")
                                    .font(.title2.bold())
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label(
                                    title: {  Text("To") },
                                    icon: { Image(systemName: "bell.slash.fill") }
                                )
                                .font(.callout)
                                
                                Text("\(viewModel.getStringTime(angle: viewModel.toAngle))")
                                    .font(.title2.bold())
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .padding()
                        .background(themeManager.currentTheme.mainText.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .padding()
                        
                        Spacer()
                        
                        // MARK: – Clock Slider
                        
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(themeManager.currentTheme.main.opacity(0.1))
                                    .frame(width: geo.size.width / 1.5,
                                           height: geo.size.width / 1.5)
                                    .shadow(radius: 40)
                                
                                TimeSlider(diameter: (geo.size.width / 1.5) - Double(40))
                                    .frame(width: geo.size.width / 1.5,
                                           height: geo.size.width / 1.5)
                            }
                            Spacer()
                        }
                        .padding()
                        
                        Spacer()
                        
                        // MARK: - Buttons
                        
                        let spaceBetweenButtons: CGFloat = 8
                        let cornerRadius: CGFloat = 18
                        let bgColor = themeManager.currentTheme.isDark ?
                        ((themeManager.currentTheme.id == "MainColor" && colorScheme == .dark) ? themeManager.currentTheme.mainGray : themeManager.currentTheme.moduleCardRoundedAreaColor) :
                        themeManager.currentTheme.moduleCardRoundedAreaColor
                        let blurEffect = VisualEffectView(effect: UIBlurEffect(style: .regular))
                        let bgOpacity: Double = 1
                        
                        //MARK: Status
                        
                        VStack(spacing: 0) {
                            HStack {
                                Toggle("Notifications",
                                       isOn: $viewModel.notificationsIsOn)
                                .toggleStyle(.switch)
                                .padding(.horizontal)
                                .padding(EdgeInsets(top: 12, leading: 0, bottom: 6, trailing: 0))
                                .foregroundColor(themeManager.currentTheme.mainText)
                            }
                            .background {
                                Rectangle().cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                                    .foregroundColor(bgColor)
                                    .opacity(bgOpacity)
                            }
                            .padding(.horizontal)
                            .onTapGesture {
                                //                        viewModel.notificationsIsOn.toggle()
                            }
                            
                            //MARK: Count
                            
                            VStack {
                                Divider()
                                HStack {
                                    HStack(spacing: spaceBetweenButtons) {
                                        Text("Count per day:  ")
                                            .foregroundColor(themeManager.currentTheme.mainText)
                                        Text("\(viewModel.countOfNotifications)")
                                            .offset(x: !viewModel.notificationCountIsWrong ? 0 : 3)
                                            .font(.title3)
                                            .foregroundColor(themeManager.currentTheme.mainText)
                                    }
                                    Spacer()
                                    
                                    
                                    
                                    HStack {
                                        Button {
                                            //                                    viewModel.countOfNotifications = viewModel.countOfNotifications > 0 ? viewModel.countOfNotifications - 1 : 0
                                            viewModel.userDidUpdateNotificationCount(viewModel.countOfNotifications - 1)
                                        } label: {
                                            Text("–")
                                                .foregroundColor(themeManager.currentTheme.mainText)
                                                .bold()
                                                .padding(.trailing)
                                                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                                        }
                                        
                                        Rectangle()
                                            .frame(width: 0.5)
                                            .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                                            .foregroundColor(.secondary)
                                        
                                        Button {
                                            //                                    viewModel.countOfNotifications += 1
                                            viewModel.userDidUpdateNotificationCount(viewModel.countOfNotifications + 1)
                                        } label: {
                                            Text("+")
                                                .foregroundColor(themeManager.currentTheme.mainText)
                                                .bold()
                                                .padding(.leading)
                                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12))
                                        }
                                    }
                                    .frame(height: 25)
                                    .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                    .background {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(lineWidth: 0.4)
                                            .foregroundColor(.black.opacity(0.2))
                                            .shadow(radius: 4)
                                    }
                                }
                                
                                Divider()
                            }
                            .padding(.horizontal)
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .background {
                                Rectangle().cornerRadius(cornerRadius, corners: [])
                                    .foregroundColor(bgColor)
                                    .opacity(bgOpacity)
                            }
                            .padding(.horizontal)
                            
                            //MARK: Modules
                            
                            HStack {
                                HStack(spacing: spaceBetweenButtons) {
                                    Text("Modules: ")
                                    Text("\(viewModel.selectedModulesCount)")
                                        .font(.title3)
                                }
                                .padding(.horizontal)
                                .foregroundColor(themeManager.currentTheme.mainText)
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Button {
                                        viewModel.isNeedToOpenModulesSelectPage = true
                                    } label: {
                                        Text("SELECT")
                                            .foregroundColor(themeManager.currentTheme.mainText)
                                            .padding(.horizontal)
                                    }
                                }
                                .frame(height: 25)
                                .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(lineWidth: 0.4)
                                        .foregroundColor(.black.opacity(0.2))
                                        .shadow(radius: 4)
                                }
                                .padding(.trailing)
                            }
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 12, trailing: 0))
                            .background {
                                Rectangle().cornerRadius(cornerRadius, corners: [.bottomLeft, .bottomRight])
                                    .foregroundColor(bgColor)
                                    .opacity(bgOpacity)
                            }
                            .padding(.horizontal)
                            .onTapGesture {  }
                        }
                        Spacer()
                    }
                }
            }
        }
        .activity($viewModel.inProgress)
        .onDisappear {
            viewModel.userIsClosingView()
        }
        .background {
            BackgroundView()
                .ignoresSafeArea()
        }
        .navigationTitle("Notifications")
        .onAppear {
            viewModel.initData()
        }
        .sheet(isPresented: $viewModel.isNeedToOpenModulesSelectPage, content: {
            ModuleSelectPage(
                modules: $viewModel.modules,
                isOpened: $viewModel.isNeedToOpenModulesSelectPage,
                groupId: .constant("0"),
                needUpdate: .constant(false),
                groups: .constant([]),
                isEditMode: .constant(false),
                selectedIndexes: $viewModel.selectedModulesIndexes,
                isJustNeedToReturnSelectedModules: true,
                onReturnSelectedModules: { self.viewModel.userDidSelectModules($0) },
                onReturnSelectedIndexes: { self.viewModel.userDidSelectModulesIndexes($0) }
            )
        })
        .navigationBarItems(
            trailing:
                Button(action: {
                    viewModel.save()
                }) {
                    Text("Save")
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .underline()
                        .bold()
                }
        )
        .sheet(isPresented: $viewModel.showPaywall, content: {
            Paywall(isOpened: $viewModel.showPaywall)
        })
        .showAlert(title: "Wordy.app", description: viewModel.alertText, isPresented: $viewModel.showAlert, withoutButtons: true, repeatAction: {})
    }
    
    //MARK: – Time Slider
    
    @ViewBuilder
    func TimeSlider(diameter: Double) -> some View {
            let width = diameter
            
            VStack {
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    ZStack {
                        
                        //MARK:  Clock Design
                        
                        ZStack {
                            ForEach(1...60, id: \.self) { index in
                                Rectangle()
                                    .fill(index % 5 == 0 ? themeManager.currentTheme.mainText : themeManager.currentTheme.mainText.opacity(0.7))
                                    .frame(width: 2, height: index % 5 == 0 ? 10 : 5)
                                    .offset(y: (width / 2) - 30)
                                    .rotationEffect(.degrees(Double(index) * 6))
                            }
                            
                            // Clock Text
                            let text = [6, 9, 12, 3]
                            ForEach(text.indices, id: \.self) { index in
                                Text("\(text[index])")
                                    .font(.caption.bold())
                                    .rotationEffect(.degrees(Double(index) * -90))
                                    .offset(y: (width / 2) - 50)
                                // 360 / 4 = 90
                                    .rotationEffect(.degrees(Double(index) * 90))
                                    .foregroundColor(themeManager.currentTheme.mainText)
                            }
                        }
                        
                        Circle()
                            .stroke(themeManager.currentTheme.mainText.opacity(0.06), lineWidth: 40)
                        
                        // Allowing reverse swiping
                        let reverseRotation = (viewModel.startProgress > viewModel.toProgress) ? -Double((1 - viewModel.startProgress) * 360) : 0
                        
                        Circle()
//                            .trim(from: viewModel.startProgress > viewModel.toProgress ? 0 : viewModel.startProgress,
//                                  to: viewModel.toProgress + (-reverseRotation / 360))
                            .trim(from: viewModel.startProgress > viewModel.toProgress ? 0 : viewModel.timeDifference >= 12 ? 0 : viewModel.startProgress,
                                  to: viewModel.timeDifference >= 12 ? 1 : viewModel.toProgress + (-reverseRotation / 360))
                            .stroke(LinearGradient(colors: [
                                themeManager.currentTheme.accent.opacity(0.8),
                                themeManager.currentTheme.main.opacity(0.7)
                            ],
                                                   startPoint: .trailing,
                                                   endPoint: .leading),
                                    style: StrokeStyle(lineWidth: 40,
                                                       lineCap: .round,
                                                       lineJoin: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .rotationEffect(.degrees(reverseRotation))
//                            .animation(.spring(), value: viewModel.needAnimateChanges)
                        
                        if viewModel.timeDifference >= 12 {
                            Circle()
                                .trim(from: viewModel.startProgress,
                                      to: viewModel.toProgress + (-reverseRotation / 360))
                                .stroke(LinearGradient(colors: [
                                    themeManager.currentTheme.accent.opacity(1),
                                    themeManager.currentTheme.main.opacity(0.7)
                                ],
                                                       startPoint: .trailing,
                                                       endPoint: .leading),
                                        style: StrokeStyle(lineWidth: 40,
                                                           lineCap: .round,
                                                           lineJoin: .round)
                                )
                                .rotationEffect(.degrees(-90))
                        }
                        
                        // Slider buttons
                        
                        Image(systemName: "bell.fill")
                            .font(.callout)
                            .foregroundColor(themeManager.currentTheme.accent)
                            .frame(width: 30, height: 30)
                            .rotationEffect(.degrees(90))
                            .rotationEffect(.degrees(-viewModel.startAngle))
                            .background(.white , in: Circle())
                            .zIndex(5)
                        // Moving to right and rotation
                            .offset(x: width / 2)
                            .rotationEffect(.degrees(viewModel.startAngle))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        viewModel.onDrag(value: value, fromSlider: true)
                                    }
                            )
                            .rotationEffect(.degrees(-90))
                            .onTapGesture {
                                if viewModel.countOfNotifications == 1 {
                                    viewModel.countOfNotifications = 2
                                    viewModel.setTwoNotificationsDefaultState()
                                }
                            }
                        
                        Image(systemName: "bell.slash.fill")
                            .font(.callout)
                            .foregroundColor(themeManager.currentTheme.accent)
                            .frame(width: 30, height: 30)
                            .rotationEffect(.degrees(90))
                            .rotationEffect(.degrees(-viewModel.toAngle))
                            .background(.white , in: Circle())
                        // Moving to right and rotation
                            .offset(x: width / 2)
                            .rotationEffect(.degrees(viewModel.toAngle))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        viewModel.onDrag(value: value)
                                    }
                            )
                            .rotationEffect(.degrees(-90))
                        
                        //MARK: Hour Text
                        if !viewModel.isOnlyOneNotification
                            && viewModel.startAngle != viewModel.toAngle {
                            VStack(spacing: 8) {
                                Text("\(viewModel.timeDifference) hr")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(themeManager.currentTheme.mainText)
                                Button {
                                    viewModel.reset()
                                } label: {
                                    Text("Reset")
                                        .foregroundColor(themeManager.currentTheme.mainText)
                                }
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(viewModel.isNight ? themeManager.currentTheme.accent : themeManager.currentTheme.mainGray)
                                    .shadow(color: .white.opacity(viewModel.isNight ? 0 : 0.3), radius: 5)
                                    .animation(.spring(), value: viewModel.isNight)
//                                Toggle("+12", isOn: $viewModel.toEvening)
//                                    .toggleStyle(.button)
//                                    .foregroundColor(.white)
//                                Text("+12")
//                                    .bold()
                                
                                if viewModel.isNight {
                                    Image(systemName: "moon.fill")
                                        .transition(.scale)
                                } else {
                                    Image(systemName: "sun.max.fill")
                                        .transition(.scale)
                                }
                                
                            }
                            .onTapGesture{
                                viewModel.isNight.toggle()
                            }
//                            .transition(.slide)
                            .animation(.interpolatingSpring(stiffness: 300,
                                                            damping: 14), value: viewModel.isNight)
                        }
                    }
                    .frame(width: width,
                           height: width)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .disabled(!viewModel.notificationsIsOn)
            .opacity(viewModel.notificationsIsOn ? 1 : 0.5)
            .onChange(of: viewModel.getStartHourValue()) { newValue in
                if newValue != viewModel.lastStartAngleVal {
                    sucessGenerator?.impactOccurred()
                }
                self.viewModel.lastStartAngleVal = newValue
            }
            .onChange(of: viewModel.getEndHourValue()) { newValue in
                if newValue != viewModel.lastEndAngleVal {
                    sucessGenerator?.impactOccurred()
                }
                self.viewModel.lastEndAngleVal = newValue
            }
    }
    
}

// MARK: - Preview

struct TimeIntervalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimeIntervalView()
                .environmentObject(ThemeManager(2))
                .preferredColorScheme(.dark)
                .environmentObject(SubscriptionManager())
        }
    }
}
