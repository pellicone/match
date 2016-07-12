//
//  ViewControllerTitle.swift
//  Match
//
//  Created by Daniel Pellicone on 6/30/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit

class ViewControllerTitle: UIViewController {
    @IBOutlet weak var whiteView: UIView!
    override func viewDidLoad() {
        self.whiteView.addDropShadowToView(self.whiteView)
    }
}

extension UIView {
    
    func addDropShadowToView(targetView:UIView? ){
        targetView!.layer.masksToBounds =  false
        targetView!.layer.shadowColor = UIColor.darkGrayColor().CGColor;
        targetView!.layer.shadowOffset = CGSizeMake(2.0, 2.0)
        targetView!.layer.shadowOpacity = 1.0
    }
}
