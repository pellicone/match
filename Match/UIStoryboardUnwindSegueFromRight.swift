//
//  UIStoryboardUnwindSegueFromRight.swift
//  Guesses
//
//  Created by Daniel Pellicone on 7/16/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit

class UIStoryboardUnwindSegueFromRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, belowSubview: src.view)
        src.view.transform = CGAffineTransformMakeTranslation(0, 0)
        
        UIView.animateWithDuration(0.25,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    src.view.transform = CGAffineTransformMakeTranslation(src.view.frame.size.width, 0)
            },
                                   completion: { finished in
                                    src.dismissViewControllerAnimated(false, completion: nil)
            }
        )
    }
}