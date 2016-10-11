//
//  ViewControllerLogin.swift
//  Match
//
//  Created by Daniel Pellicone on 6/20/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewControllerLogin: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if FBSDKAccessToken.currentAccessToken() == nil {
            print("Not Logged in..")
        }
        else {
            print("Logged in..")
            return
            
        }
        
        self.loginButton.addTarget(self, action: #selector(btnLoginPressed), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        
    }
    func btnLoginPressed() {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile"], fromViewController: self, handler: { (response:FBSDKLoginManagerLoginResult!, error: NSError!) in
            if(error == nil){
                print("No Error")
               
            }
        })
    }
        override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.performSegueWithIdentifier("showNew", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            print("Login complete")
            self.performSegueWithIdentifier("showNew", sender: self)
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
