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
    internal static let createModuleButton = ColorAsset(name: "CreateModuleButton")
    internal static let darkMain = ColorAsset(name: "DarkMain")
    internal static let findedWordHighlite = ColorAsset(name: "FindedWordHighlite")
    internal static let learnModuleBtnText = ColorAsset(name: "LearnModuleBtnText")
    internal static let main = ColorAsset(name: "Main")
    internal static let moduleCardDarkGray = ColorAsset(name: "ModuleCardDarkGray")
    internal static let moduleCardLightGray = ColorAsset(name: "ModuleCardLightGray")
    internal static let nonActiveCategory = ColorAsset(name: "NonActiveCategory")
    internal static let purchaseBtn = ColorAsset(name: "PurchaseBtn")
    internal static let searchTFBackground = ColorAsset(name: "SearchTFBackground")
    internal static let answer1 = ColorAsset(name: "answer1")
    internal static let answer2 = ColorAsset(name: "answer2")
    internal static let answer3 = ColorAsset(name: "answer3")
    internal static let answer4 = ColorAsset(name: "answer4")
  }
  internal enum Colors2 {
    internal static let accent2 = ColorAsset(name: "Accent2")
    internal static let addModuleButtonBG2 = ColorAsset(name: "AddModuleButtonBG2")
    internal static let brightBtnText2 = ColorAsset(name: "BrightBtnText2")
    internal static let createModuleButton2 = ColorAsset(name: "CreateModuleButton2")
    internal static let darkMain2 = ColorAsset(name: "DarkMain2")
    internal static let findedWordHighlite2 = ColorAsset(name: "FindedWordHighlite2")
    internal static let learnModuleBtnText2 = ColorAsset(name: "LearnModuleBtnText2")
    internal static let main2 = ColorAsset(name: "Main2")
    internal static let moduleCardDarkGray2 = ColorAsset(name: "ModuleCardDarkGray2")
    internal static let moduleCardLightGray2 = ColorAsset(name: "ModuleCardLightGray2")
    internal static let nonActiveCategory2 = ColorAsset(name: "NonActiveCategory2")
    internal static let purchaseBtn2 = ColorAsset(name: "PurchaseBtn2")
    internal static let searchTFBackground2 = ColorAsset(name: "SearchTFBackground2")
    internal static let answer12 = ColorAsset(name: "answer12")
    internal static let answer22 = ColorAsset(name: "answer22")
    internal static let answer32 = ColorAsset(name: "answer32")
    internal static let answer42 = ColorAsset(name: "answer42")
  }
  internal enum Images {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let addModule = ImageAsset(name: "AddModule")
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
    internal static let advantage = ImageAsset(name: "advantage")
    internal static let learnPageBG = ImageAsset(name: "learnPageBG")
    internal static let newGroup = ImageAsset(name: "newGroup")
  }
  internal enum Images2 {
    internal static let authBG2 = ImageAsset(name: "AuthBG2")
    internal static let carouselBG2 = ImageAsset(name: "CarouselBG2")
    internal static let gradientBG2 = ImageAsset(name: "GradientBG2")
    internal static let learnPageBG2 = ImageAsset(name: "learnPageBG2")
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
