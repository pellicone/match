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

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setButtonFontSize(self.noButton)
        self.setButtonFontSize(self.yesButton)
        self.setButtonFontSize(self.endTurnButton)
        self.textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        
       
        self.backView.addDropShadowToView(self.backView)
     //   self.container = CKContainer.defaultContainer()
     //   self.publicDatabase = self.container?.publicCloudDatabase
     //   self.privateDatabase = self.container?.privateCloudDatabase
        self.yesButton.addTarget(self, action: #selector(ViewControllerTopText.yesButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.noButton.addTarget(self, action: #selector(ViewControllerTopText.noButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.endTurnButton.addTarget(self, action: #selector(ViewControllerTopText.endTurnButtonPressedNoError), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      //  let range = NSMakeRange(0, self.textView.text.characters.count - 1)
       // self.textView.scrollRangeToVisible(range)
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.textView.removeObserver(self, forKeyPath: "contentSize")
    }
    func setButtonFontSize(button:UIButton) {
        button.titleLabel!.numberOfLines = 1
        button.titleLabel!.adjustsFontSizeToFitWidth = true
        button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
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
                                yesOrNoString = self.processQuestionText("\(gameRecord["questionText"] as! String)", yes: true)
                            }
                            else
                            {
                                yesOrNoString = self.processQuestionText("\(gameRecord["questionText"] as! String)", yes: false)
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
                                        let query = PFQuery(className: "TurnRecord")
                                        query.whereKey("gameID", equalTo: parentVC.gameID)
                                        
                                        query.findObjectsInBackgroundWithBlock {
                                            (objects: [PFObject]?, error: NSError?) -> Void in
                                            if let objects = objects {
                                                for object in objects {
                                                    object.deleteEventually()
                                                }
                                            }
                                        }
                                        
                                        let parseACL:PFACL = PFACL()
                                        parseACL.publicReadAccess = true
                                        parseACL.publicWriteAccess = true
                                        
                                        let turnRecord = PFObject(className: "TurnRecord")
                                        turnRecord.ACL = parseACL
                                        turnRecord["gameID"] = parentVC.gameID
                                        turnRecord["playerID"] = parentVC.opponentID
                                        turnRecord["text"] = "\(parentVC.userName) has responded!"
                                        
                                        turnRecord.saveEventually()
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
    
    
    func processQuestionText(str:String, yes:Bool) -> String {
        var ret = String()
        var middleWord = "does"
        if (yes)
        {
            ret = "Yes, my person"
        }
        else
        {
            ret = "No, my person"
        }
        
        var qLead = "Does your person"
        if (str.containsString("Is your person")) {
            qLead = "Is your person"
            middleWord = "is"
        }
        else if (str.containsString("Has your person")) {
            qLead = "Has your person"
            middleWord = "has"
        }
        else if (str.containsString("Did your person")) {
            qLead = "Did your person"
            middleWord = "did"
        }
        else if (str.containsString("Was your person")) {
            qLead = "Was your person"
            middleWord = "was"
        }
        if (!yes)
        {
            middleWord = "\(middleWord) not"
        }
        
       // let str = "Does your person eat food?"
        let index1 = str.startIndex.advancedBy(qLead.characters.count + 1)
      
        var substring1 = str.substringFromIndex(index1)
           let index2 = substring1.startIndex.advancedBy(substring1.characters.count - 1)
        substring1 = substring1.substringToIndex(index2)
        
        
        var replaced:String = substring1
        
        var finds = ["to you", "to me"] //(to you)(to me)
        var replaces = ["t*o* m*e*", "t*o* y*o*u*"]
        for i in 0...finds.count - 1 {
            replaced = (replaced as NSString).stringByReplacingOccurrencesOfString(finds[i], withString: replaces[i])
            
        }
        finds.removeAll()
        replaces.removeAll()
        finds =    ["I am", "I'm", "I", "you're", "you are",   "yours",        "my",  "your",   "mine","ed you", "ed me", "you" ] //(to you)(to me)
        replaces = ["y*o*u* a*r*e*", "y*o*u* a*r*e*",  "y*o*u*", "I* a*m*", "I* a*m*", "m*i*n*e*", "y*o*u*r*",   "m*y*", "y*o*u*r*s*","e*d* m*e*", "e*d* y*o*u*","I*"]
        for i in 0...finds.count - 1 {
        replaced = (replaced as NSString).stringByReplacingOccurrencesOfString(finds[i], withString: replaces[i])
        
        }
        finds.removeAll()
        replaces.removeAll()
        
        finds =    ["e*d*","t*o*", "m*e*", "I*", "y*o*u*r*s*", "y*o*u*r*", "m*y*", "y*o*u*", "m*i*n*e*", "a*m*", "a*r*e*"]
        replaces = ["ed","to",  "me", "I",   "yours",  "your", "my", "you",   "mine", "am", "are"]
        for i in 0...finds.count - 1 {
            replaced = (replaced as NSString).stringByReplacingOccurrencesOfString(finds[i], withString: replaces[i])
            
        }
        
        ret = "\(ret) \(middleWord) \(replaced)."
        return ret
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
                                        let query = PFQuery(className: "TurnRecord")
                                        query.whereKey("gameID", equalTo: parentVC.gameID)
                                        
                                        query.findObjectsInBackgroundWithBlock {
                                            (objects: [PFObject]?, error: NSError?) -> Void in
                                            if let objects = objects {
                                                for object in objects {
                                                    object.deleteEventually()
                                                }
                                            }
                                        }
                                        
                                        let parseACL:PFACL = PFACL()
                                        parseACL.publicReadAccess = true
                                        parseACL.publicWriteAccess = true
                                        
                                        let turnRecord = PFObject(className: "TurnRecord")
                                        turnRecord.ACL = parseACL
                                        turnRecord["gameID"] = parentVC.gameID
                                        turnRecord["playerID"] = parentVC.opponentID
                                        turnRecord["text"] = "It's your turn to play against \(parentVC.userName)!"
                                        
                                        turnRecord.saveEventually()
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
