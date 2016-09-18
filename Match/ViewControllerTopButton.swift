//
//  ViewControllerTopButton.swift
//  Match
//
//  Created by Daniel Pellicone on 6/30/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
//import CloudKit
import Parse
class ViewControllerTopButton: UIViewController , UITextFieldDelegate {
    @IBOutlet var topButtonView: UIView!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var button: UIButton!
   // var container:CKContainer?
   // var publicDatabase:CKDatabase?
   // var privateDatabase:CKDatabase?
    var gameID:String = String()
    var buttonPressed:Bool = false
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
   //     self.container = CKContainer.defaultContainer()
   //     self.publicDatabase = self.container?.publicCloudDatabase
   //     self.privateDatabase = self.container?.privateCloudDatabase
        self.questionTextField.delegate = self
        self.topButtonView.addDropShadowToView(self.topButtonView)
        self.button.addTarget(self, action: #selector(ViewControllerTopButton.updateQuestionTextNoError), forControlEvents: UIControlEvents.TouchUpInside)
    }
    func updateQuestionTextNoError() {
        self.updateQuestionText("")
    }
    func updateQuestionText(errorPar:String)
    {
        let parentVC:ViewControllerContainers = (self.parentViewController as! ViewControllerContainers)
        
        self.buttonPressed = true
        if (errorPar == "")
        {
            self.view.endEditing(true)
            parentVC.block = true
            parentVC.updateGameTimer?.invalidate()
            parentVC.turnButtonOff(self.button)
            parentVC.hideTopButtonVC()
        }
        if questionTextField.text != ""
        {
            print("Updating question text")
            
            
            let parseACL:PFACL = PFACL()
            parseACL.publicReadAccess = true
            parseACL.publicWriteAccess = true
            let query = PFQuery(className:"Game")
            query.whereKey("gameID", equalTo: parentVC.gameID)
            query.whereKey("player2", equalTo: parentVC.player2)
            parentVC.questionText = self.questionTextField.text!
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects {
                        if objects.count > 0 {
                            let gameRecord = objects[0]
                            gameRecord.ACL = parseACL
                         
                                dispatch_async(dispatch_get_main_queue())
                                {
                                    
                                    
                                        print("updateText")
                                        gameRecord["questionText"] = self.questionTextField.text
                                        gameRecord["whoseTurn"] = "\(parentVC.userID)waiting"
                                    gameRecord.saveInBackgroundWithBlock { (success, error) -> Void in
                                        if error == nil
                                        {
                                            dispatch_async(dispatch_get_main_queue())
                                            {
                                                parentVC.updateGameTimer?.invalidate()
                                                parentVC.updateGameTimer = nil
                                                parentVC.updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: parentVC.game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)
                                                parentVC.block = false
                                                
                                                PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": parentVC.opponentID , "message": "It's your turn to respond to \(parentVC.userName)!"])
                                            }
                                        }
                                        else
                                        {
                                            self.updateQuestionText((error?.localizedDescription)!)
                                        }
                                    }
                            }
                            
                                    
                        }
                    }
                }
                 else {
                    self.updateQuestionText((error?.localizedDescription)!)

                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
            
            /*
            let predicate = NSPredicate(format: "gameID == '\(parentVC.gameID)'")
            parentVC.questionText = self.questionTextField.text!
            self.publicDatabase!.performQuery(CKQuery(recordType: "Game", predicate: predicate), inZoneWithID: nil, completionHandler:
                {
                    (records:[CKRecord]?, error:NSError?) in
                    if error != nil
                    {
                        print(error?.localizedDescription)
                        self.updateQuestionText((error?.localizedDescription)!)
                    }
                    else if records != nil
                    {
                        dispatch_async(dispatch_get_main_queue())
                        {
                            if (records?.count > 0)
                            {
                                let gameRecord:CKRecord = records![0]
                                print("updateText")
                                gameRecord["questionText"] = self.questionTextField.text
                                gameRecord["whoseTurn"] = "\(parentVC.userID)waiting"
                                self.publicDatabase?.saveRecord(gameRecord)
                                {
                                    (record, error) in if error == nil
                                    {
                                        dispatch_async(dispatch_get_main_queue())
                                        {
                                            parentVC.updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: parentVC.game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)
                                            parentVC.block = false
                                        }
                                    }
                                    else
                                    {
                                        self.updateQuestionText((error?.localizedDescription)!)
                                    }
                                }
                            }
                            else
                            {
                                self.updateQuestionText("no records")
                            }
                        }
                    }
                })
 */
        }
    }
    

    func textFieldDidBeginEditing(textField: UITextField)
    {
        let vC:ViewController = (self.parentViewController as! ViewControllerContainers).childViewControllerWithType(ViewController)!
        vC.view.userInteractionEnabled = false
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        self.updateQuestionText("")
        self.questionTextField.resignFirstResponder()
         let vC:ViewController = (self.parentViewController as! ViewControllerContainers).childViewControllerWithType(ViewController)!
        vC.view.userInteractionEnabled = true
        return true
    }
    func textFieldDidEndEditing(textField: UITextField)
    {
        let vC:ViewController = (self.parentViewController as! ViewControllerContainers).childViewControllerWithType(ViewController)!
        vC.view.userInteractionEnabled = true
    }
}
