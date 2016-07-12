//
//  OpponentCell.swift
//  Match
//
//  Created by Daniel Pellicone on 7/6/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit

class OpponentCell: UICollectionViewCell {
   
    @IBOutlet weak var imageView: UIImageView!
    override init(frame: CGRect) {
            super.init(frame: frame)
            //initialize all your subviews.
            self.imageView.image = UIImage(named: "dot")
        }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    }
