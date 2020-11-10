//
//  ViewModel.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit
import Combine

class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    var displayPolls = [Poll]()
    
    private init() {
        print("private init time")

    }
    
    func setPolls() {
        if displayPolls.count < 3 {
            RecordOperation.queryPoll(with: NSPredicate.wildPollPredicate) {
                if self.displayPolls.count > 0 {
                    self.setPolls()
                } else {
                    // There are no records of this type to query
                    debugPrint("Nothing was queried")
                }
            }
        }
    }
    // MARK: Model Methods
    
    func addPoll(_ poll: Poll) {
        displayPolls.append(poll)
    }
        
    // MARK: Static variables
    
    static var userCKID: CKRecord.ID = CKRecord.ID()
    
    var userCKName: String {
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
    }
    
        
}


