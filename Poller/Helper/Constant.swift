//
//  Constant.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-05.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class Constant {
    
    static var screenSize: CGRect {
        return UIScreen.main.bounds
    }
    
    static var menuBarHeight: CGFloat = CGFloat(107)
    
    static var menuBarItemSize: CGSize {
        return CGSize(width: 36, height: 50)
    }
    
    // MARK: GeoView
    
    static var pollSize: CGSize {
        return CGSize(width: Constant.screenSize.width - 42, height: 680)
    }
    
    static var pollItemSize: CGSize {
        return CGSize(width: Constant.pollSize.width - 80, height: 40)
    }
    
    static var pollItemInset: CGFloat = 1
    
    static var pollItemInsetSize: CGSize = CGSize(width: Constant.pollItemSize.width - (Constant.pollItemInset * 2), height: Constant.pollItemSize.height - (Constant.pollItemInset * 2))
}
