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
            
    @Published var cardDisplaying: Bool = true
    @Published var userDisplaying: Bool = false
    
    @Published var currMiddleImg: String = "AddPoll"
    
    func tapCard() {
        if currMiddleImg != "bigX" {
            cardDisplaying = true
            userDisplaying = false
        }
    }
    
    func tapUser() {
        if currMiddleImg != "bigX" {
            cardDisplaying = false
            userDisplaying = true
        }
    }
    
    func newPoll() {
        if cardDisplaying == false && userDisplaying == false {
            resetMiddelImg()
            tapCard()
        } else {
            currMiddleImg = "bigX"
            cardDisplaying = false
            userDisplaying = false
        }
    }
    
    private func resetMiddelImg() {
        currMiddleImg = "AddPoll"
    }
}
