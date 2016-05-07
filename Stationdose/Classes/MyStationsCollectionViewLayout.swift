//
//  MyStationsCollectionViewLayout.swift
//  Stationdose
//
//  Created by Hoof on 5/3/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

let MyStationsLayoutCellKind = "StationCell"

class MyStationsCollectionViewLayout: UICollectionViewFlowLayout {

    var itemWidth: CGFloat = 0.0
    let itemSpacing: CGFloat = 0
    var layoutInfo: [NSIndexPath:UICollectionViewLayoutAttributes] = [NSIndexPath:UICollectionViewLayoutAttributes]()
    var maxXPos: CGFloat = 0
    var numColumns = 2
    
    override init() {
        super.init()
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup() {
        itemWidth = UIScreen.mainScreen().bounds.width/2
        self.itemSize = CGSizeMake(itemWidth, itemWidth)
        
    }
    
//    override func prepareLayout() {
//        layoutInfo = [NSIndexPath:UICollectionViewLayoutAttributes]()
//        
//        let numberOfSections = self.collectionView!.numberOfItemsInSection(0)
//        for i in 0..<numberOfSections {
//            let indexPath = NSIndexPath(forRow: i, inSection: 0)
//            let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
//            itemAttributes.frame = frameForItemAtIndexPath(indexPath)
//            if itemAttributes.frame.origin.x > maxXPos {
//                maxXPos = itemAttributes.frame.origin.x
//            }
//            layoutInfo[indexPath] = itemAttributes
//        }
//    }
    
//    func frameForItemAtIndexPath(indexPath: NSIndexPath) -> CGRect {
//        let maxHeight = self.collectionView!.frame.height - 20
//        let numRows = floor((maxHeight+self.minimumLineSpacing)/(itemWidth+self.minimumLineSpacing))
//        
//        let currentColumn = floor(CGFloat(indexPath.row)/numRows)
//        let currentRow = (CGFloat(indexPath.row) % numRows)
//        
//        let xPos = currentRow % 2 == 0 ? currentColumn*(itemWidth+self.minimumInteritemSpacing) : currentColumn*(itemWidth+self.minimumInteritemSpacing)+itemWidth
//        let yPos = currentRow*(itemWidth+self.minimumLineSpacing)
//        
//        let rect: CGRect = CGRectMake(xPos, yPos, itemWidth, itemWidth)
//        return rect
//    }
    
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        
//        var reusableview: UICollectionReusableView?
//        if kind == UICollectionElementKindSectionFooter {
//            reusableview = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "EmptyView", forIndexPath: indexPath)
//            if(parentController!.myStations.count > 0) {
//                reusableview!.hidden = true
//                reusableview!.frame = CGRectMake(0, 0, 0, 0);
//            }else{
//                reusableview!.hidden = false
//                reusableview!.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//            }
//        }
//        return reusableview!
//    }
}
