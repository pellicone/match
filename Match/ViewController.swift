//
//  ViewController.swift
//  Match
//
//  Created by Daniel Pellicone on 6/28/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
import CloudKit
class ViewController: UIViewController {
    
    var gameModel:GameModel = GameModel()
    var cards:[Card] = [Card]()
    var gameID:String = String()
    var container:CKContainer?
    var publicDatabase:CKDatabase?
    var privateDatabase:CKDatabase?
    var boardString:String = String()
    var userID:String = String()
    var thisPlayersBoard:[Int] = [Int]()
    var opponentBoard:[Int] = [Int]()
    var cardViews:[UIView] = [UIView]()
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var card00: UIView!
    @IBOutlet weak var card01: UIView!
    @IBOutlet weak var card02: UIView!
    @IBOutlet weak var card03: UIView!
    @IBOutlet weak var card04: UIView!
    @IBOutlet weak var card10: UIView!
    @IBOutlet weak var card11: UIView!
    @IBOutlet weak var card12: UIView!
    @IBOutlet weak var card13: UIView!
    @IBOutlet weak var card14: UIView!
    @IBOutlet weak var card20: UIView!
    @IBOutlet weak var card21: UIView!
    @IBOutlet weak var card22: UIView!
    @IBOutlet weak var card23: UIView!
    @IBOutlet weak var card24: UIView!
    @IBOutlet weak var card30: UIView!
    @IBOutlet weak var card31: UIView!
    @IBOutlet weak var card32: UIView!
    @IBOutlet weak var card33: UIView!
    @IBOutlet weak var card34: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container = CKContainer.defaultContainer()
        self.publicDatabase = self.container?.publicCloudDatabase
        self.privateDatabase = self.container?.privateCloudDatabase

        self.cards = gameModel.getCards()
        self.layoutCards()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
    
      
  
        
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Width, multiplier: 1.115, constant: 0)
        
        
        self.contentView.addConstraints([heightConstraint])
        
        
        
        self.boardString = "player1Board"
        if (self.userID != self.gameID) {
            boardString = "player2Board"
        }
        var boardProto:[Int] = [Int]()
        for i in 0...cards.count {
            if (i < 20) {
                boardProto.append(1)
            }
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
    
    func layoutCards() {
        //******************************
        

                
        
        
        
//****************************************
        self.cardViews = [self.card00, self.card01, self.card02,  self.card03,  self.card04, self.card10, self.card11, self.card12,  self.card13,  self.card14, self.card20, self.card21, self.card22,  self.card23,  self.card24, self.card30, self.card31, self.card32,  self.card33,  self.card34]
        
        let minNum:Int = min(self.cards.count, self.cardViews.count)
       
        for i in 0...(minNum - 1) {
            self.cardViews[i].addSubview(cards[i])
            
        }
       
        for card in self.cards {
            if (card.superview != nil) {
                let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.cardTapped(_:)))
                card.addGestureRecognizer(tapGestureRecognizer)
                card.bindFrameToSuperviewBounds()
                
            }
            
        }
        
    }
   
    func cardTapped(recognizer:UITapGestureRecognizer) {
        let cardThatWasTapped:Card = recognizer.view as! Card
        if !(self.parentViewController as! ViewControllerContainers).isSolving {
        
        //let cardIndex:Int = self.cardV.indexOf(cardThatWasTapped.superview!)!
       cardThatWasTapped.toggleFlip()
            self.updatePlayerBoard()
        
        print("tapped")
        }
        else {
            //let cardThatWasTapped:Card = recognizer.view as! Card
            print("I am guessing that your card is: \(cardThatWasTapped.personName)")
            (self.parentViewController as! ViewControllerContainers).isSolving = false
           
            let predicate = NSPredicate(format: "gameID == '\(self.gameID)'")
            var playerString:String = "player1"
            if self.gameID == self.userID {
                playerString = "player2"
            }
            self.publicDatabase!.performQuery(CKQuery(recordType: "Game", predicate: predicate), inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else if records != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        if (records?.count > 0)
                        {
                            let gameRecord:CKRecord = records![0]
                            let opponentsCardID:String = gameRecord["\(playerString)CardID"] as! String
                            let opponentsCardName:String = gameRecord["\(playerString)CardName"] as! String
                            if opponentsCardID == cardThatWasTapped.profPicURL {
                                print("You won!")
                                let opponentCard:Card = Card()
                                opponentCard.personName = opponentsCardName
                                opponentCard.profPicURL = opponentsCardID
                                opponentCard.profilePicture = UIImage(data: NSData(contentsOfURL: NSURL(string: opponentsCardID)!)!)!
                                (self.parentViewController as! ViewControllerContainers).myOpponentsCard = opponentCard
                               
                                (self.parentViewController as! ViewControllerContainers).endOfGame = self.userID
                                gameRecord["gameEndStatus"] = self.userID
                                
                            } else {
                                
                                (self.parentViewController as! ViewControllerContainers).solveLabel.hidden = true
                                (self.parentViewController as! ViewControllerContainers).waitingLabel.hidden = false
                                gameRecord["whoseTurn"] = (self.parentViewController as! ViewControllerContainers).opponentID
                                
                            }
                            
                            
                                
                            
                            self.publicDatabase?.saveRecord(gameRecord) { (record, error) in if error != nil {
                                (self.parentViewController as! ViewControllerContainers).isSolving = true
                                self.cardTapped(recognizer)
                                print("error")
                            }
                                else {
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    print("starting the timer up")
                                    if (!cardThatWasTapped.isFlipped)
                                    {self.cardTapped(recognizer)
                                    }
                                     if opponentsCardID != cardThatWasTapped.profPicURL {
                                        (self.parentViewController as! ViewControllerContainers).updateGameTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: (self.parentViewController as! ViewControllerContainers).game, selector: #selector(Game.updateRecord), userInfo: nil, repeats: true)
                                    }
                                }
                                
                                }
                           
                            
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            })

        }
        
        
    }
    
    func updatePlayerBoard() {
        print("Updating game object")
        let predicate = NSPredicate(format: "gameID == '\(self.gameID)'")
        
        self.publicDatabase!.performQuery(CKQuery(recordType: "Game", predicate: predicate), inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else if records != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    if (records?.count > 0)
                    {
                        let gameRecord:CKRecord = records![0]
                        var boardTemp:[Int] = gameRecord[self.boardString] as! [Int]
                        let minNum:Int = min(self.cards.count, self.cardViews.count)
                        for i in 0...minNum - 1 {
                            if (self.cards[i].isFlipped) {
                               boardTemp[i] = 0
                            }
                            else {
                               boardTemp[i] = 1
                            }
                        }
                        self.thisPlayersBoard = boardTemp
                      /*  if (self.boardString == "player1Board") {
                            self.opponentBoard = gameRecord["player2Board"] as! [Int]
                        }
                        else {
                            self.opponentBoard = gameRecord["player1Board"] as! [Int]
                        }*/
                        gameRecord[self.boardString] = self.thisPlayersBoard
                       // (self.parentViewController as! ViewControllerContainers).opponentBoard = self.opponentBoard
                        self.publicDatabase?.saveRecord(gameRecord) { (record, error) in }
                       
                        
                    }
                    
                }
                
            }
            
            
        })
        

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

extension UIViewController {
    
    func childViewControllerWithType<ViewController>(type: ViewController.Type) -> ViewController? {
        
        if let vc = self as? ViewController {
            return vc
        }
        
        for viewController in self.childViewControllers {
            if let vc:UIViewController = viewController as UIViewController {
                if let child = vc.childViewControllerWithType(type) {
                    return child
                }
            }
        }
        
        return nil
    }
}
