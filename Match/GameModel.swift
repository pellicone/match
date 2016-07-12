//
//  GameModel.swift
//  Match
//
//  Created by Daniel Pellicone on 6/16/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class GameModel: NSObject {
    var cards:[CardStruct] = [CardStruct]()
    func getCards() -> [Card] {
        var generatedCards:[Card] = [Card]()
        // generate some card objects
        let numFriends:Int = cards.count
        for index in 1...numFriends {
           // print ("out")
     
            // place card objects into the array
            let card:Card = Card()
            card.profilePicture = cards[index - 1].profilePicture
            card.personName = cards[index - 1].personName
            card.profPicURL = cards[index - 1].profilePictureURL
            print(card.personName)
            //print(card.profilePicture)
            //self.cards[index].isFlipped = true
            generatedCards.append(card)
        }
 
        // Randomize the cards
        for index in 0...(generatedCards.count - 1) {
            let currentCard:Card = generatedCards[index]
            // Randomly choose another index
            let randomIndex: Int = Int(arc4random_uniform(UInt32(numFriends)))
            
            generatedCards[index] = generatedCards[randomIndex]
            generatedCards[randomIndex] = currentCard
            
        }
        //self.setFacebookProfiles(generatedCards)

        return generatedCards
    }
    
    func setFacebookProfiles(cards:[Card]) {
        let params = ["fields": "picture.type(large),id,email,name,username"]
        let request = FBSDKGraphRequest(graphPath: "me/invitable_friends?limit=5000", parameters: params)
        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error != nil {
                _ = error.localizedDescription
            }
            else if result.isKindOfClass(NSDictionary){
                /* Handle response */
                if let dict = result as? [String: AnyObject] {
                    _ = dict["data"]!.count
                    for index in 0...20 - 1{
                        if let dict2 = dict["data"]![index]["picture"] as? [String: AnyObject] {
                            let urlAny:AnyObject! = dict2["data"]!["url"]
                            let urlString:String = String(urlAny)
                            let
                            url = NSURL(string: urlString)
                            let data = NSData(contentsOfURL : url!)
                            let image = UIImage(data : data!)
                            cards[index].profilePicture = image!
                            
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    
}
