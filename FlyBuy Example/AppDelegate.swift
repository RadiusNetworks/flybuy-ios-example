//
//  AppDelegate.swift
//  FlyBuy Example
//
//  Copyright © 2020 Radius Networks. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging
import CoreLocation
import FlyBuy
import FlyBuyPickup

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  let gcmMessageIDKey = "gcm.message_id"

  // static configuration of your test site partner_identifier
  static let site_number: String = "1111"
    
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    CLLocationManager().requestWhenInUseAuthorization()
    
    //setupFirebase()
    registerForNotifications()
    registerForSDKLocationNotifications()
    
    // add you Flybuy SDK authentication token here
    let token = "97.eHzCUMApgzRNM5bqjQ6HWRqB"
    assert(token != "<YOUR TOKEN HERE>", "You must add your FlyBuy token")

    //configure SDK
    let configOptions = ConfigOptions.Builder(token: token).build()
    FlyBuy.Core.configure(withOptions: configOptions)

    // cofigure pickup module
    FlyBuyPickup.Manager.shared.configure()

    // check site exists
    FlyBuy.Core.sites.fetchByPartnerIdentifier(partnerIdentifier: AppDelegate.site_number) {
        (site, error) -> (Void) in
      if let error = error {
        NSLog("Site not found, " + error.message)
      } else {
        NSLog("Site has been fetched")
      }
    }
    
    return true
  }

    func applicationWillResignActive(_ application: UIApplication) {
      // Sent when the application is about to move from active to inactive
      // state. This can occur for certain types of temporary interruptions (such
      // as an incoming phone call or SMS message) or when the user quits the
      // application and it begins the transition to the background state.
      //
      // Use this method to pause ongoing tasks, disable timers, and invalidate
      // graphics rendering callbacks. Games should use this method to pause the
      // game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
      // Use this method to release shared resources, save user data, invalidate
      // timers, and store enough application state information to restore your
      // application to its current state in case it is terminated later.
      //
      // If your application supports background execution, this method is called
      // instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
      // Called as part of the transition from the background to the active
      // state; here you can undo many of the changes made on entering the
      // background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      // Restart any tasks that were paused (or not yet started) while the
      // application was inactive. If the application was previously in the
      // background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
      // Called when the application is about to terminate. Save data if
      // appropriate. See also applicationDidEnterBackground:.
    }

    func applicationDidFinishLaunching(_ application: UIApplication) {
        FirebaseApp.configure()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the
      // background, this callback will not be fired till the user taps on the
      // notification launching the application.

      FlyBuy.Core.handleRemoteNotification(userInfo)

      // Since we disable swizzling with Firebase you must let Messaging know
      // about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // Since we disable swizzling with Firebase this function must be implemented
    // so that the APNs token can be paired to the FCM registration token.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
    }
  }

  extension AppDelegate {
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
      #if !DEBUG
        Crashlytics.crashlytics()
      #endif
      UNUserNotificationCenter.current().delegate = self
      Messaging.messaging().delegate = self
    }

    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    func registerForNotifications(_ callback: ((Bool, Error?) -> (Void))? = nil) {

      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
        DispatchQueue.main.async { callback?(granted, error) }
      }

      UIApplication.shared.registerForRemoteNotifications()
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
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    // fcmToken is now has an optional value, so check if there is a value
    guard let token = fcmToken else {
      return
    }
    
    FlyBuy.Core.updatePushToken(token)
  }
}
