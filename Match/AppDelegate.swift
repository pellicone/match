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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myViewController: ViewControllerFriends!
    
    var container:CKContainer?
    var publicDatabase:CKDatabase?
    var privateDatabase:CKDatabase?
      func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.container = CKContainer.defaultContainer()
        self.publicDatabase = self.container?.publicCloudDatabase
        self.privateDatabase = self.container?.privateCloudDatabase         // Override point for customization after application launch
       
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        
            let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
            
        if ckNotification.notificationType == .Query//,
          //      let queryNotification = ckNotification as? CKQueryNotification
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    print("REMOTE NOTIFICATION")
                    self.myViewController.refreshInvites()
                }
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
            dispatch_async(dispatch_get_main_queue())
            {
                print("REMOTE NOTIFICATION")
                self.myViewController.refreshInvites()
            }
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        if (self.myViewController != nil) {
            dispatch_async(dispatch_get_main_queue())
            {
                print("REMOTE NOTIFICATION")
                self.myViewController.refreshInvites()
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     
    }

    
}

