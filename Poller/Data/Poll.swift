//
//  Poll.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class Poll: Hashable {
    
    var title: String
    var pollItems: [PollItem]
    var totalVotes: Int = 0
    var seenBy: [User]
    
    init(title: String) {
        self.title = title
        self.pollItems = [PollItem]()
        self.seenBy = [User]()
    }
    
    // MARK: Hashability
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(pollItems)
        hasher.combine(seenBy)
        hasher.combine(totalVotes)
    }
    
    static func == (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.title == rhs.title
            && lhs.pollItems == rhs.pollItems
            && lhs.seenBy == rhs.seenBy
            && lhs.totalVotes == rhs.totalVotes
    }
}
