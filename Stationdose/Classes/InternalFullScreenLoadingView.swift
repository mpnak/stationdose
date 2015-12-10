//
//  InternalFullScreenLoadingView.swift
//  Stationdose
//
//  Created by Developer on 12/10/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class InternalFullScreenLoadingView: UIView {

    class func instanceFromNib() -> InternalFullScreenLoadingView {
        return UINib(nibName: "InternalFullScreenLoadingView", bundle: nil).instantiateWithOwner(self, options: nil).first as! InternalFullScreenLoadingView
    }


}
