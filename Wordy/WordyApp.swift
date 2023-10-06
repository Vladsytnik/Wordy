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
import UserNotifications

@main
struct WordyApp: App {
	
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject var router = Router()
	@StateObject var themeManager = ThemeManager()
	@StateObject var subsriptionManager = SubscriptionManager()
	@StateObject var deeplinkManager = DeeplinkManager()
	
	private let deepLinkDelegate = AppFliyerDelegate()
	
	init() {
//		FirebaseApp.configure()
		AppsFlyerLib.shared().appsFlyerDevKey = "axfubYMdYCtRH3aW6FZYUc"
		AppsFlyerLib.shared().appleAppID = "6466481056"
		Apphud.start(apiKey: "app_6t9G2dfKPDzUt3jifCJdTPMLbaKCPr")
	}
	
	var body: some Scene {
		WindowGroup {
			StartView()
				.environmentObject(router)
				.environmentObject(themeManager)
				.environmentObject(subsriptionManager)
				.environmentObject(deeplinkManager)
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
				.onOpenURL { url in
					print("DEEPLINK url: ", url)
					
					deeplinkManager.wasOpened(url: url)
					
					let test = false
				}
		}
	}
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
	
	let gcmMessageIDKey = "gcm.message_id"
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		FirebaseApp.configure()
		
		Messaging.messaging().delegate = self
		
		if #available(iOS 10.0, *) {
			// For iOS 10 display notification (sent via APNS)
			UNUserNotificationCenter.current().delegate = self
			
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: {_, _ in })
		} else {
			let settings: UIUserNotificationSettings =
			UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)
		}
		
		application.registerForRemoteNotifications()
		return true
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
					 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		print(userInfo)
		
		completionHandler(UIBackgroundFetchResult.newData)
	}
}

extension AppDelegate: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		
		let deviceToken:[String: String] = ["token": fcmToken ?? ""]
		print("Device token: ", deviceToken) // This token can be used for testing notifications on FCM
	}
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
	
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID: \(messageID)")
		}
		
		print(userInfo)
		
		// Change this to your preferred presentation option
		completionHandler([[.banner, .badge, .sound]])
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
	}
	
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		
		if let messageID = userInfo[gcmMessageIDKey] {
			print("Message ID from userNotificationCenter didReceive: \(messageID)")
		}
		
		print(userInfo)
		
		completionHandler()
	}
}


// MARK: - AppFliyerDelegate

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
