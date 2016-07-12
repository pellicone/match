//
//  Card.swift
//  Match
//
//  Created by Daniel Pellicone on 6/16/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit

class Card: UIView {
    static var cardHeight:CGFloat = 82
    static var cardWidth:CGFloat = 60
    var frontImageView:UIImageView = UIImageView()
    var backImageView:UIImageView = UIImageView()
    var profImageView:UIImageView = UIImageView()
    var profPicURL:String = String()
    var personName:String = String("") {
        didSet {
            self.personNameLabel.text = self.personName
            self.personNameLabel.font = UIFont(name: "AvenirNext-Medium", size: 9.0)
            self.personNameLabel.numberOfLines = 2
            self.personNameLabel.textAlignment = NSTextAlignment.Center
            print(self.personNameLabel.text!)
           
      //      self.addSubview(self.personNameLabel)
           // self.setNeedsDisplay()
        }
    }
    var personNameLabel:UILabel = UILabel()
    var profilePicture:UIImage = UIImage() {
        didSet {
            self.profImageView.image = profilePicture
        }
    }
    var cardValue:Int = 0
 //   var cardNames:[String] = ["card1", "card2", "card3", "card4", "card5", "card6", "card7", "card8", "card9", "card10", "card11", "card12", "card13"]
    var isFlipped:Bool = false {
        didSet {
            if !self.isFlipped {
                
              /*  UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.frontImageView.alpha = 0.0
                    self.profImageView.alpha = 0
                    }, completion: nil)*/
                UIView.transitionFromView(self.backImageView, toView: self.personNameLabel, duration: 0.4, options: UIViewAnimationOptions.TransitionFlipFromTop, completion: nil)
                
                self.setConstraintsUILabel(self.personNameLabel)
                //self.applyPositioningConstraintToImageView(frontImageView)
               // self.applyPositioningConstraintToProfImageView(profImageView)
            }
            else {
                /*UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.frontImageView.alpha = 1
                      self.profImageView.alpha = 1
                    }, completion: nil)*/
                UIView.transitionFromView(self.personNameLabel, toView: self.backImageView, duration: 0.4, options: UIViewAnimationOptions.TransitionFlipFromBottom, completion: nil)
                self.applySizeConstraintToImageView(self.backImageView)
                self.applyPositioningConstraintToImageView(backImageView)
               
              //  self.applyPositioningConstraintToProfImageView(profImageView)
                
            }
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        // TODO: set default image for the imageview
        self.backImageView.image = UIImage(named: "back")
        self.addSubview(self.backImageView)
        self.addSubview(self.profImageView)
        self.addSubview(self.frontImageView)
        self.addSubview(self.personNameLabel)
        
        self.applySizeConstraintToImageView(self.backImageView)
        self.applyPositioningConstraintToImageView(self.backImageView)
        self.applySizeConstraintToProfImageView(self.profImageView)
        self.applyPositioningConstraintToProfImageView(self.profImageView)
        self.applySizeConstraintToImageView(self.frontImageView)
        self.applyPositioningConstraintToImageView(self.frontImageView)
        self.setConstraintsUILabel(self.personNameLabel)
    //    self.applySizeConstraintToImageView(self.personNameLabel)
   //     self.applyPositioningConstraintToImageView(self.personNameLabel)
        // self.addSubview(self.personNameLabel)
        //self.applySizeConstraintToImageView(profImageView)
       // self.applyPositioningConstraintToImageView(profImageView)
       
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func applySizeConstraintToImageView(imageView:UIImageView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // TODO: add the imageview to the view
        
        // TODO: set constrains for the imageview
      //  let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: Card.cardHeight)
        //let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: Card.cardWidth)
        //imageView.addConstraints([heightConstraint, widthConstraint])

      //  self.addSubview(imageView)
        imageView.bindFrameToSuperviewBounds()
    }
    
    func applyPositioningConstraintToImageView(imageView:UIImageView) {
        
        let verticalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        let horizontalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        
        self.addConstraints([verticalConstraint, horizontalConstraint])
        
    }
    
    func applyPositioningConstraintToOppImageView(imageView:UIImageView) {
        
        let verticalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -10)
        
        let horizontalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -10)
        self.backImageView.image = UIImage(named: "oppcard")
        self.addConstraints([verticalConstraint, horizontalConstraint])
        
    }
    func applyPositioningConstraintToOppEndImageView(imageView:UIImageView) {
        
        let verticalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -40)
        
        let horizontalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -40)
        self.backImageView.image = UIImage(named: "oppcard")
        self.addConstraints([verticalConstraint, horizontalConstraint])
        
    }
    func applySizeConstraintToProfImageView(imageView:UIImageView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIViewContentMode.ScaleAspectFill;
        imageView.clipsToBounds = true;

    }
    
    func applyPositioningConstraintToProfImageView(imageView:UIImageView) {
        let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: -4)
        
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: -4)
        
        
        
        let verticalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 2)
        
        let horizontalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 2)
        
        self.addConstraints([widthConstraint, heightConstraint, verticalConstraint, horizontalConstraint])
        self.setImage()
    }
    
    func applyPositioningConstraintToOppProfImageView(imageView:UIImageView) {
        let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: -30)
        
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: -30)
        
        
        
        let verticalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 15)
        
        let horizontalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 15)
        
        self.addConstraints([widthConstraint, heightConstraint, verticalConstraint, horizontalConstraint])
        //self.setImage()
    }


    func setConstraintsUILabel(imageView:UILabel)
    {
        imageView.translatesAutoresizingMaskIntoConstraints = false
      //  imageView.contentMode = UIViewContentMode.ScaleAspectFill;
      //  imageView.clipsToBounds = true;
        // TODO: add the imageview to the view
       // self.addSubview(imageView)
        // TODO: set constrains for the imageview
        //   let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: Card.cardWidth * 0.88)
        //  let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: Card.cardWidth * 0.88)
        //   imageView.addConstraints([heightConstraint, widthConstraint])
        //  imageView.bindFrameToSuperviewBounds1()

        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Height, multiplier: 0.3, constant: 0)
        
        let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: -4)
        
        
        
        let verticalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.profImageView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -3)
        
        let horizontalConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.frontImageView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 2)
        
        self.addConstraints([widthConstraint, heightConstraint, verticalConstraint, horizontalConstraint])
     
    }
    
    func setImage() {
        self.frontImageView.image = UIImage(named: "card1")
    }
    
    func toggleFlip() {
        if isFlipped {
            isFlipped = false
        }
        else {
            isFlipped = true
        }
    }
}

extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
    
}
