//
//  WordyApp.swift
//  Wordy
//
//  Created by Vlad Sytnik on 10.12.2022.
//

import SwiftUI
import Firebase
import AppsFlyerLib
import ApphudSDK

@main
struct WordyApp: App {
	
	@StateObject var router = Router()
	@StateObject var themeManager = ThemeManager()
	private let deepLinkDelegate = AppFliyerDelegate()
	
	init() {
		FirebaseApp.configure()
		AppsFlyerLib.shared().appsFlyerDevKey = "axfubYMdYCtRH3aW6FZYUc"
		AppsFlyerLib.shared().appleAppID = "6466481056"
		Apphud.start(apiKey: "app_6t9G2dfKPDzUt3jifCJdTPMLbaKCPr")
	}
	
	var body: some Scene {
		WindowGroup {
			StartView()
				.environmentObject(router)
				.environmentObject(themeManager)
				.onAppear {
					AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
						if (error != nil){
							print("AppsFlyerLib error:", error ?? "")
							return
						} else {
							print("AppsFlyerLib:", dictionary ?? "")
							AppsFlyerLib.shared().delegate = deepLinkDelegate as? any AppsFlyerLibDelegate
							return
						}
					})
					AppsFlyerLib.shared().isDebug = true
				}
		}
	}
}

class AppFliyerDelegate: NSObject, DeepLinkDelegate {
	func didResolveDeepLink(_ result: DeepLinkResult) {
		switch result.status {
		case .notFound:
			NSLog("[AFSDK] Deep link not found")
			return
		case .failure:
			print("Error %@", result.error!)
			return
		case .found:
			NSLog("[AFSDK] Deep link found")
		}
		
		guard let deepLinkObj:DeepLink = result.deepLink else {
			NSLog("[AFSDK] Could not extract deep link object")
			return
		}
		
		if deepLinkObj.clickEvent.keys.contains("deep_link_sub2") {
			let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub2"] as! String
			NSLog("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
		} else {
			NSLog("[AFSDK] Could not extract referrerId")
		}
		
		let deepLinkStr:String = deepLinkObj.toString()
		NSLog("[AFSDK] DeepLink data is: \(deepLinkStr)")
		
		if( deepLinkObj.isDeferred == true) {
			NSLog("[AFSDK] This is a deferred deep link")
		}
		else {
			NSLog("[AFSDK] This is a direct deep link")
		}
		
	}
}
