//
//  PollItem.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class PollItem: Hashable {
    
    var title: String
    var insertionIndex: Int?
    var poll: Poll
    var votedBy: Set<User>
    
    init(title: String, parent: Poll) {
        self.title = title
        self.poll = parent
        self.votedBy = Set<User>()
    }
    
    // MARK: Hashability
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(poll)
        hasher.combine(votedBy)
    }
    
    static func == (lhs: PollItem, rhs: PollItem) -> Bool {
        return lhs.title == rhs.title
            && lhs.insertionIndex == rhs.insertionIndex
            && lhs.poll == rhs.poll
            && lhs.votedBy == rhs.votedBy
    }
}
