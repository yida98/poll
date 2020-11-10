//
//  MenuModel.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-12.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation

class MenuModel: ObservableObject {
    
    static let shared = MenuModel()
    var addViewModel = AddViewModel.shared
            
    @Published var cardDisplaying: Bool = true
    @Published var userDisplaying: Bool = false
    
    @Published var currMiddleImg: String = AssetImages.addPoll.rawValue {
        didSet {
            addViewModel.toggleShow()
        }
    }
    
    
    
    func tapCard() {
        if currMiddleImg != AssetImages.bigX.rawValue {
            cardDisplaying = true
            userDisplaying = false
        }
    }
    
    func tapUser() {
        if currMiddleImg != AssetImages.bigX.rawValue {
            cardDisplaying = false
            userDisplaying = true
        }
    }
    
    func newPoll() {
        if cardDisplaying == false && userDisplaying == false {
            resetMiddelImg()
            tapCard()
        } else {
            currMiddleImg = AssetImages.bigX.rawValue
            cardDisplaying = false
            userDisplaying = false
        }
    }
    
    private func resetMiddelImg() {
        currMiddleImg = AssetImages.addPoll.rawValue
    }
}

enum AssetImages: String {
    
    case bigX = "bigX"
    case addPoll = "addPoll"
    
}
