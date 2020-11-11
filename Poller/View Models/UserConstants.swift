//
//  UserConstants.swift
//  Poller
//
//  Created by Yida Zhang on 2020-11-10.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class UserConstants {
    // MARK: Static variables
    
    static let userCKID: CKRecord.ID = {
        let container = CKContainer.default()
        var rtn: CKRecord.ID = CKRecord.ID()
        
        let group = DispatchGroup()
        group.enter()
        container.fetchUserRecordID { (Id, error) in
            if error != nil {
                fatalError("Could not fetch user record id!")
            }
            
            guard let id = Id else {
                fatalError("No CKRecordID found")
            }
            rtn = id
            group.leave()
        }
        group.wait()
        return rtn
    }()
    
    static let userCKName: String = {
        var user: String = ""
        let group = DispatchGroup()
        let container = CKContainer.default()
        print("container of \(String(describing: container.containerIdentifier))")
        group.enter()
        
        container.fetchUserRecordID { (Id, error) in
            if error != nil {
                fatalError("Fatal error: \(String(describing: error))")
            }
            
            guard let id = Id else {
                fatalError("No CKRecordID found")
            }
            user = id.recordName
            group.leave()
        }
        
        group.wait()
        return user
    }()
    
        
}
