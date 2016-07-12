//
//  ViewControllerBase.swift
//  Match
//
//  Created by Daniel Pellicone on 6/30/16.
//  Copyright © 2016 Daniel Pellicone. All rights reserved.
//

import UIKit

class ViewControllerBase: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
    @IBOutlet weak var solveButtonView: UIView!
    @IBOutlet weak var whiteBaseView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var solveButton: UIButton!
    //var updateOpponentBoardTimer:NSTimer?
    @IBOutlet weak var oppCardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.whiteBaseView.addDropShadowToBaseView(self.whiteBaseView)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.reloadData()
        self.solveButton.addTarget(self, action: #selector(ViewControllerBase.pressSolveButton), forControlEvents: UIControlEvents.TouchUpInside)
      
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.parentViewController as! ViewControllerContainers).opponentBoard.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("opponentCell", forIndexPath: indexPath) as UICollectionViewCell
        let oppCell = cell as! OpponentCell
        let dataToDisplay:Int = (self.parentViewController as! ViewControllerContainers).opponentBoard[indexPath.row]
        //cell.viewWithTag(2)?.backgroundColor = UIColor.redColor()
        if dataToDisplay == 0 {
            oppCell.imageView.image = UIImage(named: "dotopen")
           // (cell.viewWithTag(2)!.viewWithTag(3) as! UIImageView).image = UIImage(contentsOfFile: "dotopen")
        }
     
        else {
            
            oppCell.imageView.image = UIImage(named: "dot")
              //  (cell.viewWithTag(2)! as! UIImageView).image = UIImage(contentsOfFile: "dot")
         
        }
        return cell
    }
    func pressSolveButton() {
        (self.parentViewController as! ViewControllerContainers).solveButtonPressed()
    }
}

extension UIView {
    
    func addDropShadowToBaseView(targetView:UIView? ){
        targetView!.layer.masksToBounds =  false
        targetView!.layer.shadowColor = UIColor.darkGrayColor().CGColor;
        targetView!.layer.shadowOffset = CGSizeMake(-2.0, -2.0)
        targetView!.layer.shadowOpacity = 1.0
    }
}