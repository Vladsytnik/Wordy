// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let accent = ColorAsset(name: "Accent")
    internal static let addModuleButtonBG = ColorAsset(name: "AddModuleButtonBG")
    internal static let brightBtnText = ColorAsset(name: "BrightBtnText")
    internal static let carouselLearnBtnColor = ColorAsset(name: "CarouselLearnBtnColor")
    internal static let createModuleButton = ColorAsset(name: "CreateModuleButton")
    internal static let darkMain = ColorAsset(name: "DarkMain")
    internal static let findedWordHighlite = ColorAsset(name: "FindedWordHighlite")
    internal static let launchScreenBG = ColorAsset(name: "LaunchScreenBG")
    internal static let learnModuleBtnText = ColorAsset(name: "LearnModuleBtnText")
    internal static let main = ColorAsset(name: "Main")
    internal static let mainTextColor = ColorAsset(name: "MainTextColor")
    internal static let moduleCardLightGray = ColorAsset(name: "ModuleCardLightGray")
    internal static let moduleCardMainTextColor = ColorAsset(name: "ModuleCardMainTextColor")
    internal static let moduleCardRoundedAreaColor = ColorAsset(name: "ModuleCardRoundedAreaColor")
    internal static let moduleScreenBtns = ColorAsset(name: "ModuleScreenBtns")
    internal static let nonActiveCategory = ColorAsset(name: "NonActiveCategory")
    internal static let paywallBtnsColor = ColorAsset(name: "PaywallBtnsColor")
    internal static let poptipBgColor = ColorAsset(name: "PoptipBgColor")
    internal static let purchaseBtn = ColorAsset(name: "PurchaseBtn")
    internal static let searchTFBackground = ColorAsset(name: "SearchTFBackground")
    internal static let searchTextFieldTextColor = ColorAsset(name: "SearchTextFieldTextColor")
    internal static let answer1 = ColorAsset(name: "answer1")
    internal static let answer2 = ColorAsset(name: "answer2")
    internal static let answer3 = ColorAsset(name: "answer3")
    internal static let answer4 = ColorAsset(name: "answer4")
    internal static let gradientEnd = ColorAsset(name: "gradientEnd")
    internal static let gradientStart = ColorAsset(name: "gradientStart")
    internal static let paywallCheckmark = ColorAsset(name: "paywallCheckmark")
  }
  internal enum Colors2 {
    internal static let accent2 = ColorAsset(name: "Accent2")
    internal static let addModuleButtonBG2 = ColorAsset(name: "AddModuleButtonBG2")
    internal static let brightBtnText2 = ColorAsset(name: "BrightBtnText2")
    internal static let carouselLearnBtnColor2 = ColorAsset(name: "CarouselLearnBtnColor2")
    internal static let createModuleButton2 = ColorAsset(name: "CreateModuleButton2")
    internal static let darkMain2 = ColorAsset(name: "DarkMain2")
    internal static let findedWordHighlite2 = ColorAsset(name: "FindedWordHighlite2")
    internal static let learnModuleBtnText2 = ColorAsset(name: "LearnModuleBtnText2")
    internal static let main2 = ColorAsset(name: "Main2")
    internal static let mainTextColor2 = ColorAsset(name: "MainTextColor2")
    internal static let moduleCardLightGray2 = ColorAsset(name: "ModuleCardLightGray2")
    internal static let moduleCardMainTextColor2 = ColorAsset(name: "ModuleCardMainTextColor2")
    internal static let moduleCardRoundedAreaColor2 = ColorAsset(name: "ModuleCardRoundedAreaColor2")
    internal static let moduleScreenBtns2 = ColorAsset(name: "ModuleScreenBtns2")
    internal static let nonActiveCategory2 = ColorAsset(name: "NonActiveCategory2")
    internal static let paywallBtnsColor2 = ColorAsset(name: "PaywallBtnsColor2")
    internal static let purchaseBtn2 = ColorAsset(name: "PurchaseBtn2")
    internal static let searchTFBackground2 = ColorAsset(name: "SearchTFBackground2")
    internal static let searchTextFieldTextColor2 = ColorAsset(name: "SearchTextFieldTextColor2")
    internal static let answer12 = ColorAsset(name: "answer12")
    internal static let answer22 = ColorAsset(name: "answer22")
    internal static let answer32 = ColorAsset(name: "answer32")
    internal static let answer42 = ColorAsset(name: "answer42")
  }
  internal enum Colors3 {
    internal static let accent3 = ColorAsset(name: "Accent3")
    internal static let addModuleButtonBG3 = ColorAsset(name: "AddModuleButtonBG3")
    internal static let brightBtnText3 = ColorAsset(name: "BrightBtnText3")
    internal static let carouselLearnBtnColor3 = ColorAsset(name: "CarouselLearnBtnColor3")
    internal static let createModuleButton3 = ColorAsset(name: "CreateModuleButton3")
    internal static let darkMain3 = ColorAsset(name: "DarkMain3")
    internal static let findedWordHighlite3 = ColorAsset(name: "FindedWordHighlite3")
    internal static let learnModuleBtnText3 = ColorAsset(name: "LearnModuleBtnText3")
    internal static let main3 = ColorAsset(name: "Main3")
    internal static let mainTextColor3 = ColorAsset(name: "MainTextColor3")
    internal static let moduleCardLightGray3 = ColorAsset(name: "ModuleCardLightGray3")
    internal static let moduleCardMainTextColor3 = ColorAsset(name: "ModuleCardMainTextColor3")
    internal static let moduleCardRoundedAreaColor3 = ColorAsset(name: "ModuleCardRoundedAreaColor3")
    internal static let moduleScreenBtns3 = ColorAsset(name: "ModuleScreenBtns3")
    internal static let nonActiveCategory3 = ColorAsset(name: "NonActiveCategory3")
    internal static let paywallBtnsColor3 = ColorAsset(name: "PaywallBtnsColor3")
    internal static let purchaseBtn3 = ColorAsset(name: "PurchaseBtn3")
    internal static let searchTFBackground3 = ColorAsset(name: "SearchTFBackground3")
    internal static let searchTextFieldTextColor3 = ColorAsset(name: "SearchTextFieldTextColor3")
    internal static let answer13 = ColorAsset(name: "answer13")
    internal static let answer23 = ColorAsset(name: "answer23")
    internal static let answer33 = ColorAsset(name: "answer33")
    internal static let answer43 = ColorAsset(name: "answer43")
  }
  internal enum Colors4 {
    internal static let accent4 = ColorAsset(name: "Accent4")
    internal static let addModuleButtonBG4 = ColorAsset(name: "AddModuleButtonBG4")
    internal static let brightBtnText4 = ColorAsset(name: "BrightBtnText4")
    internal static let carouselLearnBtnColor4 = ColorAsset(name: "CarouselLearnBtnColor4")
    internal static let createModuleButton4 = ColorAsset(name: "CreateModuleButton4")
    internal static let darkMain4 = ColorAsset(name: "DarkMain4")
    internal static let findedWordHighlite4 = ColorAsset(name: "FindedWordHighlite4")
    internal static let learnModuleBtnText4 = ColorAsset(name: "LearnModuleBtnText4")
    internal static let main4 = ColorAsset(name: "Main4")
    internal static let mainTextColor4 = ColorAsset(name: "MainTextColor4")
    internal static let moduleCardLightGray4 = ColorAsset(name: "ModuleCardLightGray4")
    internal static let moduleCardMainTextColor4 = ColorAsset(name: "ModuleCardMainTextColor4")
    internal static let moduleCardRoundedAreaColor4 = ColorAsset(name: "ModuleCardRoundedAreaColor4")
    internal static let moduleScreenBtns4 = ColorAsset(name: "ModuleScreenBtns4")
    internal static let nonActiveCategory4 = ColorAsset(name: "NonActiveCategory4")
    internal static let paywallBtnsColor4 = ColorAsset(name: "PaywallBtnsColor4")
    internal static let purchaseBtn4 = ColorAsset(name: "PurchaseBtn4")
    internal static let searchTFBackground4 = ColorAsset(name: "SearchTFBackground4")
    internal static let searchTextFieldTextColor4 = ColorAsset(name: "SearchTextFieldTextColor4")
    internal static let answer14 = ColorAsset(name: "answer14")
    internal static let answer24 = ColorAsset(name: "answer24")
    internal static let answer34 = ColorAsset(name: "answer34")
    internal static let answer44 = ColorAsset(name: "answer44")
  }
  internal enum Colors5 {
    internal static let accent5 = ColorAsset(name: "Accent5")
    internal static let addModuleButtonBG5 = ColorAsset(name: "AddModuleButtonBG5")
    internal static let brightBtnText5 = ColorAsset(name: "BrightBtnText5")
    internal static let carouselLearnBtnColor5 = ColorAsset(name: "CarouselLearnBtnColor5")
    internal static let createModuleButton5 = ColorAsset(name: "CreateModuleButton5")
    internal static let darkMain5 = ColorAsset(name: "DarkMain5")
    internal static let findedWordHighlite5 = ColorAsset(name: "FindedWordHighlite5")
    internal static let learnModuleBtnText5 = ColorAsset(name: "LearnModuleBtnText5")
    internal static let main5 = ColorAsset(name: "Main5")
    internal static let mainTextColor5 = ColorAsset(name: "MainTextColor5")
    internal static let moduleCardLightGray5 = ColorAsset(name: "ModuleCardLightGray5")
    internal static let moduleCardMainTextColor5 = ColorAsset(name: "ModuleCardMainTextColor5")
    internal static let moduleCardRoundedAreaColor5 = ColorAsset(name: "ModuleCardRoundedAreaColor5")
    internal static let moduleScreenBtns5 = ColorAsset(name: "ModuleScreenBtns5")
    internal static let nonActiveCategory5 = ColorAsset(name: "NonActiveCategory5")
    internal static let paywallBtnsColor5 = ColorAsset(name: "PaywallBtnsColor5")
    internal static let purchaseBtn5 = ColorAsset(name: "PurchaseBtn5")
    internal static let searchTFBackground5 = ColorAsset(name: "SearchTFBackground5")
    internal static let searchTextFieldTextColor5 = ColorAsset(name: "SearchTextFieldTextColor5")
    internal static let answer15 = ColorAsset(name: "answer15")
    internal static let answer25 = ColorAsset(name: "answer25")
    internal static let answer35 = ColorAsset(name: "answer35")
    internal static let answer45 = ColorAsset(name: "answer45")
  }
  internal enum Colors6 {
    internal static let accent6 = ColorAsset(name: "Accent6")
    internal static let addModuleButtonBG6 = ColorAsset(name: "AddModuleButtonBG6")
    internal static let brightBtnText6 = ColorAsset(name: "BrightBtnText6")
    internal static let carouselLearnBtnColor6 = ColorAsset(name: "CarouselLearnBtnColor6")
    internal static let createModuleButton6 = ColorAsset(name: "CreateModuleButton6")
    internal static let darkMain6 = ColorAsset(name: "DarkMain6")
    internal static let findedWordHighlite6 = ColorAsset(name: "FindedWordHighlite6")
    internal static let learnModuleBtnText6 = ColorAsset(name: "LearnModuleBtnText6")
    internal static let main6 = ColorAsset(name: "Main6")
    internal static let mainTextColor6 = ColorAsset(name: "MainTextColor6")
    internal static let moduleCardLightGray6 = ColorAsset(name: "ModuleCardLightGray6")
    internal static let moduleCardMainTextColor6 = ColorAsset(name: "ModuleCardMainTextColor6")
    internal static let moduleCardRoundedAreaColor6 = ColorAsset(name: "ModuleCardRoundedAreaColor6")
    internal static let moduleScreenBtns6 = ColorAsset(name: "ModuleScreenBtns6")
    internal static let nonActiveCategory6 = ColorAsset(name: "NonActiveCategory6")
    internal static let paywallBtnsColor6 = ColorAsset(name: "PaywallBtnsColor6")
    internal static let purchaseBtn6 = ColorAsset(name: "PurchaseBtn6")
    internal static let searchTFBackground6 = ColorAsset(name: "SearchTFBackground6")
    internal static let searchTextFieldTextColor6 = ColorAsset(name: "SearchTextFieldTextColor6")
    internal static let answer16 = ColorAsset(name: "answer16")
    internal static let answer26 = ColorAsset(name: "answer26")
    internal static let answer36 = ColorAsset(name: "answer36")
    internal static let answer46 = ColorAsset(name: "answer46")
  }
  internal enum Images {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let addModuleCheckMark = ImageAsset(name: "AddModuleCheckMark")
    internal static let addWordButton = ImageAsset(name: "AddWordButton")
    internal static let authBG = ImageAsset(name: "AuthBG")
    internal static let backButton = ImageAsset(name: "BackButton")
    internal static let carouselBG = ImageAsset(name: "CarouselBG")
    internal static let closeBtn = ImageAsset(name: "CloseBtn")
    internal static let closeEmoji = ImageAsset(name: "CloseEmoji")
    internal static let gradientBG = ImageAsset(name: "GradientBG")
    internal static let moduleCardBottomStuff = ImageAsset(name: "ModuleCardBottomStuff")
    internal static let plusIcon = ImageAsset(name: "PlusIcon")
    internal static let question = ImageAsset(name: "Question")
    internal static let searchIcon = ImageAsset(name: "SearchIcon")
    internal static let settingsIcon = ImageAsset(name: "SettingsIcon")
    internal static let speach = ImageAsset(name: "Speach")
    internal static let wordyYellow = ImageAsset(name: "WordyYellow")
    internal static let addModule = ImageAsset(name: "addModule")
    internal static let advantage = ImageAsset(name: "advantage")
    internal static let learnPageBG = ImageAsset(name: "learnPageBG")
    internal static let newGroup = ImageAsset(name: "newGroup")
    internal static let paper = ImageAsset(name: "paper")
    internal static let rewardConfetti = ImageAsset(name: "reward_confetti")
    internal static let rewardFirstModule = ImageAsset(name: "reward_first_module")
  }
  internal enum Images2 {
    internal static let authBG2 = ImageAsset(name: "AuthBG2")
    internal static let carouselBG2 = ImageAsset(name: "CarouselBG2")
    internal static let gradientBG2 = ImageAsset(name: "GradientBG2")
    internal static let learnPageBG2 = ImageAsset(name: "learnPageBG2")
  }
  internal enum Images3 {
    internal static let authBG3 = ImageAsset(name: "AuthBG3")
    internal static let carouselBG3 = ImageAsset(name: "CarouselBG3")
    internal static let gradientBG3 = ImageAsset(name: "GradientBG3")
    internal static let learnPageBG3 = ImageAsset(name: "learnPageBG3")
  }
  internal enum Images4 {
    internal static let authBG4 = ImageAsset(name: "AuthBG4")
    internal static let carouselBG4 = ImageAsset(name: "CarouselBG4")
    internal static let gradientBG4 = ImageAsset(name: "GradientBG4")
    internal static let learnPageBG4 = ImageAsset(name: "learnPageBG4")
  }
  internal enum Images5 {
    internal static let authBG5 = ImageAsset(name: "AuthBG5")
    internal static let carouselBG5 = ImageAsset(name: "CarouselBG5")
    internal static let gradientBG5 = ImageAsset(name: "GradientBG5")
    internal static let learnPageBG5 = ImageAsset(name: "learnPageBG5")
  }
  internal enum Images6 {
    internal static let authBG6 = ImageAsset(name: "AuthBG6")
    internal static let carouselBG6 = ImageAsset(name: "CarouselBG6")
    internal static let gradientBG6 = ImageAsset(name: "GradientBG6")
    internal static let learnPageBG6 = ImageAsset(name: "learnPageBG6")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
