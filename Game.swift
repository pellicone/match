//
//  Game.swift
//  Match
//
//  Created by Daniel Pellicone on 7/3/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
import CloudKit

class Game: NSObject {
    var container:CKContainer?
    var publicDatabase:CKDatabase?
    var privateDatabase:CKDatabase?
    
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
    var vC:ViewControllerContainers?
    override init() {
        super.init()
        self.container = CKContainer.defaultContainer()
        self.publicDatabase = self.container?.publicCloudDatabase
        self.privateDatabase = self.container?.privateCloudDatabase
    }
    
    func updateRecord() {
      
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
                        if (records?.count > 0)
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
                            if self.gameID == self.vC!.userID {
                                playerString = "player2"
                            }
                            self.vC!.player1Board = self.player1Board
                            self.vC!.player2Board = self.player2Board
                            self.vC!.questionText = self.questionText
                            self.vC!.whoseTurn = self.whoseTurn
                            self.vC!.endOfGame = self.gameEndStatus
                            var opponentsCardID:String = gameRecord["\(playerString)CardID"] as! String
                            var opponentsCardName:String = gameRecord["\(playerString)CardName"] as! String
                            
                                var opponentCard:Card = Card()
                            if (opponentsCardID != "") {
                            opponentCard.personName = opponentsCardName
                                opponentCard.profPicURL = opponentsCardID
                                opponentCard.profilePicture = UIImage(data: NSData(contentsOfURL: NSURL(string: opponentsCardID)!)!)!
                                self.vC!.myOpponentsCard = opponentCard
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
        self.printBoard(self.player1Board)
        print("Player2")
        self.printBoard(self.player2Board)
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
