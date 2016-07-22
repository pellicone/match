//
//  ViewControllerInvite.swift
//  Match
//
//  Created by Daniel Pellicone on 6/24/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
import CloudKit
import Parse
class ViewControllerInvite: UIViewController {
    var container:CKContainer?
    var publicDatabase:CKDatabase?
    var privateDatabase:CKDatabase?
    var userID:String?
    var opponentID:String?
    var gameRecord:CKRecord?
     var cards:[CardStruct] = [CardStruct]()
    var myTimer:NSTimer?
    var sendingVC:ViewControllerFriends?
    
    @IBOutlet weak var cancelButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container = CKContainer.defaultContainer()
        self.publicDatabase = self.container?.publicCloudDatabase
        self.privateDatabase = self.container?.privateCloudDatabase
        print("ViewControllerInvite")
        print(self.userID)
        self.cancelButton.addTarget(self, action: #selector(ViewControllerInvite.cancelButtonAction), forControlEvents: UIControlEvents.TouchUpInside)
        self.waitForInviteAccept()
           self.myTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewControllerInvite.waitForInviteAccept), userInfo: nil, repeats: true)
        
       
        
            
            
            
         
      //             // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    func deleteOnGameStart() {
     //   self.userID = self.opponentID
        self.cancelButtonAction()
    }
    
    func cancelButtonAction() {
        let query = PFQuery(className:"GameInstance")
        query.whereKey("userEmail", equalTo: self.userID!)
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
                        self.myTimer?.invalidate()
                    }
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        

        
        
        
        
        
        //***************************************************************************
        /*
        print(self.userID!)
        let query = CKQuery(recordType: "GameInstance", predicate: NSPredicate(format: "userEmail == '\(self.userID!)'", argumentArray: nil))
        self.publicDatabase!.performQuery(query, inZoneWithID: nil) { (records, error) in
            
            if error == nil {
                
                for record in records! {
                    
                    self.publicDatabase!.deleteRecordWithID(record.recordID, completionHandler: { (recordId, error) in
                        
                        if error == nil {
                            
                            //Record deleted
                            print("record deleted")
                            self.myTimer?.invalidate()
                        
                           // self.sendingVC!.myFriendsOnApp.append(self.opponentID!)
                            //self.performSegueWithIdentifier("returnFromInvite", sender: self)
                           // self.sendingVC!.tableViewFriends.reloadData()
                        }
                        
                    })
                    
                }
                
            }
            
        }
 */
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.myTimer!.invalidate()
        self.myTimer = nil
    }
    func waitForInviteAccept() {
        if (self.gameRecord == nil){
            print("Waiting..")
        let predicate = NSPredicate(format: "player1 == '\(self.opponentID!)'")
        
        self.publicDatabase!.performQuery(CKQuery(recordType: "Game", predicate: predicate), inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
            
            // Check if there's an error
            if error != nil {
                print(error?.localizedDescription)
            }
            else if records != nil {
                
                // No error, go through the records
                
                dispatch_after(3, dispatch_get_main_queue()) {
                   if (records?.count > 0)
                   {
                    self.gameRecord = records![0]
                   
                    }
                    
                }
                
            }
            
            
        })
        }
        else {
            self.myTimer?.invalidate()
            var personNames:[String] = self.gameRecord?.objectForKey("cardStructPersonNameList") as! [String]
            var profilePictures:[String] = self.gameRecord?.objectForKey("cardStructProfilePictureList") as! [String]
            for i in 0...personNames.count - 1 {
                var cardStruct:CardStruct = CardStruct()
                cardStruct.personName = personNames[i]
                cardStruct.profilePictureURL = profilePictures[i]
                
                let data = NSData(contentsOfURL: NSURL(string:  cardStruct.profilePictureURL)!)
                cardStruct.profilePicture = UIImage(data: data!)! as UIImage
                self.cards.append(cardStruct)
            }
            performSegueWithIdentifier("showGameFromInvite", sender: self)
        }

    }
 
   /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if segue.identifier == "showGameFromInvite" {
            
            // Create a variable that you want to send
            let cards = self.cards
            
            // Create a new variable to store the instance of PlayerTableViewController
            let destination0VC:ViewControllerContainers = segue.destinationViewController as! ViewControllerContainers
            //destination0VC.performSegueWithIdentifier("showBoardContainer", sender: destination0VC)
            // let destinationVC:ViewController = destination0VC.containerViewController! as ViewController
            destination0VC.cards = cards
            destination0VC.gameID = self.opponentID!
            destination0VC.userID = self.userID!
            self.deleteOnGameStart()
        }
    }
    
}
