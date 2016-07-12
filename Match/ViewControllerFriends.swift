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
import CloudKit

class ViewControllerFriends: UIViewController, FBSDKLoginButtonDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navButton: UIButton!
    
    @IBOutlet weak var friendsLabel: UILabel!
   
    @IBOutlet weak var tableViewFriends: UITableView!
    @IBOutlet var tableView: UITableView!
    var container:CKContainer?
    var publicDatabase:CKDatabase?
    var privateDatabase:CKDatabase?
    var userName:String = ""
    var userEmailKey:String = "" {
        didSet {
            if (self.userEmailKey != "") {
             //   self.setSubscription()
            }
        }
    }
    var profilePic:String = ""
    var userFriends:[String] = [String]()
    var myFriendsOnApp:[String] = [String]()
    //var myFriendsOnAppEmails:[String] = [String]()
    var myFriendsOnAppIDs:[String] = [String]()
    var l:String = "AASDF"
    var recordIDs:[CKRecordID] = [CKRecordID]()
    var recordInvites:[String] = [String]()
    var invitingThisCellFriend:String = String()
    var inviteFriendIDs:[String] = [String]()
    var inviteFriendFriends:[[String]] = [[String]]()
    var userFriendURLs:[String] = [String]()
    var userFriendIDs:[String] = [String]()
    var mutualCards:[CardStruct] = [CardStruct]()
    var invitingThisCellOpponentID:String = String()
    
    @IBOutlet weak var deleteGameButton: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableViewFriends.delegate = self
        self.tableViewFriends.dataSource = self
        print("viewDidLoad")
        let theViewController = self
        self.deleteGameButton.addTarget(self, action: #selector(ViewControllerFriends.deleteGamesButtonAction), forControlEvents: UIControlEvents.TouchUpInside)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.myViewController = theViewController
        self.container = CKContainer.defaultContainer()
        self.publicDatabase = self.container?.publicCloudDatabase
        self.privateDatabase = self.container?.privateCloudDatabase
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            print("Not Logged in..")
        }
        else {
            print("Logged in..")
        }
        self.getGameIDs()
        
        self.setUserFriends()
        
        self.setProfInfo()
       
        let loginButton = FBSDKLoginButton()
        self.view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        navButton.addTarget(self, action: #selector(ViewControllerFriends.refreshInvitesButton), forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.delegate = self
        let bottomMarginConstraint:NSLayoutConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -10)
        let centerXConstraint:NSLayoutConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
        self.view.addConstraints([bottomMarginConstraint, centerXConstraint])
      
        // Do any additional setup after loading the view.
    }
   
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tableView) {
            return self.recordInvites.count
        }
        return self.myFriendsOnApp.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (tableView == self.tableView) {
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
            cell.textLabel?.text = self.recordInvites[indexPath.row]
            return cell
        }
        if (tableView == self.tableViewFriends) {
            let cellFriend:UITableViewCell = tableViewFriends.dequeueReusableCellWithIdentifier("CellFriend")! as UITableViewCell
            cellFriend.textLabel?.text = self.myFriendsOnApp[indexPath.row]
            
            return cellFriend
        }
        return UITableViewCell()
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == self.tableViewFriends) {
            let cellFriend:UITableViewCell = tableViewFriends.cellForRowAtIndexPath(indexPath)!
            
            self.saveRecord((cellFriend.textLabel?.text)!, opponentEmail: self.myFriendsOnAppIDs[indexPath.row])
            self.invitingThisCellOpponentID = self.myFriendsOnAppIDs[indexPath.row]
            self.invitingThisCellFriend = self.userEmailKey
            self.performSegueWithIdentifier("showInvite", sender: self)
            
        }
        if (tableView == self.tableView) {
           self.invitingThisCellOpponentID = self.inviteFriendIDs[indexPath.row]
          self.mutualCards = self.setMutualFriends(self.inviteFriendFriends[indexPath.row])
            self.createGameRecord()
            self.performSegueWithIdentifier("showGame", sender: self)
            
        }

        
    }
    func refreshInvitesButton() {
        self.refreshInvites()
        self.getGameIDs()
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
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.performSegueWithIdentifier("showLogin", sender: self)
     //   self.setSubscription()
     //    _ = UIApplication.sharedApplication().delegate as! AppDelegate
     
        print("User logged out")
        
    }
    
    func saveRecord(opponentName:String, opponentEmail: String) {
    
        let predicate = NSPredicate(format: "%K == %@", "userEmail", self.userEmailKey)
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
            }})
        
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
                    self.userFriendURLs.removeAll()
                    for d in dictData {
                        _ = d as! [String: AnyObject]
                        var dDict:[String: AnyObject] = d as! [String:AnyObject]
                        let friendPic:String = String(dDict["picture"]!["data"]!!["url"]!!)
                        self.userFriends.append(String(dDict["name"]!))
                        self.userFriendURLs.append(friendPic)
                        self.userFriendIDs.append("\(friendPic)")
                        
                    }
                }
            }
        }
    }
    
    func setTheMyFriendsOnApp(gameIDs:[String]) {
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
                    for friend in dictDataDict {
                        let friendDict = friend as! [String: AnyObject]
                        let friendID:String = String(friendDict["id"]!)
                        let friendName:String = String(friendDict["name"]!)
                        if (!gameIDs.contains(friendID) && !self.myFriendsOnAppIDs.contains(friendID)) {
                            self.myFriendsOnApp.append(friendName)
                            self.myFriendsOnAppIDs.append(friendID)
                        }
                    }
                    self.tableViewFriends.reloadData()
                }
            }

        }
        
    }
    
    func deleteGamesButtonAction() {
        // print(self.userID!)
        let query = CKQuery(recordType: "Game", predicate: NSPredicate(value: true))
        self.publicDatabase!.performQuery(query, inZoneWithID: nil) { (records, error) in
            
            if error == nil {
                
                for record in records! {
                    
                    self.publicDatabase!.deleteRecordWithID(record.recordID, completionHandler: { (recordId, error) in
                        
                        if error == nil {
                            
                            //Record deleted
                            print("record deleted")
                            // self.myTimer?.invalidate()
                            
                            // self.sendingVC!.myFriendsOnApp.append(self.opponentID!)
                            //self.performSegueWithIdentifier("returnFromInvite", sender: self)
                            // self.sendingVC!.tableViewFriends.reloadData()
                        }
                        
                    })
                    
                }
                
            }
            
        }
    }
    
    func getGameIDs() -> [String] {
        var ids:[String] = [String]()
        let predicate = NSPredicate(value: true)
        print(predicate.predicateFormat)
        // better be accurate to get only the record you need
        let query = CKQuery(recordType: "Game", predicate: predicate)
        
        self.publicDatabase!.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error != nil {
                print("Error querying records: \(error!.localizedDescription)")
            }
            else  {
                for record in records! {
                ids.append(record.objectForKey("player2") as! String)
                ids.append(record.objectForKey("gameID") as! String)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.setTheMyFriendsOnApp(ids)
                }
                
            
            }
        })
        
        
        return ids
    }

    func setMutualFriends(friendFriendIDs:[String]) -> [CardStruct] {
        var cards:[CardStruct] = [CardStruct]()
        for friendA in friendFriendIDs {
            if (self.userFriendIDs.contains(friendA))
            {
                var card:CardStruct = CardStruct()
                let index:Int = self.userFriendIDs.indexOf(friendA)!
                let url:String = self.userFriendURLs[index]
                card.personName = self.userFriends[index]
                card.profilePictureURL = url
                let data = NSData(contentsOfURL: NSURL(string: url)!)
                card.profilePicture = UIImage(data: data!)! as UIImage
                if (url != "https://scontent.xx.fbcdn.net/v/t1.0-1/s200x200/10354686_10150004552801856_220367501106153455_n.jpg?oh=246adb8e3d7dc948f4d8025495fbf8dd&oe=57FD4150") {
                cards.append(card)
                }
            }
        }
        return cards
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
                    self.profilePic = String(dict["picture"]!["data"]!!["url"]!)
                    self.userEmailKey = String(dict["id"]!)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshInvites()
                    }
                }
                    
                }
        }
        
        }
    
    func refreshInvites() {
        let predicate = NSPredicate(format: "opponentEmail == '\(self.userEmailKey)'")
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
        self.friendsLabel.text = String(self.recordInvites)
    }
    
    func setSubscription() {
        
        self.publicDatabase!.fetchAllSubscriptionsWithCompletionHandler() { [unowned self] (subscriptions, error) -> Void in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        self.publicDatabase!.deleteSubscriptionWithID(subscription.subscriptionID, completionHandler: { (str, error) -> Void in
                            if error != nil {
                                // do your error handling here!
                                print(error!.localizedDescription)
                                self.setSubscription()
                            }
                        })
                    }
                    
                    // more code to come!
                    let predicate = NSPredicate(format: "opponentEmail == '\(self.userEmailKey)'")
                    print("subscription set:\(self.userEmailKey)")
                    //print(predicate.debugDescription)
                    
                    let subscription = CKSubscription(recordType: "GameInstance", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
                   // print(subscription.debugDescription)
                    
                    let info = CKNotificationInfo()
                    info.alertLocalizationKey = "Someone wants to play Guesses with you!"
                    info.soundName = "NewAlert.aiff"
                    info.shouldBadge = true
                    
                    subscription.notificationInfo = info
                    // CKSubscription.
                    self.publicDatabase!.saveSubscription(subscription) { subscription, error in
                        //...
                        if error != nil {
                            print(error!.localizedDescription)
                        self.setSubscription()
                        }
                    }
                }
            } else {
                // do your error handling here!
                print(error!.localizedDescription)
                self.setSubscription()
            }
        }
        
        
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
        destinationVC.opponentID = self.invitingThisCellOpponentID
            destinationVC.sendingVC = self
        }
        else if segue.identifier == "showGame" {
            // Create a variable that you want to send
            let cards = self.mutualCards
            
            // Create a new variable to store the instance of PlayerTableViewController
            let destination0VC:ViewControllerContainers = segue.destinationViewController as! ViewControllerContainers
            destination0VC.cards = cards
            destination0VC.gameID = self.userEmailKey
            destination0VC.userID = self.userEmailKey
        }
    }
    func createGameRecord() {
        var cardStructPersonNameList:[String] = [String]()
        var cardStructProfilePictureList:[String] = [String]()
        for cardStruct in self.mutualCards {
            cardStructPersonNameList.append(cardStruct.personName)
            cardStructProfilePictureList.append(cardStruct.profilePictureURL)
        }
        
        let record:CKRecord = CKRecord(recordType: "Game")
        record.setValue(cardStructPersonNameList, forKey: "cardStructPersonNameList")
        record.setValue(cardStructProfilePictureList, forKey: "cardStructProfilePictureList")
        record.setValue(self.userEmailKey, forKey: "gameID")
        record.setValue(self.userEmailKey, forKey: "player1")
        record.setValue(self.invitingThisCellOpponentID, forKey: "player2")
        record.setValue(self.userEmailKey, forKey: "whoseTurn")
        record.setValue("false", forKey: "gameEndStatus")
        record.setValue("false", forKey: "isAwaitingApproval")
        record.setValue("", forKey: "questionText")
        record.setValue("", forKey: "player1CardID")
        record.setValue("", forKey: "player1CardName")
        record.setValue("", forKey: "player2CardID")
        record.setValue("", forKey: "player2CardName")
        var boardProto:[Int] = [Int]()
        for i in 0...cardStructPersonNameList.count {
            if (i < 20) {
                boardProto.append(1)
            }
            
        }
        record.setValue(boardProto, forKey: "player2Board")
        record.setValue(boardProto, forKey: "player1Board")
        
        
        
        
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

}
