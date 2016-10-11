//
//  ViewControllerContainers.swift
//  Match
//
//  Created by Daniel Pellicone on 6/29/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
//import CloudKit
import Parse
class ViewControllerContainers: UIViewController {
    @IBOutlet weak var topButtonContainer: UIView!
    @IBOutlet weak var topTextContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!
    var containerViewController: ViewController?
    var cards:[CardStruct] = [CardStruct]()
    var gameID:String = String()
    var game:Game = Game()
    weak var updateGameTimer:NSTimer?
    var userID:String = String()
    var tap:UITapGestureRecognizer!
    var opponentID:String = String()
    var opponentName:String = String()
    var userName:String = String()
   // var container:CKContainer?
   // var publicDatabase:CKDatabase?
   // var privateDatabase:CKDatabase?
    var cardSet:Bool = false
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var loadMainView: UIView!
    var oppCard:Card = Card()
    var isSolving:Bool = false
    var initialLoad:Bool = true
    var cardHeight:CGFloat = 100
    var whoseTurn:String = String() {
        didSet {
            if (!self.block || !self.initialLoad)
            {
            let topButtonVC:ViewControllerTopButton = self.childViewControllerWithType(ViewControllerTopButton)!
            let topTextVC:ViewControllerTopText = self.childViewControllerWithType(ViewControllerTopText)!
            print("didSet\(self.whoseTurn)")
            if (topButtonVC.questionTextField.text == "")
            {
                self.turnButtonOff(topButtonVC.button)
            }
            else if !topButtonVC.buttonPressed
            {
                self.turnButtonOn(topButtonVC.button)
            }
            
            // Look at different scenarios for whoseTurn

            if (self.whoseTurn == self.userID)
            {
                if ((self.updateGameTimer?.valid) == true)
                {
                    self.showTopButtonVC()
                    self.hideTopTextVC()
                }
                
            }
            else if (self.whoseTurn == "\(self.userID)waiting")
            {
                self.hideTopButtonVC()
                self.hideTopTextVC()
            }
            else if (self.whoseTurn == "\(self.opponentID)waiting")
            {
                self.turnButtonOn(topTextVC.yesButton)
                self.turnButtonOn(topTextVC.noButton)
                topTextVC.endTurnButton.hidden = true
                self.hideTopButtonVC()
                self.showTopTextVC()
            }
            else if (self.whoseTurn == "\(self.userID)waitingfinished")
            {
                self.hideTopButtonVC()
                self.turnButtonOn(topTextVC.endTurnButton)
                topTextVC.noButton.hidden = true
                topTextVC.yesButton.hidden = true
                self.showTopTextVC()
                topButtonVC.questionTextField.text = ""
                topButtonVC.buttonPressed = false
            }
            else if (self.whoseTurn == "\(self.opponentID)waitingfinished") {
                self.hideTopButtonVC()
                self.hideTopTextVC()
               
            }
            else if self.whoseTurn == "\(self.opponentID)" {
                self.hideTopButtonVC()
                self.hideTopTextVC()
            }
           // self.cardSet = true
            }
        }
    }
 
    var questionText:String = String()
        {
        didSet {
            self.setLabel()
        }
    }
    
    var opponentBoard:[Int] = [Int]() {
        didSet {
            self.childViewControllerWithType(ViewControllerBase)?.collectionView.reloadData()
        }
    }
    var player2:String = String()
    var player2Board = [Int]()
    var player1Board = [Int]()
        {
        didSet {
            if (self.userID == self.gameID)
            {
                self.opponentBoard = self.player2Board
            }
            else{
                self.opponentBoard = self.player1Board
            }
        }
    }
   
    @IBOutlet weak var endScreenView: UIVisualEffectView!
    
   
    @IBOutlet weak var endScreenLabel: UILabel!
    
    @IBOutlet weak var endScreenCard: UIView!
    var myOpponentsCard:Card = Card()
    var endOfGame:String = String() {
        didSet {
            if self.endOfGame == self.userID {
                
                self.endScreenView.hidden = false
                self.myOpponentsCard.removeConstraints(self.myOpponentsCard.constraints)
                self.myOpponentsCard.applySizeConstraintToImageView(self.myOpponentsCard.backImageView)
                self.myOpponentsCard.applyPositioningConstraintToImageView(self.myOpponentsCard.backImageView)
                self.myOpponentsCard.applySizeConstraintToProfImageView(self.myOpponentsCard.profImageView)
                self.myOpponentsCard.applyPositioningConstraintToOppProfImageView(self.myOpponentsCard.profImageView)
                self.myOpponentsCard.applySizeConstraintToImageView(self.myOpponentsCard.frontImageView)
                self.myOpponentsCard.applyPositioningConstraintToImageView(self.myOpponentsCard.frontImageView)
                self.myOpponentsCard.setConstraintsUILabelOppCard(self.myOpponentsCard.personNameLabel)
                self.myOpponentsCard.frontImageView.image = UIImage(named: "oppcard")
                self.myOpponentsCard.backImageView.image = UIImage(named: "oppcard")
                self.myOpponentsCard.personNameLabel.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
                self.myOpponentsCard.personNameLabel.adjustsFontSizeToFitWidth = true
                self.endScreenCard.addSubview(self.myOpponentsCard)
                self.myOpponentsCard.bindFrameToSuperviewBounds()
            }
            if self.endOfGame == self.opponentID {
                self.updateGameTimer?.invalidate()
                self.endScreenView.hidden = false
                self.myOpponentsCard.removeConstraints(self.myOpponentsCard.constraints)
                self.myOpponentsCard.applySizeConstraintToImageView(self.myOpponentsCard.backImageView)
                self.myOpponentsCard.applyPositioningConstraintToImageView(self.myOpponentsCard.backImageView)
                self.myOpponentsCard.applySizeConstraintToProfImageView(self.myOpponentsCard.profImageView)
                self.myOpponentsCard.applyPositioningConstraintToOppProfImageView(self.myOpponentsCard.profImageView)
                self.myOpponentsCard.applySizeConstraintToImageView(self.myOpponentsCard.frontImageView)
                self.myOpponentsCard.applyPositioningConstraintToImageView(self.myOpponentsCard.frontImageView)
                self.myOpponentsCard.setConstraintsUILabelOppCard(self.myOpponentsCard.personNameLabel)
                self.myOpponentsCard.frontImageView.image = UIImage(named: "oppcard")
                self.myOpponentsCard.backImageView.image = UIImage(named: "oppcard")
                self.myOpponentsCard.personNameLabel.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
                self.myOpponentsCard.personNameLabel.adjustsFontSizeToFitWidth = true
                self.endScreenLabel.text = "You Lost!"
                self.endScreenCard.addSubview(self.myOpponentsCard)
                self.myOpponentsCard.bindFrameToSuperviewBounds()
            }
        }
    }
    var block:Bool = false
    var randomize:Bool = true
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var solveLabel: UILabel!
    @IBOutlet weak var quitButton: UIButton!
    
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
   
    override func viewDidLoad() {
        if (self.presentingViewController != nil) {
            (self.presentingViewController as! ViewControllerFriends).timer!.invalidate()
            (self.presentingViewController as! ViewControllerFriends).refreshTimer!.invalidate()
        }
        self.presentingViewController?.dismissViewControllerAnimated(false, completion: {})
        super.viewDidLoad()
        self.endScreenView.hidden = true
        self.solveLabel.hidden = true
        self.view.userInteractionEnabled = false
        let contentViewHeightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: self.contentView, attribute: NSLayoutAttribute.Width, multiplier: 1.12, constant: 0)
        self.contentView.addConstraint(contentViewHeightConstraint)
    //    self.container = CKContainer.defaultContainer()
    //    self.publicDatabase = self.container?.publicCloudDatabase
    //    self.privateDatabase = self.container?.privateCloudDatabase
        // Add height constraint to the content view so scrollview knows how much to scroll
        
     //   self.whoseTurn = "pause"
        self.game.vC = self
        self.game.getBoard()
        //Looks for single or multiple taps.
        self.tap = UITapGestureRecognizer(target: self, action: #selector(ViewControllerContainers.dismissKeyboard))
      //  self.tap.cancelsTouchesInView = true
        self.view.addGestureRecognizer(self.tap)
       self.quitButton.addTarget(self, action: #selector(ViewControllerContainers.deleteGamesButtonAction), forControlEvents: UIControlEvents.TouchUpInside)
        self.returnButton.addTarget(self, action: #selector(ViewControllerContainers.returnButtonAction), forControlEvents: UIControlEvents.TouchUpInside)
      //  self.oppCard.personName = self.cards[randCardNum].personName
      //  self.oppCard.profilePicture = self.cards[randCardNum].profilePicture
       // self.oppCard.profPicURL = self.cards[randCardNum].profilePictureURL
       
        
        if (self.userID == self.gameID) {
           
       self.oppCard.removeConstraints(self.oppCard.constraints)
            self.oppCard.applySizeConstraintToImageView(self.oppCard.backImageView)
            self.oppCard.applyPositioningConstraintToImageView(self.oppCard.backImageView)
            self.oppCard.applySizeConstraintToProfImageView(self.oppCard.profImageView)
            self.oppCard.applyPositioningConstraintToProfImageView(self.oppCard.profImageView)
            self.oppCard.applySizeConstraintToImageView(self.oppCard.frontImageView)
            self.oppCard.applyPositioningConstraintToOppImageView(self.oppCard.frontImageView)
            self.oppCard.setConstraintsUILabelOppCard(self.oppCard.personNameLabel)
     self.oppCard.frontImageView.image = UIImage(named: "oppcard")
        
       
        //cards[randCardNum]
        self.childViewControllerWithType(ViewControllerBase)!.oppCardView.addSubview(oppCard)
        
    
      
        self.oppCard.bindFrameToSuperviewBounds()
        }
        else if self.oppCard.personName != "" {
            self.oppCard.removeConstraints(self.oppCard.constraints)
            self.oppCard.applySizeConstraintToImageView(self.oppCard.backImageView)
            self.oppCard.applyPositioningConstraintToImageView(self.oppCard.backImageView)
            self.oppCard.applySizeConstraintToProfImageView(self.oppCard.profImageView)
            self.oppCard.applyPositioningConstraintToProfImageView(self.oppCard.profImageView)
            self.oppCard.applySizeConstraintToImageView(self.oppCard.frontImageView)
            self.oppCard.applyPositioningConstraintToOppImageView(self.oppCard.frontImageView)
            self.oppCard.setConstraintsUILabelOppCard(self.oppCard.personNameLabel)
            self.oppCard.frontImageView.image = UIImage(named: "oppcard")
            
            
            //cards[randCardNum]
            self.childViewControllerWithType(ViewControllerBase)!.oppCardView.addSubview(oppCard)
            
            
            
            self.oppCard.bindFrameToSuperviewBounds()
        }
        else  {
            self.childViewControllerWithType(ViewControllerBase)!.oppCardView.hidden = true
        }
        self.game.updateRecord()
        self.updateGameTimer?.invalidate()
        self.updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self.game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)

    }
     override func viewWillAppear(animated: Bool) {
        self.game.getBoard()
        self.game.updateRecord()
        
        self.updateGameTimer?.invalidate()
        self.updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self.game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)

    }
    func turnButtonOff(button:UIButton) {
        button.userInteractionEnabled = false
        button.hidden = false
        button.alpha = 0.2
    }
    func turnButtonOn(button:UIButton)
    {
        button.userInteractionEnabled = true
        button.hidden = false
        button.alpha = 1.0
    }
    func showTopButtonVC() {
        self.topButtonContainer.hidden = false
      //  let notHiddenHeight:CGFloat = self.titleContainer.frame.size.height
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:
            {
                self.topButtonContainer.frame.origin.y = 0
            }, completion: {
                finished in
                    self.solveButtonEnabled()
                })
    }
    func showTopTextVC() {
        self.topTextContainer.hidden = false
 //       let notHiddenHeight:CGFloat = self.titleContainer.frame.size.height
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.topTextContainer.frame.origin.y = 0
            self.setLabel()
            }, completion: nil)
    }
    
    func hideTopButtonVC() {
        self.solveButtonDisabled()
        let hiddenHeight:CGFloat = self.titleContainer.frame.size.height
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.topButtonContainer.frame.origin.y = -(hiddenHeight)
            }, completion: nil)
    }
    func hideTopTextVC() {
        let hiddenHeight:CGFloat = self.titleContainer.frame.size.height
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.topTextContainer.frame.origin.y = -(hiddenHeight)
            }, completion: nil)
    }
    func solveButtonPressed() {
        self.hideTopButtonVC()
        self.updateGameTimer?.invalidate()
        self.isSolving = true
        self.childViewControllerWithType(ViewControllerTopButton)?.questionTextField.text = ""
        self.waitingLabel.hidden = true
        self.solveLabel.hidden = false
        
        
        

        self.solveButtonDisabled()
      //  dispatch_async(dispatch_get_main_queue()) { self.waitingLabel.text = "Tap a card to make your guess."}
        print("solve button")
                
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.updateGameTimer?.invalidate()
        self.updateGameTimer = nil
    
    }
    func saveYourCard() {
       /* print("SAVING CARD")
        let predicate = NSPredicate(format: "gameID == '\(self.gameID)'")
        var playerString:String = "player2"
        if self.gameID == self.userID {
            playerString = "player1"
        }
        self.publicDatabase!.performQuery(CKQuery(recordType: "Game", predicate: predicate), inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
            if error != nil {
                print(error?.localizedDescription)
                self.saveYourCard()
            }
            else if records != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    if (records?.count > 0)
                    {
                        let gameRecord:CKRecord = records![0]
                        gameRecord["\(playerString)CardID"] = self.oppCard.profPicURL
                        gameRecord["\(playerString)CardName"] = self.oppCard.personName
                       //} self.cardSet = true
                        self.publicDatabase?.saveRecord(gameRecord) { (record, error) in if error != nil {
                            self.saveYourCard()
                            }}
                        
                    }
                    else {
                         self.saveYourCard()
                    }
                    
                }
                
            }
            
            
        })
    */
    
    }
    func solveButtonDisabled() {
        let solveButtonView:UIView = self.childViewControllerWithType(ViewControllerBase)!.solveButtonView
        if solveButtonView.userInteractionEnabled != false {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                solveButtonView.alpha = 0.2
                }, completion: {finished in solveButtonView.userInteractionEnabled = false})
        }
    }
    
    func solveButtonEnabled() {
        let solveButtonView:UIView = self.childViewControllerWithType(ViewControllerBase)!.solveButtonView
        
        if solveButtonView.userInteractionEnabled != true && solveButtonView.alpha != 1 {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                solveButtonView.alpha = 1.0
                }, completion: {finished in solveButtonView.userInteractionEnabled = true})
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
        (self.childViewControllerWithType(ViewController))!.view.userInteractionEnabled = true
        //tap.cancelsTouchesInView
    }
    func deleteGamesButtonAction() {
        // print(self.userID!)
        
        PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": self.opponentID , "message": "\(self.userName) resigned!"])
        let queryTurn = PFQuery(className: "TurnRecord")
        queryTurn.whereKey("gameID", equalTo: self.gameID)
        
        queryTurn.findObjectsInBackgroundWithBlock {
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
        
        let gameOver = PFObject(className: "GameOver")
        gameOver.ACL = parseACL
        gameOver["gameID"] = self.gameID
        gameOver["winner"] = self.opponentID
        
        
        gameOver.saveEventually()
        
        
        let query = PFQuery(className: "Game")
        query.whereKey("gameID", equalTo: self.gameID)
        query.whereKey("player2", equalTo: self.player2)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                for object in objects {
                    object.deleteEventually()
                }
            }
        }
        let query2 = PFQuery(className: "PlayerBoard")
        query2.whereKey("gameID", equalTo: "\(self.gameID)\(self.player2)")
      //  query2.whereKey("gameID", equalTo: self.gameID)
        query2.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                for object in objects {
                    object.deleteEventually()
                }
            }
        }
        performSegueWithIdentifier("goBackToFriends", sender: self)
        /*   let query = CKQuery(recordType: "Game", predicate: NSPredicate(value: true))
         self.publicDatabase!.performQuery(query, inZoneWithID: nil) { (records, error) in
         
         if error == nil {
         
         for record in records! {
         
         self.publicDatabase!.delete(withRecordID: record.recordID, completionHandler: { (record, error) in
         
         })                }
         
         }
         
         }*/
    }
    func returnButtonAction() {
        // print(self.userID!)
       // PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": self.opponentID , "message": "Your opponent resigned!"])
        if (endOfGame == self.opponentID) {
        let query = PFQuery(className: "Game")
        query.whereKey("gameID", equalTo: self.gameID)
        query.whereKey("player2", equalTo: self.player2)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                for object in objects {
                    object.deleteEventually()
                }
            }
        }
        let query2 = PFQuery(className: "PlayerBoard")
        query2.whereKey("gameID", equalTo: "\(self.gameID)\(self.player2)")
        //  query2.whereKey("gameID", equalTo: self.gameID)
        query2.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                for object in objects {
                    object.deleteEventually()
                }
            }
        }
            let query3 = PFQuery(className: "TurnRecord")
            query3.whereKey("gameID", equalTo: "\(self.gameID)")
            //  query2.whereKey("gameID", equalTo: self.gameID)
            query3.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if let objects = objects {
                    for object in objects {
                        object.deleteEventually()
                    }
                }
            }
        }
        else {
           // PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": self.opponentID , "message": "You lost!"])
        }
        performSegueWithIdentifier("goBackToFriends", sender: self)
        /*   let query = CKQuery(recordType: "Game", predicate: NSPredicate(value: true))
         self.publicDatabase!.performQuery(query, inZoneWithID: nil) { (records, error) in
         
         if error == nil {
         
         for record in records! {
         
         self.publicDatabase!.delete(withRecordID: record.recordID, completionHandler: { (record, error) in
         
         })                }
         
         }
         
         }*/
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // you can set this name in 'segue.embed' in storyboard
        self.game.gameID = self.gameID
        self.game.player2 = self.player2
        self.game.updateRecord()
        self.childViewControllerWithType(ViewControllerTitle)?.titleLabel.text = self.opponentName
        if segue.identifier == "showBoardContainer" {
            let connectContainerViewController = segue.destinationViewController as! ViewController
            connectContainerViewController.gameModel.randomize = self.randomize
            connectContainerViewController.gameModel.cards = self.cards
          
            self.containerViewController = connectContainerViewController
            self.containerViewController?.gameID = self.gameID
            self.containerViewController?.userID = self.userID
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    
    
    func setLabel() {
        
            
                //print("didSet")
                print(self.questionText)
                if ("\(self.opponentID)waiting" == self.whoseTurn) {
                    if (self.questionText == ""){
                        self.childViewControllerWithType(ViewControllerTopText)?.textView.text = ""
                    }
                    else {
                        self.childViewControllerWithType(ViewControllerTopText)?.textView.text = "\(self.questionText)"
                    }
                }
                else {
                     if (self.questionText.containsString("my person")){
                        self.childViewControllerWithType(ViewControllerTopText)?.textView.text = "\(self.questionText)"
                    }
                     else {
                        self.childViewControllerWithType(ViewControllerTopText)?.textView.text = ""
                    }
                }
        
        
            
        

        }
   }
