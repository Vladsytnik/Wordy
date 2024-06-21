//
//  LiquidOnboardingPage.swift
//  Wordy
//
//  Created by user on 13.06.2024.
//

import SwiftUI
import Combine

struct Intro: Identifiable, Equatable, Decodable {
    var id = UUID().uuidString
    var title: String
    var description: String
    var img: UIImage?
    var color: Color = .black
    var offset: CGSize = .zero
    
    var sortingIndex = 0
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        img: UIImage? = nil,
        color: Color = .black,
        offset: CGSize = .zero,
        sortingIndex: Int = 0
    )
    {
        self.id = id
        self.title = title
        self.description = description
        self.img = img
        self.color = color
        self.offset = offset
        self.sortingIndex = sortingIndex
    }
    
    init() {
        title = ""
        description = ""
        color = .black
    }
    
    enum CodingKeys: CodingKey {
        case title
        case description
        case img
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        
        if let imgData = try container.decodeIfPresent(Data.self, forKey: .img) {
            self.img = UIImage(data: imgData)
        }
    }
}

struct LiquidOnboardingPK: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct LiquidOnboardingView: View {
    
    // MARK: - INTROS
    @Binding var intros: [Intro]
    @Binding var firstIntro: Intro
    @Binding var isOpened: Bool
    
    // MARK: - GESTURE PROPERTIES
    @GestureState var isDragging: Bool = false
    
    @State var fakeIndex: Int = 0
    @State var currentIndex: Int = 0
    @State var isShownCloseBtn = false
    
    @State var isWorked = false
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @State var bottomStackSize: CGSize = .zero
    
    @State var curveX: CGFloat = .zero
    @State var curveY: CGFloat = .zero
    
    @State var realCurveX: CGFloat = .zero
    @State var realCurveY: CGFloat = .zero
    
    @State var isCurveCoordinatedApplied = false
    
    @State var isAlreadyOpened = false
    @State var isHideBgForTransition = false
    
//    init(intros: [Intro]) {
//        self.intros = intros
//    }
    
    var body: some View {
        ZStack {
            
            if !isHideBgForTransition {
                getBgColor(index: 1, isLast: false)
                    .ignoresSafeArea()
                    .padding(.bottom, -150)
            }
            
            ForEach(intros.indices.reversed(), id: \.self) { index in
                //Intro View
                IntroView(intro: intros[index], index: index, isLast: index == 0)
                    .clipShape(
                        LiquidShape(offset: intros[index].offset,
                                    curvePoint: fakeIndex == index ? 50 : 0,
                                    curveX: $curveX, curveY: $curveY,
                                    isLast: index == 0)
                    )
                    .padding(.trailing, fakeIndex == index ? 15: 0)
                    .padding(.trailing, currentIndex < intros.count - 3 ? 0 : -15)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture()
                            .updating($isDragging, body: {value, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                                withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.6, blendDuration: 0.6)){
                                    intros[fakeIndex].offset = value.translation
                                }
                                
                            })
                            .onEnded({value in
                                withAnimation(.spring()) {
                                    if -intros[fakeIndex].offset.width > getRect().width / 4
                                            && currentIndex < intros.count - 3
                                    {
                                        intros[fakeIndex].offset.width = -getRect().height * 1.5
                                        
                                        fakeIndex += 1
                                        
                                        // MARK: - UPDATE ORIGINAL INDEX
                                        if currentIndex == intros.count - 3 {
                                            currentIndex = 0
                                        } else {
                                            currentIndex += 1
                                        }
                                        
                                        // MARK: - RESETING INDEX
                                        //                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        //                                        if fakeIndex == (intros.count - 2) {
                                        //                                            for index in 0..<intros.count - 2{
                                        //                                                intros[index].offset = .zero
                                        //                                            }
                                        //
                                        //                                            fakeIndex = 0
                                        //                                        }
                                        //                                    }
                                        
                                    } else {
                                        intros[fakeIndex].offset = .zero
                                    }
                                }
                            })
                    )
            }
            
            ZStack {
                HStack(spacing: 8) {
                    ForEach(0..<intros.count - 2, id: \.self){ index in
                        Circle()
                            .fill(isDark()
                                  ? currentIndex == index ? themeManager.currentTheme.accent : themeManager.currentTheme.mainText.opacity(0.3)
                                  : currentIndex == index ? .white.opacity(0.7) : themeManager.currentTheme.mainText.opacity(0.3)
                            )
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentIndex == index ? 1.15 : 0.85)
                    }
                    
                    if isShownCloseBtn {
                        Spacer()
                    }
                }
                .background {
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: LiquidOnboardingPK.self, value: geo.size)
                    }
                }
                
                HStack(spacing: 16) {
                    if isShownCloseBtn {
                        Spacer()
                    }
                    
                    //                    Button{
                    ////                        for index in 0..<intros.count - 2 {
                    ////                            intros[index].offset = .zero
                    ////                        }
                    //
                    //                        currentIndex = 0
                    ////                        fakeIndex = 0
                    //
                    //                        isShownCloseBtn = false
                    //
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    //                            for index in 0..<intros.count - 2 {
                    //                                intros[index].offset = .zero
                    //                            }
                    //
                    //                            fakeIndex = 0
                    //
                    //                        }
                    //                    } label: {
                    //                        Image(systemName: "arrow.circlepath")
                    //                            .foregroundColor(themeManager.currentTheme.mainText.opacity(0.7))
                    //                            .scaleEffect(1.3)
                    //                    }
                    //                    .opacity(isShownCloseBtn ? 1 : 0)
                    //                    .animation(.bouncy.speed(0.9).delay(0.1), value: isShownCloseBtn)
                    
                    Button{
                        isOpened.toggle()
                    } label: {
                        Text("Закрыть")
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.currentTheme.mainText)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(themeManager.currentTheme.mainText.opacity(0.4))
                            .clipShape(Capsule())
                    }
                    .opacity(isShownCloseBtn ? 1 : 0)
                    .animation(.bouncy.speed(0.7), value: isShownCloseBtn)
                }
            }
            .padding()
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            
            if !isAlreadyOpened {
                getBgColor(index: 1, isLast: false)
                    .ignoresSafeArea()
                    .padding(.bottom, -150)
            }
            
            IntroView(intro: firstIntro, index: 1, isLast: false)
                .ignoresSafeArea()
                .padding(.trailing, 15)
                .transition(.opacity)
                .opacity(isAlreadyOpened ? 0 : 1)
                .animation(.spring.speed(0.8), value: isAlreadyOpened)
            
        }
        .overlay(
            Button(action: {
                
            }, label: {
                
                Image(systemName: "chevron.right")
                    .font(.largeTitle)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
                    .opacity(currentIndex < intros.count - 3 ? 1 : 0)
                    .gesture(
                    DragGesture()
                        .updating($isDragging, body: {value, out, _ in
                            out = true
                        })
                        .onChanged({ value in
                            withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.6, blendDuration: 0.6)){
                                intros[fakeIndex].offset = value.translation
                            }
                            
                        })
                        .onEnded({value in
                            withAnimation(.spring()){
                                if -intros[fakeIndex].offset.width > getRect().width / 4
                                        && currentIndex < intros.count - 3
                                {
                                    intros[fakeIndex].offset.width = -getRect().height * 1.5
                                    
                                    fakeIndex += 1
                                    
                                    // MARK: - UPDATE ORIGINAL INDEX
                                    if currentIndex == intros.count - 3 {
                                        currentIndex = 0
                                    } else {
                                        currentIndex += 1
                                    }
                                    
                                    // MARK: - RESETING INDEX
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        if fakeIndex == (intros.count - 2) {
                                            for index in 0..<intros.count - 2{
                                                intros[index].offset = .zero
                                            }
                                            
                                            fakeIndex = 0
                                        }
                                    }
                                    
                                } else {
                                    intros[fakeIndex].offset = .zero
                                }
                            }
                        })
                    )
                
            })
            .offset(y: -18)
            .opacity(isDragging ? 0 : 1)
            .animation(.linear, value: isDragging)
                .position(x: getRect().width - 25, y: 150)
            .ignoresSafeArea()
            ,alignment: .topTrailing
        )
        .onAppear {
            print("Test appearing: onAppear")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                print("Test appearing: onAppear .now() + 1")
                guard let first = intros.first else {
                    return
                }
                
                guard var last = intros.last else {
                    return
                }
                
                last.offset.width = -getRect().height * 1.5
                
                intros.append(first)
                intros.insert(last, at: 0)
                
                fakeIndex = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    print("Test appearing: onAppear isAlreadyOpened = true")
                    isAlreadyOpened = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                isHideBgForTransition = true
            }
        }
        .task {
            
        }
        .onChange(of: currentIndex) { val in
            if currentIndex == (intros.count - 2) - 1 {
                withAnimation(.bouncy) {
                    isShownCloseBtn = true
                }
            }
        }
        .onChange(of: curveX) { val in
            if (!isCurveCoordinatedApplied && val != .zero && curveY != .zero)
                ||  (realCurveX == curveX && realCurveY != curveY)
            {
                realCurveX = curveX
                realCurveY = curveY
                isCurveCoordinatedApplied = true
            }
        }
        .onPreferenceChange(LiquidOnboardingPK.self, perform: { value in
            bottomStackSize = value
        })
        .overlay {
           
        }
        
    }
    
    @ViewBuilder
    func IntroView(intro: Intro, index: Int, isLast: Bool) -> some View {
        ZStack {
            VStack {
                if let img = intro.img {
                    Image(uiImage: img)
                    //                Image(uiImage: UIImage.actions)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(40)
                        .padding()
                } else {
                    Image("")
                        .resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    
    //                Text(intro.title)
    //                    .font(.system(size: 40))
    //                    .textCase(.uppercase)
    //                    .foregroundColor(themeManager.currentTheme.mainText)
                    
                    Text(intro.title)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.mainText)
                        .padding(.trailing)
                    
                    Text(intro.description)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .padding(.top)
//                        .frame(width: getRect().width - 100)
                        .padding(.trailing)
                        .padding(.trailing)
                        .lineSpacing(8)
                        .foregroundColor(themeManager.currentTheme.mainText)
                    
                    Color.clear
                        .frame(height: 50)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding([.trailing, .top])
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background((index % 2 == 0 && !isLast)
//                         ? themeManager.currentTheme.main
//                         : (isDark() ? themeManager.currentTheme.darkMain : themeManager.currentTheme.answer2))
            .background(getBgColor(index: index, isLast: isLast))
            .onAppear {
                
            }
//            .onChange(of: isLast, perform: { value in
//                print(value)
//            })
            
//                .background( intro.color)
        }
    }
    
    private func getBgColor(index: Int, isLast: Bool) -> Color {
        (index % 2 == 0 && !isLast)
//        ? themeManager.currentTheme.main
//                     : (isDark() ? themeManager.currentTheme.darkMain : themeManager.currentTheme.answer2)
        ? themeManager.currentTheme.answer1
                     : themeManager.currentTheme.answer4
    }
    
    private func isDark() -> Bool {
        themeManager.currentTheme.isSupportLightTheme
        ? colorScheme != .light
        : themeManager.currentTheme.isDark
    }
    
    func lighten(by percentage: CGFloat, color: Color) -> Color {
        return adjustBrightness(by: abs(percentage), color: color)
    }
    
    func darken(by percentage: CGFloat, color: Color) -> Color {
        return adjustBrightness(by: -abs(percentage), color: color)
    }
    
    private func adjustBrightness(by percentage: CGFloat, color: Color) -> Color {
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(hue: hue, saturation: saturation, brightness: min(max(brightness + percentage, 0), 1), opacity: Double(alpha))
    }
}

// MARK: - VIEW ETENSION

extension View{
    func getRect()->CGRect{
        return UIScreen.main.bounds
    }
}

struct LiquidOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        LiquidOnboardingView(
            intros: .constant([
                Intro(title: "А у нас новое обновление!",
                      description: "Свайпните влево, чтобы посмотреть, что нового добавили в этот релиз.",
                      img: nil,
                      color: ThemeManager().currentTheme.main),
                
                Intro(title: "Календарь",
                      description: "Отслеживайте свои занятия и оценивайте свои результаты, чтобы обучение было более эффективным.",
                      img: UIImage(named: "reward_first_module"),
                      color: ThemeManager().currentTheme.darkMain),
                
                Intro(title: "Оптимизации и улучшения",
                      description: "Как обычно, поправили некоторые моменты, и теперь приложение работает чуть шустрее!",
                      img: UIImage(named: "WordyYellow"),
                      color: ThemeManager().currentTheme.main),
            ]),
            firstIntro: .constant(Intro(title: "А у нас новое обновление!",
                                        description: "Свайпните влево, чтобы посмотреть, что нового добавили в этот релиз.",
                                        img: nil,
                                        color: ThemeManager().currentTheme.main)),
            isOpened: .constant(true)
        )
        .environmentObject(ThemeManager())
    }
}

struct LiquidShape: Shape {
    var offset: CGSize
    var curvePoint: CGFloat
    
    @Binding var curveX: CGFloat
    @Binding var curveY: CGFloat
    
    var isLast: Bool = false
    
    // MARK: SHAPE ANIMATION
    var animatableData: AnimatablePair<CGSize.AnimatableData, CGFloat>{
        get{
            return AnimatablePair(offset.animatableData, curvePoint)
        }
        set{
            offset.animatableData = newValue.first
            curvePoint = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
            return Path { path in
                let width = rect.width + (-offset.width > 0 ? offset.width : 0)
                
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: rect.width, y: 0))
                path.addLine(to: CGPoint(x: rect.width, y: rect.height))
                path.addLine(to: CGPoint(x: 0, y: rect.height))
                
                // MARK: - FROM
                let from = 80 + (offset.width)
                path.move(to: CGPoint(x: rect.width, y: from > 80 ? 80 : from))
                
                // MAR: - TO
                var to = 180 + (offset.height) + (-offset.width)
                to = to < 180 ? 180 : to
                
                let mid : CGFloat = 80 + ((to - 80) / 2)
                
//                curveY = mid
//                curveX = getRect().width - curvePoint - 24
                
                path.addCurve(to: CGPoint(x: rect.width, y: to),
                              control1: CGPoint(x: width - curvePoint, y: mid),
                              control2: CGPoint(x: width - curvePoint, y: mid))
                
            }
        }
}
