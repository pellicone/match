//
//  Game.swift
//  Match
//
//  Created by Daniel Pellicone on 7/3/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
//import CloudKit
import Parse
class Game: NSObject {
    //var container:CKContainer?
    //var publicDatabase:CKDatabase?
    //var privateDatabase:CKDatabase?
    
    var cardStructPersonNameList:[String] = [String]()
    var cardStructProfilePictureList:[String] = [String]()
    var gameEndStatus:String = String()
    var gameID:String = String()
    var isAwaitingApproval:String = String()
    var player1:String = String()
    var player2:String = String()
    var whoseTurn:String = String()
    var questionText:String = String()
    var player1Board:[Int] = [Int]()
    var player2Board:[Int] = [Int]()
    weak var vC:ViewControllerContainers?
    override init() {
        super.init()
  //      self.container = CKContainer.defaultContainer()
     //   self.publicDatabase = self.container?.publicCloudDatabase
    //    self.privateDatabase = self.container?.privateCloudDatabase
    }
    
    func getBoard() {
        //***************************************
        //* Users player board
        //***************************************
        if (self.vC != nil) {

        let parseACL:PFACL = PFACL()
        parseACL.publicReadAccess = true
        //parseACL.publicWriteAccess = true
        let queryBoard = PFQuery(className:"PlayerBoard")
        queryBoard.whereKey("gameID", equalTo: (self.gameID + self.player2))
                    queryBoard.whereKey("playerID", equalTo: (self.vC?.opponentID)!)
        
        queryBoard.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {

                if objects?.count > 0 {
                    let userBoardRecord = objects![0]
                    userBoardRecord.ACL = parseACL
                 //   if (self.vC!.gameID == self.vC!.opponentID) {
                        self.player1Board = userBoardRecord.objectForKey("board") as! [Int]
                        self.vC!.player1Board = self.player1Board
                 //   }
                  //  else {
                        self.player2Board = userBoardRecord.objectForKey("board") as! [Int]
                        self.vC!.player2Board = self.player2Board
                   // }
                }
            }
            }
        }
    }
    
    
    func updateRecord() {
        print("Opponent Name: \(self.vC?.opponentName)")
        let parseACL:PFACL = PFACL()
        parseACL.publicReadAccess = true
        parseACL.publicWriteAccess = true
        
        getBoard()
        
        
        //update game record
        let query = PFQuery(className:"Game")
        query.whereKey("gameID", equalTo: self.gameID)
        query.whereKey("player2", equalTo: self.player2)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    
                        let gameRecord = objects[0]
                        gameRecord.ACL = parseACL
                   
                    self.cardStructPersonNameList = gameRecord.objectForKey("cardStructPersonNameList") as! [String]
                    self.cardStructProfilePictureList = gameRecord.objectForKey("cardStructProfilePictureList") as! [String]
                    self.gameEndStatus = gameRecord.objectForKey("gameEndStatus") as! String
                    self.isAwaitingApproval  = gameRecord.objectForKey("isAwaitingApproval") as! String
                    self.player1 = gameRecord.objectForKey("player1") as! String
                    self.player2 = gameRecord.objectForKey("player2") as! String
                    self.vC!.player2 = self.player2
                    self.whoseTurn = gameRecord.objectForKey("whoseTurn") as! String
                    self.questionText = gameRecord.objectForKey("questionText") as! String
                  //  self.player1Board = gameRecord.objectForKey("player1Board") as! [Int]
                  //  self.player2Board = gameRecord.objectForKey("player2Board") as! [Int]
                    if self.vC!.userID == self.player1 {
                        self.vC!.opponentID = self.player2
                    }
                    else {
                        self.vC!.opponentID = self.player1
                    }
                //    self.vC?.opponentName = gameRecord[""]
                    var playerString:String = "player1"
                    var otherPlayerString:String = "player2"
                    if self.gameID == self.vC!.userID {
                        playerString = "player2"
                        otherPlayerString = "player1"
                    }
                    if playerString == "player2" && (gameRecord["shuffledIDs"] as! [String])  == self.cardStructProfilePictureList {
                        var cardNames = [String]()
                        var cardIDs = [String]()
                        for card in self.vC!.childViewControllerWithType(ViewController)!.cardViews {
                            cardNames.append((card.subviews[0] as! Card).personName)
                            cardIDs.append((card.subviews[0] as! Card).profPicURL)
                        }
                        gameRecord["shuffledNames"] = cardNames
                        gameRecord["shuffledIDs"] = cardIDs
                    
                        gameRecord.saveInBackgroundWithBlock { (success, error) -> Void in
                        //    PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": opponentEmail , "message": "\(self.userName) wants to play Guesses with you!"])
                            print("push")
                        }
                        /*if let database:CKDatabase = self.publicDatabase {
                            database.saveRecord(gameRecord, completionHandler: { (record:CKRecord?, error:NSError?) in
                                if error != nil {
                                    NSLog(error!.localizedDescription)
                                }
                                else {
                                    print( "saved")
                                }
                            })
                        }*/
                        
                    }
                    else if playerString == "player1"  && (gameRecord["shuffledIDs2"] as! [String])  == self.cardStructProfilePictureList {
                        var cardNames = [String]()
                        var cardIDs = [String]()
                        for card in self.vC!.childViewControllerWithType(ViewController)!.cardViews {
                            cardNames.append((card.subviews[0] as! Card).personName)
                            cardIDs.append((card.subviews[0] as! Card).profPicURL)
                        }
                        gameRecord["shuffledNames2"] = cardNames
                        gameRecord["shuffledIDs2"] = cardIDs
                        gameRecord.saveInBackgroundWithBlock { (success, error) -> Void in
                            //    PFCloud.callFunctionInBackground("alertUser", withParameters: ["channels": opponentEmail , "message": "\(self.userName) wants to play Guesses with you!"])
                            print("push")
                        }
                        
                    }
                    
                   // self.vC!.player1Board = self.player1Board
                   // self.vC!.player2Board = self.player2Board
                    self.vC!.questionText = self.questionText
                    if self.vC!.initialLoad {
                        if self.vC!.userID != self.vC!.gameID && self.vC!.opponentID + "waiting" != self.whoseTurn {
                            self.vC!.topButtonContainer.hidden = true
                            self.vC!.topTextContainer.hidden = true
                            self.vC!.hideTopButtonVC()
                            self.vC!.hideTopTextVC()
                        }
                        else {
                            self.vC!.initialLoad = false
                            self.vC!.topButtonContainer.hidden = false
                            self.vC!.topTextContainer.hidden = false
                        }
                    }
                    self.vC!.whoseTurn = self.whoseTurn
                    
                    self.vC!.endOfGame = self.gameEndStatus
                    let opponentsCardID:String = gameRecord["\(playerString)CardID"] as! String
                    let opponentsCardName:String = gameRecord["\(playerString)CardName"] as! String
                    let myCardID:String = gameRecord["\(otherPlayerString)CardID"] as! String
                    let myCardName:String = gameRecord["\(otherPlayerString)CardName"] as! String
                    let opponentCard:Card = Card()
                    if (opponentsCardID != "") {
                        opponentCard.personName = opponentsCardName
                        opponentCard.profPicURL = opponentsCardID
                        opponentCard.profilePicture = UIImage(data: NSData(contentsOfURL: NSURL(string: opponentsCardID)!)!)!
                        self.vC!.myOpponentsCard = opponentCard
                    }
                    let myCard:Card = Card()
                    if (self.vC!.oppCard.personName == "" && otherPlayerString == "player2") {
                        myCard.personName = myCardName
                        myCard.profPicURL = myCardID
                        myCard.profilePicture = UIImage(data: NSData(contentsOfURL: NSURL(string: myCardID)!)!)!
                        self.vC!.oppCard = myCard
                        self.vC!.oppCard.frontImageView.image = UIImage(named: "oppcard")
                        self.vC!.oppCard.applyPositioningConstraintToOppImageView(self.vC!.oppCard.frontImageView)
                       
                        //cards[randCardNum]
                        let textView = self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.subviews.first
                        let constraints:[NSLayoutConstraint] = self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.constraints
                        if (textView != nil)
                        {
                                                         textView!.removeFromSuperview()
                            print("ERROR textview is nil")
                        }
                        
                        self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.addSubview(self.vC!.oppCard)
                        if (textView != nil)
                        {
                        self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.addSubview(textView!)
                        }
                            self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.addConstraints(constraints)
                        
                        self.vC!.oppCard.bindFrameToSuperviewBounds()
                        self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.hidden = false
                        
                    }
                
                    self.printGame()
                    
                    self.vC!.view.userInteractionEnabled = true
                    self.vC!.loadingView.alpha = 0.0
                    self.vC!.loadMainView.alpha = 0.0
                    //******************************
                
                }
                
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
        
      /************************************************************************************
            print("Updating game object")
            let predicate = NSPredicate(format: "gameID == '\(self.gameID)'")
       
        self.publicDatabase!.performQuery(CKQuery(recordType: "Game", predicate: predicate), inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
                
                // Check if there's an error
                if error != nil {
                    print(error?.localizedDescription)
                }
                else if records != nil {
                    
                    // No error, go through the records
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if (records?.count > 0 && self.vC != nil)
                        {
                            let gameRecord:CKRecord = records![0]
                            self.cardStructPersonNameList = gameRecord.objectForKey("cardStructPersonNameList") as! [String]
                            self.cardStructProfilePictureList = gameRecord.objectForKey("cardStructProfilePictureList") as! [String]
                            self.gameEndStatus = gameRecord.objectForKey("gameEndStatus") as! String
                            self.isAwaitingApproval  = gameRecord.objectForKey("isAwaitingApproval") as! String
                            self.player1 = gameRecord.objectForKey("player1") as! String
                            self.player2 = gameRecord.objectForKey("player2") as! String
                            
                            self.whoseTurn = gameRecord.objectForKey("whoseTurn") as! String
                            self.questionText = gameRecord.objectForKey("questionText") as! String
                            self.player1Board = gameRecord.objectForKey("player1Board") as! [Int]
                            self.player2Board = gameRecord.objectForKey("player2Board") as! [Int]
                            if self.vC!.userID == self.player1 {
                                self.vC!.opponentID = self.player2
                            }
                            else {
                                self.vC!.opponentID = self.player1
                            }
                            var playerString:String = "player1"
                            var otherPlayerString:String = "player2"
                            if self.gameID == self.vC!.userID {
                                playerString = "player2"
                                otherPlayerString = "player1"
                            }
                            if playerString == "player2" && (gameRecord["shuffledIDs"] as! [String])  == self.cardStructProfilePictureList {
                                var cardNames = [String]()
                                var cardIDs = [String]()
                                for card in self.vC!.childViewControllerWithType(ViewController)!.cardViews {
                                    cardNames.append((card.subviews[0] as! Card).personName)
                                    cardIDs.append((card.subviews[0] as! Card).profPicURL)
                                }
                                gameRecord["shuffledNames"] = cardNames
                                gameRecord["shuffledIDs"] = cardIDs
                                if let database:CKDatabase = self.publicDatabase {
                                    database.saveRecord(gameRecord, completionHandler: { (record:CKRecord?, error:NSError?) in
                                        if error != nil {
                                            NSLog(error!.localizedDescription)
                                        }
                                        else {
                                            print( "saved")
                                        }
                                    })
                                }

                            }
                            else if playerString == "player1"  && (gameRecord["shuffledIDs2"] as! [String])  == self.cardStructProfilePictureList {
                                var cardNames = [String]()
                                var cardIDs = [String]()
                                for card in self.vC!.childViewControllerWithType(ViewController)!.cardViews {
                                    cardNames.append((card.subviews[0] as! Card).personName)
                                    cardIDs.append((card.subviews[0] as! Card).profPicURL)
                                }
                                gameRecord["shuffledNames2"] = cardNames
                                gameRecord["shuffledIDs2"] = cardIDs
                                if let database:CKDatabase = self.publicDatabase {
                                    database.saveRecord(gameRecord, completionHandler: { (record:CKRecord?, error:NSError?) in
                                        if error != nil {
                                            NSLog(error!.localizedDescription)
                                        }
                                        else {
                                            print( "saved")
                                        }
                                    })
                                }

                            }
                            
                            self.vC!.player1Board = self.player1Board
                            self.vC!.player2Board = self.player2Board
                            self.vC!.questionText = self.questionText
                            if self.vC!.initialLoad {
                                if self.vC!.userID != self.vC!.gameID && self.vC!.opponentID + "waiting" != self.whoseTurn {
                                    self.vC!.topButtonContainer.hidden = true
                                    self.vC!.topTextContainer.hidden = true
                                    self.vC!.hideTopButtonVC()
                                    self.vC!.hideTopTextVC()
                                }
                                else {
                                    self.vC!.initialLoad = false
                                    self.vC!.topButtonContainer.hidden = false
                                    self.vC!.topTextContainer.hidden = false
                                }
                            }
                            self.vC!.whoseTurn = self.whoseTurn
                            
                            self.vC!.endOfGame = self.gameEndStatus
                            let opponentsCardID:String = gameRecord["\(playerString)CardID"] as! String
                            let opponentsCardName:String = gameRecord["\(playerString)CardName"] as! String
                            let myCardID:String = gameRecord["\(otherPlayerString)CardID"] as! String
                            let myCardName:String = gameRecord["\(otherPlayerString)CardName"] as! String
                                let opponentCard:Card = Card()
                            if (opponentsCardID != "") {
                            opponentCard.personName = opponentsCardName
                                opponentCard.profPicURL = opponentsCardID
                                opponentCard.profilePicture = UIImage(data: NSData(contentsOfURL: NSURL(string: opponentsCardID)!)!)!
                                self.vC!.myOpponentsCard = opponentCard
                            }
                            let myCard:Card = Card()
                            if (self.vC!.oppCard.personName == "" && otherPlayerString == "player2") {
                                myCard.personName = myCardName
                                myCard.profPicURL = myCardID
                                myCard.profilePicture = UIImage(data: NSData(contentsOfURL: NSURL(string: myCardID)!)!)!
                                self.vC!.oppCard = myCard
                                self.vC!.oppCard.frontImageView.image = UIImage(named: "oppcard")
                                self.vC!.oppCard.applyPositioningConstraintToOppImageView(self.vC!.oppCard.frontImageView)
                                
                                //cards[randCardNum]
                                let textView = self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.subviews.first
                                let constraints:[NSLayoutConstraint] = self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.constraints
                                textView!.removeFromSuperview()
                                
                                self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.addSubview(self.vC!.oppCard)
                                self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.addSubview(textView!)
                                self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.addConstraints(constraints)

                                self.vC!.oppCard.bindFrameToSuperviewBounds()
                                self.vC!.childViewControllerWithType(ViewControllerBase)!.oppCardView.hidden = false
                                
                            }
                            
                            self.printGame()
                            
                            self.vC!.view.userInteractionEnabled = true
                            self.vC!.loadingView.alpha = 0.0
                            self.vC!.loadMainView.alpha = 0.0
                            
                          //  self.vC.
                                                     //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                
            })
        *///*************************************
            self.vC?.childViewControllerWithType(ViewController)?.updatePlayerBoard()
        }

    func printGame() {
        print("Game ID: \(self.gameID)")
        print("player1: \(self.player1)")
        print("player2: \(self.player2)")
        print("whoseTurn: \(self.whoseTurn)")
        print("questionText: \(self.questionText)")
        print("gameEndStatus: \(self.gameEndStatus)")
        print("isAwaitingApproval: \(self.isAwaitingApproval)")
        print("Player1")
       // self.printBoard(self.player1Board)
        print("Player2")
      //  self.printBoard(self.player2Board)
        print()
    }
    
    func printBoard(board:[Int]) {
        var dBoard:[[Int]] = [[Int](), [Int](), [Int](), [Int]()]
        var count:Int = 0
        for r in 0...3 {
            for _ in 0...4 {
                dBoard[r].append(board[count])
                count += 1
            }
            print(dBoard[r])
        }
        
    }
    
    
}
