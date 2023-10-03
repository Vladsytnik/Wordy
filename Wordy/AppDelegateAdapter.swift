//
//  AppDelegateAdapter.swift
//  Wordy
//
//  Created by Vlad Sytnik on 03.10.2023.
//

import SwiftUI
import FirebaseMessaging


class AppDelegateAdapter: NSObject, UIApplicationDelegate, ObservableObject {
	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		UNUserNotificationCenter.current().delegate = self
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(
			options: authOptions,
			completionHandler: { _, _ in }
		)
		
		application.registerForRemoteNotifications()
		Messaging.messaging().delegate = self
		
//		Messaging.messaging().token { token, error in
//			if let error = error {
//				print("Error fetching FCM registration token: \(error)")
//			} else if let token = token {
//				print("FCM registration token: \(token)")
//
//			}
//		}
	}
	
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		for urlContext in URLContexts {
			let url = urlContext.url
			
		}
		// URL not auth related; it should be handled separately.
	}
}

// MARK: - Notifications

extension AppDelegateAdapter: UNUserNotificationCenterDelegate, MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		print("Firebase registration token: \(String(describing: fcmToken))")
		
		let dataDict: [String: String] = ["token": fcmToken ?? ""]
		NotificationCenter.default.post(
			name: Notification.Name("FCMToken"),
			object: nil,
			userInfo: dataDict
		)
		// TODO: If necessary send token to application server.
		// Note: This callback is fired at each app startup and whenever a new token is generated.
	}
	
	func application(application: UIApplication,
					 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		Messaging.messaging().apnsToken = deviceToken
	}
}
