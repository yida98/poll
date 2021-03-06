//
//  Poll.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class Poll: Hashable, ObservableObject {
    
    var title: String
    var pollItemRefs: [CKRecord.Reference]
    var pollItems = [PollItem]()
    var totalVotes: Int = 0
    var seenBy: Set<CKRecord.Reference>
    var creator: CKRecord.Reference
    var record: CKRecord
    
    init(record: CKRecord) {
        self.title = record[PollKeys.title.rawValue] as! String
        if let _ = record[PollKeys.pollItems.rawValue] as? [CKRecord.Reference] {
            self.pollItemRefs = record[PollKeys.pollItems.rawValue] as! [CKRecord.Reference]
        } else {
            self.pollItemRefs = [CKRecord.Reference]()
        }
        if let seenBy = record[PollKeys.seenBy.rawValue] as? Set<CKRecord.Reference> {
            self.seenBy = seenBy
        } else {
            self.seenBy = Set<CKRecord.Reference>()
        }
        // Query all pollItems
//        RecordOperation.queryPollItems(for: record) { items in
//            self.pollItems = items
//        }
         
        guard let parent = record[PollKeys.creator.rawValue] as? CKRecord.Reference else {
            fatalError("This Poll doesn't belong to any User!")
        }
        self.creator = parent

        self.record = record
    }
    
    static func create(title: String, creator: CKRecord, pollRecords: [CKRecord]) -> CKRecord { // TODO: Pass in CKRecord.ID for creator pls
        let record = CKRecord(recordType: RecordType.poll.rawValue)
        record.setValue(title, forKey: PollKeys.title.rawValue)
        
        let creatorReference = CKRecord.Reference(recordID: creator.recordID, action: .deleteSelf)
        record.setValue(creatorReference, forKey: PollKeys.creator.rawValue)
        
        var pollItemRefs = [CKRecord.Reference]()
        for item in pollRecords {
            let itemRef = CKRecord.Reference(record: item, action: .deleteSelf)
            pollItemRefs.append(itemRef)
        }
        record.setValue(pollItemRefs, forKey: PollKeys.pollItems.rawValue)

        RecordOperation.batchSave(save: [record], delete: [])
//        ViewModel.save(record)
        return record
    }

    enum PollKeys: String {
        case title = "Title"
        case pollItems = "PollItems"
        case seenBy = "SeenBy"
        case creator = "Creator"
        
    }
    
    // MARK: Hashability
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(pollItemRefs)
        hasher.combine(seenBy)
        hasher.combine(totalVotes)
    }
    
    static func == (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.title == rhs.title
            && lhs.pollItemRefs == rhs.pollItemRefs
            && lhs.seenBy == rhs.seenBy
            && lhs.totalVotes == rhs.totalVotes
    }
}


extension Poll {
    
    // MARK: Class methods
    
    func addPollItems(itemRecords: [CKRecord]) {
        var childRefs = [CKRecord.Reference]()
        for record in itemRecords {
            childRefs.append(CKRecord.Reference(record: record, action: .none))
        }
        self.record.setValue(childRefs, forKey: Poll.PollKeys.pollItems.rawValue)
        var saves = itemRecords
        saves.append(self.record)
        RecordOperation.batchSave(save: saves, delete: [])
    }
    
    func getPollItems(completionHandler: @escaping (_ pollItemResults: [PollItem]) -> () = { _ in }) {
        RecordOperation.queryPollItems(with: self.pollItemRefs) { results in
            self.pollItems = results
            completionHandler(results)
        }
    }
    
}


