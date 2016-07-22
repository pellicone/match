//
//  GameListCell.swift
//  Guesses
//
//  Created by Daniel Pellicone on 7/21/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit

class GameListCell: UITableViewCell {
    var imageView2:UIImageView = UIImageView()
    var uiView1:UIView = UIView()
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var profPicView: UIImageView!
   
    override func layoutSubviews() {
        dispatch_async(dispatch_get_main_queue()){
            super.layoutSubviews()
            
        }
    }
}
