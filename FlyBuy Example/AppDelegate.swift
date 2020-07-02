//
//  AppDelegate.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit
import FlyBuy
import UserNotifications
import Firebase
import FirebaseMessaging
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  let gcmMessageIDKey = "gcm.message_id"
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let token = "97.eHzCUMApgzRNM5bqjQ6HWRqB"
    assert(token != "<YOUR TOKEN HERE>", "You must add your FlyBuy token")
    FlyBuy.configure(["token": token])
    
    FlyBuy.sites.fetch(page: 1) { (sites, pagination, error) -> (Void) in
        NSLog("Sites have been fetched")
    }
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

extension AppDelegate {
  func checkFlyBuyConfig() {
    FlyBuy.config.fetch() { (config, error) in
      if let upgradeSettings = config?["upgrade"] as? [String : Any],
        let required = upgradeSettings["required"] as? Bool,
        let urlStr = upgradeSettings["url"] as? String, let url = URL(string: urlStr),
        let message = upgradeSettings["message"] as? String {
          self.upgradeAlert(required: required, message: message, url: url)
      }
    }
  }

  func upgradeAlert(required: Bool, message: String, url: URL) {
    let alert = UIAlertController(title: "New Version Available", message: message, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Update App", style: .default, handler: { (action) in
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }))
    alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
    if let topController = UIApplication.shared.keyWindow?.rootViewController {
      DispatchQueue.main.async {
        topController.present(alert, animated: true, completion: nil)
      }
    }
  }

  func setupFirebase() {
    FirebaseApp.configure()
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self
    Messaging.messaging().shouldEstablishDirectChannel = true
  }

  // Register for remote notifications. This shows a permission dialog on first run, to
  // show the dialog at a more appropriate time move this registration accordingly.
  func registerForNotifications(_ callback: ((Bool, Error?) -> (Void))? = nil) {

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
      DispatchQueue.main.async { callback?(granted, error) }
    }

    UIApplication.shared.registerForRemoteNotifications()

    InstanceID.instanceID().instanceID { (result, error) in
      if let error = error {
        print("Error fetching remote instance ID: \(error)")
      } else if let result = result {
        print("Remote instance ID token: \(result.token)")
      }
    }
  }

  func registerForSDKLocationNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(sdkLocationNotification(notification:)), name: .locationAuthorizationNotDetermined, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(sdkLocationNotification(notification:)), name: .locationNotAuthorized, object: nil)
  }
  
  @objc func sdkLocationNotification(notification: Notification) {
    switch notification.name {
    case .locationAuthorizationNotDetermined:
      // We should have already asked for location authorization after presenting
      // the "consent" screen during a redeem flow. But the SDK is telling us we
      // haven't asked, so let's ask now.
      CLLocationManager().requestWhenInUseAuthorization()

    case .locationNotAuthorized:
      NSLog("App is not authorized to receive location updates")
      
    default: ()
    }
  }
}

extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    completionHandler([.badge, .sound, .alert])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}

extension AppDelegate : MessagingDelegate {

  // Note: This callback is fired at each app startup and whenever a new token
  // is generated.
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("Firebase registration token: \(fcmToken)")
    let dataDict:[String: String] = ["token": fcmToken]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                    object: nil,
                                    userInfo: dataDict)
    FlyBuy.updatePushToken(fcmToken)
  }

  // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when
  // the app is in the foreground.  To enable direct data messages, you can set
  // Messaging.messaging().shouldEstablishDirectChannel to true.
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    FlyBuy.handleRemoteNotification(remoteMessage.appData)
    print("Received data message: \(remoteMessage.appData)")
  }
}
