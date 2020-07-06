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
    var polls: [CKRecord.Reference]
    var votedFor: Set<CKRecord.Reference>
    var pollsSeen: Set<CKRecord.Reference>
    
    var record: CKRecord
    
    init(record: CKRecord) {
        self.accountName = ViewModel.shared.userCKName
        self.polls = record[User.UserKeys.polls.rawValue] as! [CKRecord.Reference]
        self.votedFor = record[User.UserKeys.votedFor.rawValue] as! Set<CKRecord.Reference>
        self.pollsSeen = record[User.UserKeys.pollsSeen.rawValue] as! Set<CKRecord.Reference>
        
        self.record = record
    }
    
    static func create(with name: String = ViewModel.shared.userCKName) -> CKRecord {
        let record = CKRecord(recordType: RecordType.user.rawValue)
        record.setValue(name, forKey: UserKeys.accountName.rawValue)
        
        ViewModel.batchSave(save: [record], delete: [])
        //ViewModel.save(record)
        
        return record
    }
        
    enum UserKeys: String {
        case accountName = "AccountName"
        case polls = "Polls"
        case votedFor = "VotedFor"
        case pollsSeen = "PollsSeen"
    }
    
    // MARK: Hashability
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(accountName)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.accountName == rhs.accountName
    }
    
}
