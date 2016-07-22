//
//  FriendCollect.swift
//  Guesses
//
//  Created by Daniel Pellicone on 7/15/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit

class FriendCollect: UICollectionViewCell {
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //initialize all your subviews.
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
