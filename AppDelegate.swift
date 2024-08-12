//
//  AppDelegate.swift
//  TodoApp
//
//  Created by Berat Yükselen on 16.04.2024.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // FCM entegrasyonu
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()

        // Bildirimler için izin isteme
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni alınamadı: \(error)")
            } else {
                print("Bildirim izni alındı!")
            }
        }
        UNUserNotificationCenter.current().delegate = self

        window = UIWindow()
        window?.rootViewController = MainTabBarViewController()
        window?.makeKeyAndVisible()

        return true
    }

    // FCM tokeni alma
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            return
        }
        print("FCM Token: \(token)")
    }

    // Bildirim alındığında çağrılacak metod
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Bildirime tıklandığında burası çalışır, gerektiğinde işlemler yapılabilir.
        completionHandler()
    }
}

