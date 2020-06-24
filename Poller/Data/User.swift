//
//  User.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class User: Hashable {
    
    var accountName: String
    var polls: Set<Poll>
    var votedFor: Set<PollItem>
    var pollsSeen: Set<Poll>
    
    init() {
        self.accountName = ViewModel.shared.userCKName
        self.polls = Set<Poll>()
        self.votedFor = Set<PollItem>()
        self.pollsSeen = Set<Poll>()
    }
    
    // MARK: Hashability
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(accountName)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.accountName == rhs.accountName
    }
    
}
