//
//  MyStationsCollectionViewController.swift
//  Stationdose
//
//  Created by Hoof on 5/2/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MyStationsCollectionViewCell"

class MyStationsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let kItemSpacing: CGFloat = 0.0
    weak var parentController: HomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        self.collectionView?.allowsSelection = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addStationsPressed (sender: AnyObject?) {
        self.parentController?.addStations(sender!)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if parentController?.myStations != nil {
            return parentController!.myStations.count
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyStationsCollectionViewCell
    
        if let station = parentController?.myStations[indexPath.row] {
            cell.station = station
            
            if let sponsoredUrl = station.art where sponsoredUrl.characters.count > 0 {
                print("sponsoredUrl " + sponsoredUrl)
                if let URL = NSURL(string: sponsoredUrl) {
                    cell.imageView?.af_setImageWithURL(URL, placeholderImage: UIImage(named: "stations-list-placeholder"))
                } else {
                    cell.imageView!.image = UIImage(named: "stations-list-placeholder")
                }
            } else {
                cell.imageView!.image = UIImage(named: "stations-list-placeholder")
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let w = UIScreen.mainScreen().bounds.width
        return CGSize(width: w/2, height: w/2)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(self.view.bounds.width, 233.0);
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableview: UICollectionReusableView?
        if kind == UICollectionElementKindSectionFooter {
            reusableview = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "EmptyView", forIndexPath: indexPath)
            if(parentController!.myStations.count > 0) {
                reusableview!.hidden = true
                reusableview!.frame = CGRectMake(0, 0, 0, 0);
            }else{
                reusableview!.hidden = false
//                reusableview!.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }
        }
        return reusableview!
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let station = parentController?.myStations[indexPath.row] {
            parentController!.selectedStation = station
            parentController!.showStationAtIndexPath(indexPath)
        }
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
