//
//  ViewControllerFriends.swift
//  Match
//
//  Created by Daniel Pellicone on 6/21/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
//import CloudKit
import Parse
class ViewControllerFriends: UIViewController, FBSDKLoginButtonDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var navButton: UIButton!
    
    @IBOutlet weak var friendsLabel: UILabel!
   
    @IBOutlet weak var tableViewFriends: UITableView!
    @IBOutlet var tableView: UITableView!
  //  var container:CKContainer?
   // var publicDatabase:CKDatabase?
    //var privateDatabase:CKDatabase?
    var userName:String = ""
    var randList:[Int] = [Int]()
    var userEmailID = ""
    var myFriendsOnAppURLs:[String] = [String]()
    var progressCount:Int = 0
    var inviteFriendURLs:[String] = [String]()
    var gameIDs:[String] = [String]()
    var opponentIDs:[String] = [String]()
    var notEnoughFriends:Bool = false
    var randListSize:Int = 20 {
        didSet {
            self.randList.removeAll(keepCapacity: false)
            for _ in 0...(self.randListSize - 1) {
                var randNum = Int(arc4random_uniform(UInt32(self.randListSize)))
                while (self.randList.contains(randNum)) {
                    var newRandNum:Int = randNum + 1
                    if (newRandNum >= self.randListSize) {
                        newRandNum = 0
                    }
                    randNum = newRandNum
                }
                
                self.randList.append(randNum)
                
                //   print(randList)
            }

        }
    }
    var player1OppCard:Card = Card()
    var userEmailKey:String = "" {
        didSet {
            if (self.userEmailKey != "") {
                   self.setSubscription()
                    self.deleteAllInvites(self.userEmailKey)
            }
        }
    }
    weak var destVC:ViewControllerContainers!
    var profilePic:String = ""
    var userFriends:[String] = [String]()
    var myFriendsOnApp:[String] = [String]()
    //var myFriendsOnAppEmails:[String] = [String]()
    var myFriendsOnAppIDs:[String] = [String]()
    var l:String = "AASDF"
    //var recordIDs:[CKRecordID] = [CKRecordID]()
    var recordInvites:[String] = [String]()
    var invitingThisCellFriend:String = String()
    var inviteFriendIDs:[String] = [String]()
    var inviteFriendFriends:[[String]] = [[String]]()
    var inviteFriendFriendNames:[[String]] = [[String]]()
    var userFriendURLs:[String] = [String]()
    var userFriendIDs:[String] = [String]()
    var userFriendIDsDict:[String:String] = [String:String]()
    var mutualCards:[CardStruct] = [CardStruct]()
    var sendMutualCards:[CardStruct] = [CardStruct]()
    var invitingThisCellOpponentID:String = String()
    weak var refreshTimer:NSTimer?
    var friendFriendIDsCount = 0
    var gameNames = [String]()
    var gameURLs = [String]()
    var opponentName = String()
    @IBOutlet weak var deleteGameButton: UIButton!
    @IBOutlet weak var collectionViewFriends: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var inviteFriendView: UIImageView!
    @IBOutlet weak var noFriendsImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var tableViewGames: UITableView!
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var gameFriendView: UIImageView!
    var sendThisGameID:String = String()
    
    var gameIDsIDs:[String] = [String]()
    
    
    weak var timer:NSTimer!
    override func viewDidLoad() {
        
        if (self.presentingViewController != nil) {
        (self.presentingViewController as! ViewControllerContainers).updateGameTimer!.invalidate()
        }
         self.presentingViewController?.dismissViewControllerAnimated(false, completion: {})
        super.viewDidLoad()
       
      //  self.noFriendsImageView.alpha = 0.0
        
        self.loadingView.hidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.progressView.progress = 0
        self.collectionViewFriends.delegate = self
        self.collectionViewFriends.dataSource = self
        self.tableViewGames.delegate = self
        self.tableViewGames.dataSource = self
        self.okButton.addTarget(self, action: #selector(ViewControllerFriends.pressOKButton), forControlEvents: UIControlEvents.TouchUpInside)
        print("viewDidLoad")
        //self.getGameIDs()
      //  self.deleteGameButton.addTarget(self, action: #selector(ViewControllerFriends.deleteGamesButtonAction), forControlEvents: UIControlEvents.TouchUpInside)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.myViewController = self
   //     self.container = CKContainer.defaultContainer()
     //   self.publicDatabase = self.container?.publicCloudDatabase
      //  self.privateDatabase = self.container?.privateCloudDatabase
        

       
     //   let loginButton = FBSDKLoginButton()
     //   self.view.addSubview(loginButton)
      //  loginButton.translatesAutoresizingMaskIntoConstraints = false
      //  loginButton.readPermissions = ["public_profile", "email", "user_friends"]
     //   navButton.addTarget(self, action: #selector(ViewControllerFriends.refreshInvitesButton), forControlEvents: UIControlEvents.TouchUpInside)
     //   loginButton.delegate = self
    //    let bottomMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -10)
   //     let centerXConstraint:NSLayoutConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
     //   self.view.addConstraints([bottomMarginConstraint, centerXConstraint])
        self.randListSize = 20
        
      //  self.refreshTimer?.invalidate()
        //self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(ViewControllerFriends.refreshInvitesButton), userInfo: nil, repeats: true)
                // Do any additional setup after loading the view.
           }
   
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(1.5, animations: {
                
         self.tableViewGames.alpha = 1.0
                self.tableView.alpha = 1.0
                    self.collectionViewFriends.alpha = 1.0
              //      self.noFriendsImageView.alpha = 0.0
             //   self.inviteFriendView.alpha = 0.0
                
            })
        }
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            UIView.animateWithDuration(1.5, animations: {
                
                if self.myFriendsOnApp.count == 0 {
                    
                    self.noFriendsImageView.alpha = 0.2
                    
                }
               if self.recordInvites.count == 0 {
                 self.inviteFriendView.alpha = 0.2
                }
                if self.gameNames.count == 0 {
                    self.gameFriendView.alpha = 0.2
                }
            })
            
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tick() {
        self.progressView.progress = Float(self.progressCount) / (Float(self.friendFriendIDsCount))
        if self.progressView.hidden == false && self.progressView.progress >= 0.99 {
            dispatch_async(dispatch_get_main_queue()) {
                 self.progressView.hidden = true
                self.activityIndicatorView.hidden = false
                self.loadingLabel.text = "Starting game..."
            }
           
        }
        if notEnoughFriends {
            dispatch_async(dispatch_get_main_queue()) {
                self.progressView.hidden = true
                self.activityIndicatorView.hidden = true
                self.okButton.hidden = false
                self.loadingLabel.text = "You and \(self.opponentName) need more mutual friends to play!"
            }
        }
    }
    
    func pressOKButton() {
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView.hidden = true
            self.activityIndicatorView.hidden = true
            self.okButton.hidden = true
            self.loadingView.hidden = true
            self.notEnoughFriends = false
            self.viewWillAppear(false)
        }
    }
    func deleteAllInvites(id:String) {
        let query = PFQuery(className:"GameInstance")
        query.whereKey("userEmail", equalTo: id)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                
                
                for object in objects! {
                    object.deleteInBackgroundWithBlock({ (f, error) in
                        //object delete
                        print("record deleted")
                    })
                    //print("record deleted")
                    
                }
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            
            
            
            
        }
    }
    
    func deleteThisGameInvite(userEmail:String, opponentEmail:String) {
        let query = PFQuery(className:"GameInstance")
        query.whereKey("userEmail", equalTo: userEmail)
        query.whereKey("opponentEmail", equalTo: opponentEmail)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                
                
                for object in objects! {
                    object.deleteEventually()
                    //print("record deleted")
                    
                }
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            
            
            
            
        }
    }
    
    //table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tableView) {
            
            dispatch_async(dispatch_get_main_queue()) {
                if self.recordInvites.count != 0 {
                    self.inviteFriendView.alpha = 0.0
                }
                UIView.animateWithDuration(1.5, animations: {
                    
                 if self.recordInvites.count != 0 {                    self.tableView.alpha = 1.0
                    
                    }
                    
                    
                })
            }
            let seconds = 2.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                
                UIView.animateWithDuration(1.5, animations: {
                    
                    if self.recordInvites.count == 0 {
                        
                        self.inviteFriendView.alpha = 0.2
                    }
                   
                    
                    
                })
                
            })
            return self.recordInvites.count
        }
        else if (tableView == self.tableViewGames) {
            dispatch_async(dispatch_get_main_queue()) {
                if self.gameNames.count != 0 {
                    self.gameFriendView.alpha = 0.0
                }
                UIView.animateWithDuration(1.5, animations: {
                    
                    
                        self.tableViewGames.alpha = 1.0
                    
                    
                    
                    
                })
            }
            let seconds = 2.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                
                UIView.animateWithDuration(1.5, animations: {
                    
                    if self.gameNames.count == 0 {
                        
                        self.gameFriendView.alpha = 0.2
                    }
                    
                    
                    
                })
                
            })

            return self.gameNames.count
        }
        return self.myFriendsOnApp.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView == self.tableView) {
            let cell:inviteListCell = tableView.dequeueReusableCellWithIdentifier("Cell")! as! inviteListCell
            cell.textView.text = self.recordInvites[indexPath.row]
          //  cell.profPicView.image =
            
            let data = NSData(contentsOfURL: NSURL(string: self.inviteFriendURLs[indexPath.row])!)
          //  var cell1 = cell as! inviteListCell
            cell.profPicView.image = (UIImage(data: data!)! as UIImage)
            
            
            // cell.imageView?.image =
            return cell
        }
        if (tableView == self.tableViewGames) {
            let cell:GameListCell = tableView.dequeueReusableCellWithIdentifier("cellGame")! as! GameListCell
            cell.textView.text = self.gameNames[indexPath.row]
            
            
            let data = NSData(contentsOfURL: NSURL(string: self.gameURLs[indexPath.row])!)
           
            cell.profPicView.image = (UIImage(data: data!)! as UIImage)
            
            
           
            return cell
        }
        return UITableViewCell()
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.refreshTimer?.invalidate()
        if (tableView == self.tableView) {
      
        
            self.opponentName = self.recordInvites[indexPath.row]
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                dispatch_sync(dispatch_get_main_queue()) {
                    self.activityIndicatorView.hidden = true
                    self.progressView.hidden = false
                    self.loadingLabel.text = "Setting up board..."
                    self.loadingView.hidden = false
                    self.loadingView.setNeedsDisplay()
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewControllerFriends.tick), userInfo: nil, repeats: true)
                }
            print("hide")
                self.invitingThisCellOpponentID = self.inviteFriendIDs[indexPath.row]
        print("2")
            
                //All stuff here
                self.mutualCards = self.setMutualFriends(self.inviteFriendFriends[indexPath.row], index: indexPath.row)
                if (self.mutualCards.count >= 20){
                print("3")
                dispatch_sync(dispatch_get_main_queue()) {
                    
                         self.createGameRecord()
                
        print("4")
        self.performSegueWithIdentifier("showGame", sender: self)
                print("5")
                    }
                }
                else {
                    PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": self.invitingThisCellOpponentID, "message": "You don't have enough mutual friends with \(self.userName) to play."])
                    self.notEnoughFriends = true
                    print("not enough mutual friends")
                }
        })
        }
        else if (tableView == self.tableViewGames) {
            self.opponentName = self.gameNames[indexPath.row]
            self.sendThisGameID = self.gameIDsIDs[indexPath.row]
            let destination0VC:ViewControllerContainers = ViewControllerContainers()
         
            let parseACL:PFACL = PFACL()
            parseACL.publicReadAccess = true
            parseACL.publicWriteAccess = true
            let queryBoard = PFQuery(className: "PlayerBoard")
            //queryBoard.whereKey("gameID", equalTo: self.sendThisGameID)
            queryBoard.whereKey("playerID", equalTo: self.userEmailKey)
            let query = PFQuery(className:"Game")
           // query.whereKey("gameID", equalTo: self.sendThisGameID)
          //  query.whereKey("player1", equalTo: self.gameIDsIDs[indexPath.row])
            //query.whereKey("player2", equalTo: self.userEmailKey)
            //TODO: make sure we get the game with player2
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects {
                        if objects.count > 0 {
                            for i in 0...objects.count - 1 {
                            let record = objects[i]
                            record.ACL = parseACL
                            if (record["player1"] as! String == self.userEmailKey && self.gameIDsIDs[indexPath.row] == record["player2"] as! String) || (record["player2"] as! String == self.userEmailKey && self.gameIDsIDs[indexPath.row] == record["player1"] as! String){
                             queryBoard.whereKey("gameID", equalTo: "\(record["gameID"])\(record["player2"])")
                            queryBoard.findObjectsInBackgroundWithBlock {
                            (objectsBoard: [PFObject]?, error: NSError?) -> Void in
                                if let objectsBoard = objectsBoard {
                                    if objectsBoard.count > 0 {
                            
                                        let recordBoard = objectsBoard[0]
                                        recordBoard.ACL = parseACL
                                        
                            
                            var playerBoard:[Int] = [Int]()
                            destination0VC.gameID = record.objectForKey("gameID") as! String
                            destination0VC.player2 = record.objectForKey("player2") as! String
                            destination0VC.userID = self.userEmailKey
                            var cardStructPersonNameList = [String]() //record.objectForKey("cardStructPersonNameList") as! [String]
                            var cardStructProfilePictureList = [String]() //record.objectForKey("cardStructProfilePictureList") as! [String]
                            if self.userEmailKey == destination0VC.gameID
                            {
                                destination0VC.oppCard.personName = record.objectForKey("player1CardName") as! String
                                destination0VC.oppCard.profPicURL = record.objectForKey("player1CardID") as! String
                                playerBoard = recordBoard.objectForKey("board") as! [Int]
                                let data = NSData(contentsOfURL: NSURL(string: destination0VC.oppCard.profPicURL)!)
                                destination0VC.oppCard.profilePicture = UIImage(data: data!)! as UIImage
                                cardStructPersonNameList = record.objectForKey("shuffledNames") as! [String]
                                cardStructProfilePictureList = record.objectForKey("shuffledIDs") as! [String]
                                
                            }
                            else
                            {
                                destination0VC.oppCard.personName = record.objectForKey("player2CardName") as! String
                                destination0VC.oppCard.profPicURL = record.objectForKey("player2CardID") as! String
                                playerBoard = recordBoard.objectForKey("board") as! [Int]
                                let data = NSData(contentsOfURL: NSURL(string: destination0VC.oppCard.profPicURL)!)
                                destination0VC.oppCard.profilePicture = UIImage(data: data!)! as UIImage
                                cardStructPersonNameList = record.objectForKey("shuffledNames2") as! [String]
                                cardStructProfilePictureList = record.objectForKey("shuffledIDs2") as! [String]
                                
                            }
                            
                            var cards = [CardStruct]()
                            for i in 0...cardStructPersonNameList.count - 1 {
                                var card:CardStruct = CardStruct()
                                card.profilePictureURL = cardStructProfilePictureList[i]
                                card.personName = cardStructPersonNameList[i]
                                if playerBoard[i] == 0 {
                                    card.isFlipped = true
                                }
                                let data = NSData(contentsOfURL: NSURL(string: card.profilePictureURL)!)
                                card.profilePicture = UIImage(data: data!)! as UIImage
                                
                                cards.append(card)
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                destination0VC.cards = cards
                                destination0VC.initialLoad = false
                                //  destination0VC.whoseTurn = record.objectForKey("whoseTurn") as! String
                                self.destVC = destination0VC
                                
                                
                                
                                self.performSegueWithIdentifier("showGame22", sender: self)
                                            }
                            
                            
                     //       record.saveInBackgroundWithBlock { (success, error) -> Void in
                     //           PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": opponentEmail , "message": "\(self.userName) wants to play Guesses with you!"])
                     //           print("push")}
                    //    }
                                        }
                        }
                            }
                                }}
                        }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
                }
            }
        }
        
                
                
            
            /*******************************************
            let predicate = NSPredicate(format: "%K == %@", "gameID", self.sendThisGameID)
            print(predicate.predicateFormat)
            // better be accurate to get only the record you need
            let query = CKQuery(recordType: "Game", predicate: predicate)
            
            self.publicDatabase!.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
                if error != nil {
                    print("Error querying records: \(error!.localizedDescription)")
                }
                else  {
                    
                        
                        
                        for record in records! {
                            var playerBoard:[Int] = [Int]()
                            destination0VC.gameID = record.objectForKey("gameID") as! String
                            destination0VC.userID = self.userEmailKey
                            var cardStructPersonNameList = [String]() //record.objectForKey("cardStructPersonNameList") as! [String]
                            var cardStructProfilePictureList = [String]() //record.objectForKey("cardStructProfilePictureList") as! [String]
                            if self.userEmailKey == destination0VC.gameID
                            {
                                destination0VC.oppCard.personName = record.objectForKey("player1CardName") as! String
                                destination0VC.oppCard.profPicURL = record.objectForKey("player1CardID") as! String
                                playerBoard = record.objectForKey("player1Board") as! [Int]
                                let data = NSData(contentsOfURL: NSURL(string: destination0VC.oppCard.profPicURL)!)
                                destination0VC.oppCard.profilePicture = UIImage(data: data!)! as UIImage
                                cardStructPersonNameList = record.objectForKey("shuffledNames") as! [String]
                                cardStructProfilePictureList = record.objectForKey("shuffledIDs") as! [String]
                                
                            }
                            else
                            {
                                destination0VC.oppCard.personName = record.objectForKey("player2CardName") as! String
                                destination0VC.oppCard.profPicURL = record.objectForKey("player2CardID") as! String
                                playerBoard = record.objectForKey("player2Board") as! [Int]
                                let data = NSData(contentsOfURL: NSURL(string: destination0VC.oppCard.profPicURL)!)
                                destination0VC.oppCard.profilePicture = UIImage(data: data!)! as UIImage
                                cardStructPersonNameList = record.objectForKey("shuffledNames2") as! [String]
                                cardStructProfilePictureList = record.objectForKey("shuffledIDs2") as! [String]
                                
                            }
                          
                            var cards = [CardStruct]()
                            for i in 0...cardStructPersonNameList.count - 1 {
                                var card:CardStruct = CardStruct()
                                card.profilePictureURL = cardStructProfilePictureList[i]
                                card.personName = cardStructPersonNameList[i]
                                if playerBoard[i] == 0 {
                                    card.isFlipped = true
                                }
                                let data = NSData(contentsOfURL: NSURL(string: card.profilePictureURL)!)
                                card.profilePicture = UIImage(data: data!)! as UIImage
                                
                                cards.append(card)
                            }
                             dispatch_async(dispatch_get_main_queue()) {
                            destination0VC.cards = cards
                            destination0VC.initialLoad = false
                          //  destination0VC.whoseTurn = record.objectForKey("whoseTurn") as! String
                            self.destVC = destination0VC
                            
                           
                                
                                       self.performSegueWithIdentifier("showGame22", sender: self)
                            }
                            
                            
                    }
                    

                    
                    
                    
                    
                }
            })
         */  //***********************************
  
            
           
            
            
            
            
            
        //self.loadingView.hidden = true
        
    }
    func refreshInvitesButton() {
        self.getGameIDs()
        self.refreshInvites()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.refreshTimer != nil {
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
        }
        if self.timer != nil {
        self.timer?.invalidate()
        self.timer = nil
        }
    }
 
    override func viewWillAppear(animated: Bool) {
        if FBSDKAccessToken.currentAccessToken() == nil {
            print("Not Logged in..")
        }
        else {
            print("Logged in..")
        }
        
        self.setUserFriends()
        
        self.setProfInfo()
        self.getGameIDs()
        self.refreshTimer?.invalidate()
         self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewControllerFriends.refreshInvitesButton), userInfo: nil, repeats: true)
        self.timer?.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewControllerFriends.tick), userInfo: nil, repeats: true)
        
    }
    
    func navButtonAction() {
        self.performSegueWithIdentifier("showGame", sender: self)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            print("Login complete")
            print(self.userEmailKey)

        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        dispatch_async(dispatch_get_main_queue()) {
            if self.myFriendsOnApp.count != 0 {
                
                self.noFriendsImageView.alpha = 0.0
            }
            UIView.animateWithDuration(1.5, animations: {
                
                
                self.collectionViewFriends.alpha = 1.0
                
                
                
            })
        }
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            UIView.animateWithDuration(1.5, animations: {
                
                if self.myFriendsOnApp.count == 0 {
                    
                    self.noFriendsImageView.alpha = 0.2
                }
               
                
                
            })
            
        })

        return self.myFriendsOnApp.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = self.collectionViewFriends.dequeueReusableCellWithReuseIdentifier("friendCell", forIndexPath: indexPath) as UICollectionViewCell
        let cellFriend = cell as! FriendCollect
        if (collectionView == self.collectionViewFriends) {
            
            //dispatch_async(dispatch_get_main_queue()) {
            var nameSplit:[String] = self.myFriendsOnApp[indexPath.row].characters.split(" ").map(String.init)
                cellFriend.friendNameLabel.text = nameSplit[0]
            let data = NSData(contentsOfURL: NSURL(string: self.myFriendsOnAppURLs[indexPath.row])!)
                cellFriend.profilePicView.image = UIImage(data: data!)! as UIImage
               // cellFriend.hidden = false
               // cellFriend.profilePicView.image =
           // }
            
            //self.refreshInvites()
           // self.saveRecord((self.myFriendsOnApp[indexPath.row]), opponentEmail: self.myFriendsOnAppIDs[indexPath.row])
           // (self.collectionViewFriends.viewWithTag(5) as! UILabel).text = self.myFriendsOnApp[indexPath.row]
          //  self.invitingThisCellOpponentID = self.myFriendsOnAppIDs[indexPath.row]
           // self.invitingThisCellFriend = self.userEmailKey
           // self.performSegueWithIdentifier("showInvite", sender: self)
        }
        cellFriend.layoutIfNeeded()
        return cellFriend as UICollectionViewCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView == self.collectionViewFriends) {
           // let cellFriend:UICollectionViewCell = self.collectionViewFriends.cellForItemAtIndexPath(indexPath)!//.cellForRowAtIndexPath(indexPath)!
             self.opponentName = self.myFriendsOnApp[indexPath.row]
            self.saveRecord(self.myFriendsOnApp[indexPath.row], opponentEmail: self.myFriendsOnAppIDs[indexPath.row])
            self.invitingThisCellOpponentID = self.myFriendsOnAppIDs[indexPath.row]
            self.invitingThisCellFriend = self.userEmailKey
            self.performSegueWithIdentifier("showInvite", sender: self)
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.performSegueWithIdentifier("showLogin", sender: self)
     //   self.setSubscription()
     //    _ = UIApplication.sharedApplication().delegate as! AppDelegate
     
        print("User logged out")
        
    }
    
    func saveRecord(opponentName:String, opponentEmail: String) {
    
        //***************************************************************************
        // PARSE CODE
        //***************************************************************************
        let parseACL:PFACL = PFACL()
        parseACL.publicReadAccess = true
        parseACL.publicWriteAccess = true
        let query = PFQuery(className:"GameInstance")
        query.whereKey("userEmail", equalTo: self.userEmailKey)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    if objects.count == 0 {
                        let gameInstance = PFObject(className: "GameInstance")
                        gameInstance.ACL = parseACL
                        gameInstance["profilePic"] = self.profilePic
                        gameInstance["userName"] = self.userName
                        gameInstance["userEmail"] = self.userEmailKey
                        gameInstance["userFriends"] = self.userFriends
                        gameInstance["opponentName"] = opponentName
                        gameInstance["opponentEmail"] = opponentEmail
                        gameInstance["userFriendURLs"] = self.userFriendURLs
                        gameInstance["userFriendIDs"] = self.userFriendIDs
                        
                      
                        gameInstance.saveInBackgroundWithBlock { (success, error) -> Void in
                           PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": opponentEmail , "message": "\(self.userName) wants to play Guesses with you!"])
                        print("push")}
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        

        
        
        //***************************************************************************
      /*  let predicate = NSPredicate(format: "%K == %@", "userEmail", self.userEmailKey)
        print(predicate.predicateFormat)
        let query = CKQuery(recordType: "GameInstance", predicate: predicate)
        self.publicDatabase!.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            }
            else if records?.count == 0 {
                let record:CKRecord = CKRecord(recordType: "GameInstance")
                record.setValue(self.profilePic, forKey: "profilePic")
                record.setValue(self.userName, forKey: "userName")
                record.setValue(self.userEmailKey, forKey: "userEmail")
                record.setValue(self.userFriends, forKey: "userFriends")
                record.setValue(opponentName, forKey: "opponentName")
                record.setValue(opponentEmail, forKey: "opponentEmail")
                record.setValue(self.userFriendURLs, forKey: "userFriendURLs")
                record.setValue(self.userFriendIDs, forKey: "userFriendIDs")
                    if let database:CKDatabase = self.publicDatabase {
                        database.saveRecord(record, completionHandler: { (record:CKRecord?, error:NSError?) in
                            if error != nil {
                                NSLog(error!.localizedDescription)
                            }
                            else {
                                print( "saved")
                            }
                        })
                    }

                }
            else {
                print ("record must be deleted first")
            }})*/
        
            }

    
    func setUserFriends() {
        let params = ["fields": "picture.type(large),id,email,name,username"]
        let request = FBSDKGraphRequest(graphPath: "me/invitable_friends?limit=5000", parameters: params)
       
        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error != nil {
                _ = error.localizedDescription
            }
            else if result.isKindOfClass(NSDictionary){
                /* Handle response */
                if let dict = result as? [String: AnyObject] {
                    
                    let dictData:NSArray =  dict["data"] as! NSArray
                    self.userFriends.removeAll()
                    self.userFriendIDs.removeAll()
                    self.userFriendIDsDict.removeAll()
                    self.userFriendURLs.removeAll()
                    for d in dictData {
                        _ = d as! [String: AnyObject]
                        var dDict:[String: AnyObject] = d as! [String:AnyObject]
                        let friendPic:String = String(dDict["picture"]!["data"]!!["url"]!!)
                        self.userFriends.append(String(dDict["name"]!))
                        self.userFriendURLs.append(friendPic)
                        self.userFriendIDs.append("\(friendPic)")
                        self.userFriendIDsDict["\(friendPic)"] = String(dDict["name"]!)
                        
                    }
                }
            }
        }
    }
    
    func setTheMyFriendsOnApp(gameIDss:Set<String>) {
        //self.myFriendsOnApp.removeAll()
        let params = ["fields": "picture.type(large),id,user_email,name"]
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: params)
        
        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error != nil {
                _ = error.localizedDescription
            }
            else if result.isKindOfClass(NSDictionary){
                /* Handle response */
                if let dict = result as? [String: AnyObject] {
                    print(dict)
                    let dictData:AnyObject = dict["data"]!
                    let dictDataDict:NSArray = dictData as! NSArray
                    //let gameIDs:[String] = self.getGameIDs()
                    self.gameIDsIDs.removeAll(keepCapacity: false)
                    //self.opponentIDs.removeAll(keepCapacity: false)
                    self.gameNames.removeAll(keepCapacity: false)
                    self.gameURLs.removeAll(keepCapacity: false)
                    for friend in dictDataDict {
                        let friendDict = friend as! [String: AnyObject]
                        let friendID:String = String(friendDict["id"]!)
                        let friendName:String = String(friendDict["name"]!)
                        let friendPic:String = String(friendDict["picture"]!["data"]!["url"]!!)
                        if (!gameIDss.contains(friendID) && !self.myFriendsOnAppIDs.contains(friendID)) {
                            self.myFriendsOnApp.append(friendName)
                            self.myFriendsOnAppIDs.append(friendID)
                            self.myFriendsOnAppURLs.append(friendPic)
                        }
                        
                        if (gameIDss.contains(friendID)) {
                            if (self.myFriendsOnAppIDs.contains(friendID)) {
                                self.myFriendsOnApp.removeAll()
                                self.myFriendsOnAppIDs.removeAll()
                                self.myFriendsOnAppURLs.removeAll()
                                self.setTheMyFriendsOnApp(gameIDss)
                                print("RESET")
                            }
                            self.gameIDsIDs.append(friendID)
                            //self.opponentIDs.append(<#T##newElement: Element##Element#>)
                            self.gameNames.append(friendName)
                            self.gameURLs.append(friendPic)
                        }
                    }
                    self.tableViewGames.reloadData()
                    self.collectionViewFriends.reloadData()
                }
            }

        }
        
    }
    
    func deleteGamesButtonAction() {
        // print(self.userID!)
        
        let query = PFQuery(className: "Game")
       // query.whereKey("columnName", equalTo: "abcd")
         query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
            for object in objects {
                object.deleteEventually()
            }
            }
        }
        let query2 = PFQuery(className: "PlayerBoard")
        // query.whereKey("columnName", equalTo: "abcd")
        query2.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                for object in objects {
                    object.deleteEventually()
                }
            }
        }
        
     /*   let query = CKQuery(recordType: "Game", predicate: NSPredicate(value: true))
        self.publicDatabase!.performQuery(query, inZoneWithID: nil) { (records, error) in
            
            if error == nil {
                
                for record in records! {
                    
                    self.publicDatabase!.delete(withRecordID: record.recordID, completionHandler: { (record, error) in
                        
                    })                }
                
            }
            
        }*/
    }
    
    func getGameIDs() -> Set<String> {
        var ids:Set<String> = Set<String>()
        self.gameIDs.removeAll()
        self.opponentIDs.removeAll()
        let parseACL:PFACL = PFACL()
        parseACL.publicReadAccess = true
        parseACL.publicWriteAccess = true
 
                let query2 = PFQuery(className:"Game")
               // query2.whereKey("player2", equalTo: self.userEmailKey)
                query2.findObjectsInBackgroundWithBlock {
                    (objects2: [PFObject]?, error2: NSError?) -> Void in
                    
                    if error2 == nil {
                        // The find succeeded.
                        print("Successfully retrieved \(objects2!.count) scores.")
                        // Do something with the found objects
                        if let objects2 = objects2 {
                            for object2 in objects2 {
                                
                                object2.ACL = parseACL
                                if (object2["player1"] as! String == self.userEmailKey) {
                                    ids.insert(object2.objectForKey("player2") as! String)
                                    self.gameIDs.append(object2.objectForKey("gameID") as! String)
                                    self.opponentIDs.append(object2["player2"] as! (String))
                                }
                                else if (object2["player2"] as! String == self.userEmailKey) {
                                    ids.insert(object2.objectForKey("player1") as! String)
                                    self.gameIDs.append(object2.objectForKey("gameID") as! String)
                                    self.opponentIDs.append(object2["player1"] as! (String))
                                }
                                
                                
                                
                                
                            }
                            
                        }
                       // dispatch_async(dispatch_get_main_queue()) {
                          //  self.tableViewGames.reloadData()
                            self.setTheMyFriendsOnApp(ids)
                       // }
                        
                    } else {
                        // Log details of the failure
                        print("Error: \(error2!) \(error2!.userInfo)")
                    }
                }

                
                
                
      
        
        
        
        
        
       // let predicate = NSPredicate(value: true)
        //print(predicate.predicateFormat)
        // better be accurate to get only the record you need
        
       /*
        
        let query = CKQuery(recordType: "Game", predicate: predicate)
        
        self.publicDatabase!.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            }
            else  {
                self.gameIDs.removeAll(keepCapacity: false)
                for record in records! {
                ids.append(record.objectForKey("player2") as! String)
                ids.append(record.objectForKey("gameID") as! String)
                    
                    self.gameIDs.append(record.objectForKey("gameID") as! String)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableViewGames.reloadData()
                    self.setTheMyFriendsOnApp(ids)
                }
                
            
            }
        })*/
        
        
        return ids
    }

    func setMutualFriends(friendFriendIDs:[String], index:Int) -> [CardStruct] {
        var cards:[CardStruct] = [CardStruct]()
        var cardsBad:[CardStruct] = [CardStruct]()
        self.friendFriendIDsCount = friendFriendIDs.count
        self.progressCount = 0
        var indexSet:Set<Int> = Set()
        for friendA in friendFriendIDs {
            self.progressCount += 1
            if (self.userFriendIDsDict[friendA] != nil && self.inviteFriendFriendNames[index].contains(self.userFriendIDsDict[friendA]!))
            {
                
                var card:CardStruct = CardStruct()
                let index:Int = self.userFriendIDs.indexOf(friendA)!
                let url:String = self.userFriendURLs[index]
                card.personName = self.userFriends[index]
                card.profilePictureURL = url
                let data = NSData(contentsOfURL: NSURL(string: url)!)
                card.profilePicture = UIImage(data: data!)! as UIImage
                indexSet.insert(index)
                cards.append(card)
                    self.progressCount += 1
                
            }
        }
        
        
        
        
        self.timer.invalidate()
        if (cards.count >= 20) {
            self.randListSize = cards.count
        }//}
        else {
         
           // for friendA in friendFriendIDs {
                
                while indexSet.count < 20 && (self.userFriendURLs.count > 0)
                {
                    var card:CardStruct = CardStruct()
                    var randIndex = Int(arc4random_uniform(UInt32(self.userFriendURLs.count)))
                    
                    while (indexSet.contains(randIndex))
                    {
                        randIndex = Int(arc4random_uniform(UInt32(self.userFriendURLs.count)))
                    }
                    
                    let index:Int = randIndex
                    
                    let url:String = self.userFriendURLs[index]
                    card.personName = self.userFriends[index]
                    card.profilePictureURL = url
                    let data = NSData(contentsOfURL: NSURL(string: url)!)
                    card.profilePicture = UIImage(data: data!)! as UIImage
                    if (!friendFriendIDs.contains(url)) {
                        cardsBad.append(card)
                        indexSet.insert(index)
                    }
                }
            

            var n:Int = 0;
            while (cards.count < 20) {
                self.progressCount += 1
                cards.append(cardsBad[n])
                n += 1
            }
            PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": self.invitingThisCellOpponentID , "message": "You don't have enough mutual friends with \(self.userName), so you may not know everyone featured."])
            self.randListSize = cards.count
        }
        return cards
    }
    
    func maskImage(image: UIImage, withMask maskImage: UIImage) -> UIImage {
        
        let maskRef = maskImage.CGImage
        
        let mask = CGImageMaskCreate(
            CGImageGetWidth(maskRef!),
            CGImageGetHeight(maskRef!),
            CGImageGetBitsPerComponent(maskRef!),
            CGImageGetBitsPerPixel(maskRef!),
            CGImageGetBytesPerRow(maskRef!),
            CGImageGetDataProvider(maskRef!)!,
            nil,
            false)
        
        let masked = CGImageCreateWithMask(image.CGImage!, mask!)
        let maskedImage = UIImage(CGImage: masked!)
        
        // No need to release. Core Foundation objects are automatically memory managed.
        
        return maskedImage
        
    }
    func setProfInfo() {
        print("SETTING PROF INFO")
        let params = ["fields": "picture.type(large),id,email,name"]
        let request = FBSDKGraphRequest(graphPath: "me", parameters: params)
   
        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error != nil {
                let errorMessage = error.localizedDescription
                print(errorMessage)
            }
            else if result.isKindOfClass(NSDictionary)
            {
                /* Handle response */
                if let dict = result as? [String: AnyObject]
                {
                    
                    self.userName = String(dict["name"]!)
                    
                    print(self.userEmailKey)
                    self.profilePic = String(dict["picture"]!["data"]!!["url"]!!)
                    self.userEmailKey = String(dict["id"]!)
                  //  dispatch_async(dispatch_get_main_queue()) {
                        self.refreshInvites()
                  //  }
                }
                    
                }
        }
        
        }
    
    func refreshInvites() {
     dispatch_async(dispatch_get_main_queue()){
        let query = PFQuery(className:"GameInstance")
        query.whereKey("opponentEmail", equalTo: self.userEmailKey)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                self.recordInvites.removeAll(keepCapacity: false)
                self.inviteFriendIDs.removeAll(keepCapacity: false)
                self.inviteFriendFriends.removeAll(keepCapacity: false)
                self.inviteFriendFriendNames.removeAll(keepCapacity: false)
                self.inviteFriendURLs.removeAll(keepCapacity: false)
                if let objects = objects {
                    for object in objects {
                        print(object.objectId)
                        self.recordInvites.append(object["userName"] as! String)
                        self.inviteFriendIDs.append(object["userEmail"] as! String)
                        self.inviteFriendFriends.append(object["userFriendIDs"] as! [String])
                        self.inviteFriendFriendNames.append(object["userFriends"] as! [String])
                        self.inviteFriendURLs.append(object["profilePic"] as! String)
                    }
               //     self.friendsLabel.text = String(self.recordInvites)
                  //  print(self.friendsLabel)
                 //   self.tableView.reloadData()
                   // self.collectionViewFriends.reloadData()
                  //  self.tableView.setNeedsDisplay()
                  //  self.collectionViewFriends.setNeedsDisplay()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            self.tableView.reloadData()
            self.collectionViewFriends.reloadData()
        }
        
        
            //    self.friendsLabel.text = String(self.recordInvites)
        }

        
        //*************************************************************************************
        
       /* let predicate = NSPredicate(format: "opponentEmail == '\(self.userEmailKey)'")
        self.publicDatabase!.performQuery(CKQuery(recordType: "GameInstance", predicate: predicate), inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else if let returnedRecords = records {
                dispatch_after(4, dispatch_get_main_queue()) {
                        self.recordInvites.removeAll(keepCapacity: false)
                        self.inviteFriendIDs.removeAll(keepCapacity: false)
                        self.inviteFriendFriends.removeAll(keepCapacity: false)
                        for record in returnedRecords
                        {
                            
                            print("forLoop")
                            let messageRecord:CKRecord = record
                            self.recordInvites.append(messageRecord.objectForKey("userName") as! String)
                            self.inviteFriendIDs.append(messageRecord.objectForKey("userEmail") as! String)
                            self.inviteFriendFriends.append(messageRecord.objectForKey("userFriendIDs") as! [String])
                        }
                        self.friendsLabel.text = String(self.recordInvites)
                        print(self.friendsLabel)
                        self.tableView.reloadData()
                        self.tableView.setNeedsDisplay()
                    }
            
                }
        })
        self.tableView.reloadData()
        self.friendsLabel.text = String(self.recordInvites)*/
    }
    
    func setSubscription() {
        
        // When users indicate they are Giants fans, we subscribe them to that channel.
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.addUniqueObject(self.userEmailKey, forKey: "channels")
        currentInstallation.saveInBackground()
        
        
        /*let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.userEmailID, forKey: "userEmailID")
        
        let database = CKContainer.defaultContainer().publicCloudDatabase
        
        database.fetchAllSubscriptionsWithCompletionHandler() { [unowned self] (subscriptions, error) -> Void in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.deleteSubscriptionWithID(subscription.subscriptionID, completionHandler: { (str, error) -> Void in
                            if error != nil {
                                // do your error handling here!
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                    // more code to come!
                    let predicate = NSPredicate(format:"opponentEmail = %@", self.userEmailKey)
                    let subscription = CKSubscription(recordType: "GameInstance", predicate: predicate, options: .FiresOnRecordCreation)
                    
                    let notification = CKNotificationInfo()
                    notification.alertBody = "There's a new whistle in the genre."
                    notification.soundName = UILocalNotificationDefaultSoundName
                    
                    subscription.notificationInfo = notification
                    
                    self.publicDatabase!.saveSubscription(subscription) { (result, error) -> Void in
                        if error != nil {
                            print(error!.localizedDescription)
                        }
                    }
                }
            } else {
                // do your error handling here!
                print(error!.localizedDescription)
            }
        }
        */
        
        
        
    }
       
    @IBAction func unwindToHere(segue: UIStoryboardSegue) {
        // And we are back
        _ = segue.sourceViewController as! ViewControllerInvite
        // use svc to get mood, action, and place
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "showInvite" {
        // Create a variable that you want to send
        let userID = self.invitingThisCellFriend
        
        // Create a new variable to store the instance of PlayerTableViewController
        let destinationVC:ViewControllerInvite = segue.destinationViewController as! ViewControllerInvite
        destinationVC.userID = userID
            destinationVC.opponentName = self.opponentName
            destinationVC.userName = self.userName
        destinationVC.opponentID = self.invitingThisCellOpponentID
            destinationVC.sendingVC = self
           
        }
        else if segue.identifier == "showGame" {
            // Create a variable that you want to send
            let cards = self.sendMutualCards
            
            // Create a new variable to store the instance of PlayerTableViewController
            let destination0VC:ViewControllerContainers = segue.destinationViewController as! ViewControllerContainers
            destination0VC.opponentName = self.opponentName
            destination0VC.cards = cards
            destination0VC.gameID = self.userEmailKey
            destination0VC.userID = self.userEmailKey
            destination0VC.player2 = self.invitingThisCellOpponentID
            destination0VC.oppCard = self.player1OppCard
            destination0VC.userName = self.userName
             self.deleteThisGameInvite(self.invitingThisCellOpponentID, opponentEmail: self.userEmailKey)
            
            
        }
        else if segue.identifier == "showGame22" {
            // Create a variable that you want to send
            //let cards = self.sendMutualCards
            
            // Create a new variable to store the instance of PlayerTableViewController
            let destination0VC:ViewControllerContainers = segue.destinationViewController as! ViewControllerContainers
            print("showGame2")
            
            destination0VC.cards = self.destVC.cards
            destination0VC.gameID = self.destVC.gameID
            destination0VC.opponentName = self.opponentName
            destination0VC.userID = self.userEmailKey
            destination0VC.oppCard = self.destVC.oppCard
            destination0VC.randomize = false
            destination0VC.initialLoad = false
            destination0VC.userName = self.userName
           destination0VC.player2 = self.destVC.player2
            
            
            print("showGame2End")
            
        }
 
    }
    func createGameRecord() {
        //dispatch_async(dispatch_get_main_queue()) {
       //     self.loadingView.hidden = false
       //     self.loadingView.setNeedsDisplay()
       // }
     //   var cardStructPersonNameListTemp:[String] = [String]()
      //  var cardStructProfilePictureListTemp:[String] = [String]()
      //  for cardStruct in self.mutualCards {
     //       cardStructPersonNameListTemp.append(cardStruct.personName)
     //       cardStructProfilePictureListTemp.append(cardStruct.profilePictureURL)
     //   }
        var cardStructPersonNameList:[String] = [String]()
        var cardStructProfilePictureList:[String] = [String]()
        
       
        self.sendMutualCards.removeAll()
        var numCards = 20
        if self.randListSize < 20 {
            numCards = self.randListSize
        }
        for k in 0...numCards - 1 {
            let randNum = self.randList[k]
            var card:CardStruct = self.mutualCards[randNum]
         
            let data = NSData(contentsOfURL: NSURL(string: card.profilePictureURL)!)
            card.profilePicture = UIImage(data: data!)! as UIImage
            cardStructPersonNameList.append(card.personName)
            cardStructProfilePictureList.append(card.profilePictureURL)
            self.sendMutualCards.append(card)
            
        }
        
        let randNumPlayer1 = Int(arc4random_uniform(UInt32(numCards)))
        var randNumPlayer2 = Int(arc4random_uniform(UInt32(numCards)))
        while (randNumPlayer1 == randNumPlayer2){
            randNumPlayer2 = Int(arc4random_uniform(UInt32(numCards)))
        }
        
        
        let parseACL:PFACL = PFACL()
        parseACL.publicReadAccess = true
        parseACL.publicWriteAccess = true
                             let record = PFObject(className: "Game")
                        record.ACL = parseACL
        
                        
          let player1Board = PFObject(className: "PlayerBoard")
        player1Board.ACL = parseACL
        //  let player2Board = PFObject(className: "PlayerBoard")
        player1Board["gameID"] = self.userEmailKey + self.invitingThisCellOpponentID
        player1Board["playerID"] = self.userEmailKey
        player1Board["board"] = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        player1Board.saveEventually()
        
        let player2Board = PFObject(className: "PlayerBoard")
        player2Board.ACL = parseACL
        //  let player2Board = PFObject(className: "PlayerBoard")
        player2Board["gameID"] = self.userEmailKey + self.invitingThisCellOpponentID
        player2Board["playerID"] = self.invitingThisCellOpponentID
        player2Board["board"] = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        player2Board.saveEventually()


        
        
    
        record["cardStructPersonNameList"] = cardStructPersonNameList
        record["cardStructProfilePictureList"] = cardStructProfilePictureList
        record["shuffledNames"] = cardStructPersonNameList
        record["shuffledIDs"] = cardStructProfilePictureList
        record["shuffledNames2"] = cardStructPersonNameList
        record["shuffledIDs2"] = cardStructProfilePictureList
        record["gameID"] = self.userEmailKey
        record["player1"] = self.userEmailKey
        record["player2"] = self.invitingThisCellOpponentID
        record["whoseTurn"] = self.userEmailKey
        record["gameEndStatus"] = "false"
        record["isAwaitingApproval"] = "false"
        record["questionText"] = ""
        record["player1CardID"] = cardStructProfilePictureList[randNumPlayer1]
       record["player1CardName"] =  cardStructPersonNameList[randNumPlayer1]
        record["player2CardID"] = cardStructProfilePictureList[randNumPlayer2]
        record["player2CardName"] = cardStructPersonNameList[randNumPlayer2]
        var boardProto:[Int] = [Int]()
        for i in 0...cardStructPersonNameList.count {
            if (i < 20) {
                boardProto.append(1)
            }
            
        }
        record.setValue(boardProto, forKey: "player2Board")
        record.setValue(boardProto, forKey: "player1Board")
        self.player1OppCard.removeConstraints(self.player1OppCard.constraints)
        self.player1OppCard.personName = cardStructPersonNameList[randNumPlayer1]
        self.player1OppCard.profPicURL = cardStructProfilePictureList[randNumPlayer1]
         self.player1OppCard.profilePicture = UIImage(data: NSData(contentsOfURL: NSURL(string: self.player1OppCard.profPicURL)!)!)!
        
        
        record.saveInBackgroundWithBlock { (success, error) -> Void in
            // PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": opponentEmail , "message": "\(self.userName) wants to play Guesses with you!"])

        }
    }
    
  
    
    
}



        
        
    


