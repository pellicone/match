//
//  AppDelegate.swift
//  Match
//
//  Created by Daniel Pellicone on 6/16/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import CloudKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myViewController: ViewControllerFriends!
    
    var container:CKContainer?
    var publicDatabase:CKDatabase?
    var privateDatabase:CKDatabase?
      func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // **********************************************************************************************
        // PARSE ADDITION
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        //Parse.enableLocalDatastore()
        
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "NYMYpVBdTaQSGckmlcOcdzM4KoUaASH4iovyiGwQ"
            ParseMutableClientConfiguration.clientKey = "f5ktev8XpZXHllWL4GD4FGTkUqwh9f1LdZ4QMpPI"
            ParseMutableClientConfiguration.server = "https://parseapi.back4app.com/"
            
        })
        
        Parse.initializeWithConfiguration(parseConfiguration)
        
        
        // ****************************************************************************
        // Uncomment and fill in with your Parse credentials:
        // Parse.setApplicationId("aafdsgw4y645tawet123", clientKey: "sdfg34tesfgsdfhsdfg34rt")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************
        
        PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.publicReadAccess = true
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
           // let userNotificationTypes = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
            print("register")
            
        }
        else {
        //    let types = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Sound]
          //  application.registerForRemoteNotificationTypes([UIRemoteNotificationType.Badge, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Sound])
        }
        
        initializeNotificationServices()
       // self.myViewController.refreshInvites()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        PFPush.handlePush(userInfo)
        print("didReceiveRemoteNotification")
        self.myViewController.refreshInvites()
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
     
      
    }
    func initializeNotificationServices() -> Void {
      //_gs = UIUserNotificationSettings(forTypes: [ .Sound, .Alert, .Badge], categories: nil)
       // UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        print("initialize")
        
        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // Override point for customization after application launch.
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     
        print("aPP will enter bg NOTIFICATION")
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if (self.myViewController != nil) {
         //   dispatch_async(dispatch_get_main_queue())
         //   {
                print("REMOTE NOTIFICATION")
                self.myViewController.refreshInvites()
           // }
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let installation = PFInstallation.currentInstallation()
        if installation.badge != 0 {
            installation.badge = 0
        }
        installation.saveEventually()
        FBSDKAppEvents.activateApp()
        if (self.myViewController != nil) {
           // dispatch_async(dispatch_get_main_queue())
          //  {
           //     print("REMOTE NOTIFICATION")
                self.myViewController.refreshInvites()
          //  }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     
    }

    
}

