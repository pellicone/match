//
//  ViewControllerTopText.swift
//  Match
//
//  Created by Daniel Pellicone on 7/5/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
//import CloudKit
import Parse
class ViewControllerTopText: UIViewController {
  
    @IBOutlet var backView: UIView!
   
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var endTurnButton: UIButton!
   //  var container:CKContainer?
   // var publicDatabase:CKDatabase?
   // var privateDatabase:CKDatabase?
    var gameID:String = String()
    @IBOutlet var yesButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backView.addDropShadowToView(self.backView)
     //   self.container = CKContainer.defaultContainer()
     //   self.publicDatabase = self.container?.publicCloudDatabase
     //   self.privateDatabase = self.container?.privateCloudDatabase
        self.yesButton.addTarget(self, action: #selector(ViewControllerTopText.yesButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.noButton.addTarget(self, action: #selector(ViewControllerTopText.noButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.endTurnButton.addTarget(self, action: #selector(ViewControllerTopText.endTurnButtonPressedNoError), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func yesButtonPressed()
    {
        self.yesOrNoButtonPressed("yes", errorPar: "")
    }
    
    func noButtonPressed()
    {
        self.yesOrNoButtonPressed("no", errorPar: "")
    }
    
    func yesOrNoButtonPressed(yesOrNo:String, errorPar:String) {
        let parentVC:ViewControllerContainers = (self.parentViewController as! ViewControllerContainers)
        if (errorPar == "")
        {
            parentVC.block = true
            parentVC.updateGameTimer?.invalidate()
            parentVC.turnButtonOff(self.noButton)
            parentVC.turnButtonOff(self.yesButton)
            parentVC.hideTopTextVC()
        }
        
        
        
        let parseACL:PFACL = PFACL()
        parseACL.publicReadAccess = true
        parseACL.publicWriteAccess = true
        let query = PFQuery(className:"Game")
        query.whereKey("gameID", equalTo: parentVC.gameID)
        query.whereKey("player2", equalTo: parentVC.player2)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                
                if objects != nil
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        if (objects?.count > 0)
                        {
                            let gameRecord = objects![0]
                            gameRecord.ACL = parseACL

                          
                            var yesOrNoString:String = String()
                            if (yesOrNo == "yes")
                            {
                                yesOrNoString = "Yes, my person is \(gameRecord["questionText"] as! String)."
                            }
                            else
                            {
                                yesOrNoString = "No, my person is not \(gameRecord["questionText"] as! String)."
                            }
                            gameRecord["questionText"] = yesOrNoString
                            gameRecord["whoseTurn"] = "\((self.parentViewController as! ViewControllerContainers).opponentID)waitingfinished"
                            gameRecord.saveInBackgroundWithBlock { (success, error) -> Void in
                                if error != nil
                                {
                                    print(error?.localizedDescription)
                                    self.yesOrNoButtonPressed(yesOrNo, errorPar: (error?.localizedDescription)!)
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue())
                                    {
                                        parentVC.updateGameTimer?.invalidate()
                                        parentVC.updateGameTimer = nil
                                        parentVC.updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: parentVC.game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)
                                        parentVC.block = false
                                        let containerVC = (self.parentViewController as! ViewControllerContainers)
                                        PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": parentVC.opponentID , "message": "\(containerVC.userName) has responded!"])
                                    }
                                }
                                
                                
                           
                            }
                            
                        }
                        else
                        {
                            self.yesOrNoButtonPressed(yesOrNo, errorPar: "no records")
                        }
                    }
                }
            
      
            }
            else {
                self.yesOrNoButtonPressed(yesOrNo, errorPar: (error?.localizedDescription)!)
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
        
        
        
        
        
        
        
       /* let predicate = NSPredicate(format: "gameID == '\(parentVC.gameID)'")
        self.publicDatabase!.performQuery(CKQuery(recordType: "Game", predicate: predicate), inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
            if error != nil {
                print(error?.localizedDescription)
                self.yesOrNoButtonPressed(yesOrNo, errorPar: (error?.localizedDescription)!)
            }
            else if records != nil
            {
                dispatch_async(dispatch_get_main_queue()) {
                    if (records?.count > 0)
                    {
                        let gameRecord:CKRecord = records![0]
                        var yesOrNoString:String = String()
                        if (yesOrNo == "yes")
                        {
                            yesOrNoString = "Yes, my person is \(gameRecord["questionText"] as! String)."
                        }
                        else
                        {
                             yesOrNoString = "No, my person is not \(gameRecord["questionText"] as! String)."
                        }
                        gameRecord["questionText"] = yesOrNoString
                        gameRecord["whoseTurn"] = "\((self.parentViewController as! ViewControllerContainers).opponentID)waitingfinished"
                        self.publicDatabase?.saveRecord(gameRecord, completionHandler:
                            { (record, error) in
                                if error != nil
                                {
                                    print(error?.localizedDescription)
                                    self.yesOrNoButtonPressed(yesOrNo, errorPar: (error?.localizedDescription)!)
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue())
                                    {
                                        parentVC.updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: parentVC.game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)
                                        parentVC.block = false
                                    }
                                }
                        })
                    }
                    else
                    {
                        self.yesOrNoButtonPressed(yesOrNo, errorPar: "no records")
                    }
                }
            }
        })*/
    }
    func endTurnButtonPressedNoError() {
        self.endTurnButtonPressed("")
    }
    func endTurnButtonPressed(errorPar:String) {
        let parentVC:ViewControllerContainers = (self.parentViewController as! ViewControllerContainers)
        if (errorPar == "")
        {
            parentVC.block = true
            parentVC.updateGameTimer?.invalidate()
            parentVC.turnButtonOff(self.endTurnButton)
            parentVC.hideTopTextVC()
        }
        
        let parseACL:PFACL = PFACL()
        parseACL.publicReadAccess = true
        parseACL.publicWriteAccess = true
        let query = PFQuery(className:"Game")
        query.whereKey("gameID", equalTo: parentVC.gameID)
        query.whereKey("player2", equalTo: parentVC.player2)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                
                if objects != nil
                {
                    dispatch_async(dispatch_get_main_queue()) {
                        if (objects?.count > 0)
                        {
                            let gameRecord = objects![0]
                            gameRecord.ACL = parseACL
                            
                            
                           
                            gameRecord["questionText"] = ""
                            gameRecord["whoseTurn"] = parentVC.opponentID
                            gameRecord.saveInBackgroundWithBlock { (success, error) -> Void in
                                if error != nil
                                {
                                    print(error?.localizedDescription)
                                    self.endTurnButtonPressed((error?.localizedDescription)!)

                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue())
                                    {
                                        parentVC.updateGameTimer?.invalidate()
                                        parentVC.updateGameTimer = nil
                                        parentVC.updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: parentVC.game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)
                                        parentVC.block = false
                                        let containerVC = (self.parentViewController as! ViewControllerContainers)
                                        PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": parentVC.opponentID , "message": "It's your turn to play against \(containerVC.userName)!"])
                                    }
                                }
                                
                                
                                
                            }
                            
                        }
                        else
                        {
                            self.endTurnButtonPressed("no records")

                        }
                    }
                }
                
                
            }
            else {
                self.endTurnButtonPressed((error?.localizedDescription)!)

                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            /*let predicate = NSPredicate(format: "gameID == '\(parentVC.gameID)'")
       
        self.publicDatabase!.performQuery(CKQuery(recordType: "Game", predicate: predicate), inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
            if error != nil {
                print(error?.localizedDescription)
                self.endTurnButtonPressed((error?.localizedDescription)!)
            }
            else if records != nil
            {
                dispatch_async(dispatch_get_main_queue()) {
                    if (records?.count > 0)
                    {
                        let gameRecord:CKRecord = records![0]
                        gameRecord["questionText"] = ""
                        gameRecord["whoseTurn"] = parentVC.opponentID
                        self.publicDatabase?.saveRecord(gameRecord, completionHandler:
                            { (record, error) in
                                if error != nil
                                {
                                    print(error?.localizedDescription)
                                    self.endTurnButtonPressed((error?.localizedDescription)!)
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue())
                                    {
                                        parentVC.updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: parentVC.game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)
                                        parentVC.block = false
                                    }
                                }
                        })
                    }
                    else
                    {
                        self.endTurnButtonPressed("no records")
                    }
                }
            }
        })
 */
        }
        }
}
