//
//  PollItem.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class PollItem: Hashable, ObservableObject {
    
    var title: String
//    var insertionIndex: Int?
    var poll: CKRecord.Reference
    var votedBy: Set<CKRecord.Reference>
    
    var record: CKRecord
    
    init(record: CKRecord) {
        self.title = record[PollItemKeys.title.rawValue] as! String
        self.votedBy = record[PollItemKeys.votedBy.rawValue] as! Set<CKRecord.Reference>
        guard let poll = record[PollItemKeys.poll.rawValue] as? CKRecord.Reference else {
            fatalError("This PollItem doesn't belong to any Poll!")
        }
        self.poll = poll

        self.record = record
    }
    
    static func create(title: String, parent: CKRecord) -> CKRecord {
        let record = CKRecord(recordType: RecordType.pollItem.rawValue)
        record.setValue(title, forKey: PollItemKeys.title.rawValue)
        
//        record.setParent(parent.recordID)
        let parentRef = CKRecord.Reference(recordID: parent.recordID, action: .deleteSelf)
        record.setValue(parentRef, forKey: PollItemKeys.poll.rawValue)
//        record.setValue(self.votedBy, forKey: PollItemKeys.votedBy.rawValue)
        
        RecordOperation.batchSave(save: [record], delete: [])

//        ViewModel.save(record)
        return record
    }
    
    enum PollItemKeys: String {
        case title = "Title"
        case poll = "Poll"
        case votedBy = "VotedBy"
    }
    
    // MARK: Hashability
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(poll)
        hasher.combine(votedBy)
    }
    
    static func == (lhs: PollItem, rhs: PollItem) -> Bool {
        return lhs.title == rhs.title
//            && lhs.insertionIndex == rhs.insertionIndex
            && lhs.poll == rhs.poll
            && lhs.votedBy == rhs.votedBy
    }
}
