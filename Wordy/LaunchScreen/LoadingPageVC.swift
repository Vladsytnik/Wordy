//
//  LoadingPage.swift
//  Wordy
//
//  Created by user on 18.02.2024.
//

import SwiftUI
import ImageIO
import CoreHaptics

enum LoadingPageState: Int {
    case initial = 0
    case smallElements = 1
    case logoRotation = 2
    case circleAppearing = 3
    case circleColorChanging = 4
    case isEncreasing = 5
    case disappearingMask = 6
}

struct LoadingPage: View {
    
    let duration: Double
    
    @State private var animationIndex = 0
    private let minimumScaleFactor: CGFloat = 0.05
    @State var hapticEngine: CHHapticEngine?
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @Binding var start: Bool
    var onComplete: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color(asset: Asset.Colors.launchScreenBG)
                .ignoresSafeArea()
            
            Logo()
                .scaleEffect(animationIndex == intFrom(state: .initial) ? 1 :
                                animationIndex < intFrom(state: .isEncreasing) ? minimumScaleFactor :
                                1.1)
                .shadow(color: .white.opacity(0.5),
                        radius: animationIndex > intFrom(state: .initial) ? 10 : 0)
            
            YellowCircle()
                .scaleEffect(animationIndex == intFrom(state: .initial) ? 1 :
                                animationIndex < intFrom(state: .isEncreasing) ? minimumScaleFactor + 0.1 :
                                20)
                .opacity(animationIndex < intFrom(state: .circleAppearing) ? 0 : 1)
//                .shadow(color: .yellow, radius: 10, x: 0, y: 0)
                .shadow(color: .white.opacity(0.5),
                        radius: animationIndex > intFrom(state: .initial) ? 10 : 0)
            
            MainColorCircle()
                .scaleEffect(animationIndex == intFrom(state: .initial) ? 1 :
                                animationIndex < intFrom(state: .isEncreasing) ? minimumScaleFactor + 0.1 :
                                20)
            
            Circle()
                .frame(width: 100)
//                .offset(x: animationIndex < intFrom(state: .isEncreasing) ? 8 : 0,
//                        y: animationIndex < intFrom(state: .isEncreasing) ? -20 : 0)
                .scaleEffect(animationIndex < intFrom(state: .disappearingMask) ? 0 : 20)
                .blendMode(.destinationOut)
        }
        .onChange(of: start, perform: { value in
            if value {
                startAnimation()
            }
        })
        .onAppear {
            do {
                hapticEngine = try CHHapticEngine()
            } catch(let error) {
                print("haptic error: \(error.localizedDescription)")
            }
        }
        .compositingGroup()
    }
    
    func startHaptic() {
        do {
            guard let path = Bundle.main.path(forResource: "haptic_loading", ofType : "ahap")
            else { return }
                    
            try hapticEngine?.start()
            try hapticEngine?.playPattern(from: URL(fileURLWithPath: path))
        } catch(let error) {
            print("haptic error: \(error.localizedDescription)")
        }
    }
    
    func startAnimation() {
        startHaptic()
        print("loading page test: началась анимация Loading Page")
        withAnimation(.spring.delay(0.3)) {
            animationIndex += 1
            animationIndex += 1
        }
        withAnimation(.spring(duration: 0.5).delay(0.4)) {
            animationIndex += 1
        }
        withAnimation(.spring(duration: 0.3).delay(0.6)) {
            animationIndex += 1
        }
        withAnimation(.spring(duration: 0.7).delay(0.9)) {
            animationIndex += 1
        }
        withAnimation(.spring(duration: 1.0).delay(0.97)) {
            animationIndex += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            print("loading page test: закрывается экран Loading Page")
            self.onComplete?()
        }
    }
    
    func intFrom(state: LoadingPageState) -> Int {
        state.rawValue
    }
    
    @ViewBuilder
    private func MainColorCircle() -> some View {
        Circle()
        .frame(width: 100)
        .offset(x: animationIndex < intFrom(state: .circleColorChanging) ? 8 : 0,
                y: animationIndex < intFrom(state: .circleColorChanging) ? -20 : 0)
        .foregroundColor(themeManager.currentTheme.main)
        .opacity(animationIndex < intFrom(state: .circleColorChanging) ? 0 : 1)
    }
    
    @ViewBuilder
    private func YellowCircle() -> some View {
        Circle()
        .frame(width: 100)
        .offset(x: animationIndex < intFrom(state: .circleColorChanging) ? 8 : 0,
                y: animationIndex < intFrom(state: .circleColorChanging) ? -20 : 0)
        .foregroundColor(Color(asset: Asset.Colors.wordyYellow))
        .opacity(animationIndex < intFrom(state: .circleColorChanging) ? 1 : 0)
    }
    
    @ViewBuilder
    private func Logo() -> some View {
        Image(asset: Asset.Images.wordyYellow)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
        .rotationEffect(animationIndex < intFrom(state: .logoRotation) ? .degrees(0) : .degrees(2160))
        .offset(x: 8, y: -20)
    }
}

#Preview {
    TestLoadingPage()
        .environmentObject(Router())
        .environmentObject(DataManager.shared)
        .environmentObject(DeeplinkManager())
        .environmentObject(RewardManager())
        .environmentObject(ThemeManager(0))
}


class LoadingPageVC: UIViewController {
    
    @IBOutlet var imageV: UIImageView!
    @IBOutlet var widthCntrn: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.widthCntrn.constant = 110
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.widthCntrn.constant = 1
                self.view.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)
        
        return animation
    }
}
