//
//  inviteListCell.swift
//  Guesses
//
//  Created by Daniel Pellicone on 7/16/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit

class inviteListCell: UITableViewCell {
    var imageView2:UIImageView = UIImageView()
    var uiView1:UIView = UIView()
    
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    override func layoutSubviews() {
        dispatch_async(dispatch_get_main_queue()){
            super.layoutSubviews()
        
      }
    }
}
