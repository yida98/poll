//
//  ViewModel.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class ViewModel {
    
    static let shared = ViewModel()
    
    static var publicContainer = CKContainer.default().publicCloudDatabase
    
    // MARK: View Model
    
    var currPollArray: [Poll]?
    static var mockPolls: [Poll] = [Poll]() // This will effectively be overwritten at app launch
    
    /// Used to originally populate the currPollArray
    private func initFetchPollArray() {
        ViewModel.queryPoll(with: NSPredicate.wildPollPredicate(), limit: 3) { records in
            // TODO: Handle these records
            self.currPollArray = [Poll]()
            for record in records {
                self.currPollArray!.append(Poll(record: record))
            }
            let pollsNeeded = 3 - self.currPollArray!.count
            self.currPollArray!.append(contentsOf: ViewModel.mockPolls[0..<pollsNeeded])
        }
    }
    
    private static func fetchOwnPolls() {
        ViewModel.queryPoll(with: NSPredicate.ownPollPredicate()) { records in
            // TODO: Handle these records
        }
    }
    
    // MARK: CKRecord methods
    
    static func save(_ record: CKRecord) { // This is only for one record
        ViewModel.publicContainer.save(record) { (record, error) in
            if let error = error {
                // TODO: Error handling
                fatalError("\(error.localizedDescription)")
            } else {
                // TODO: What happens after a record is saved
                debugPrint("CKRecord of type \(record!.recordType.debugDescription) successfully saved")
            }
        }
    }
    
    static func fetch(_ recordID: CKRecord.ID) {
        ViewModel.publicContainer.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                // TODO: Error handling
                fatalError("\(error.localizedDescription)")
            } else {
                // TODO: What happens after a record is fetched
                debugPrint("CKRecord of ID \(record!.recordType.debugDescription) successfully fetched")
            }
        }
    }
    
    static func batchSave(save records: [CKRecord], delete delRecords: [CKRecord.ID]) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: delRecords)
        operation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.changedKeys
        
        operation.modifyRecordsCompletionBlock = { records, recordIDs, error in
            // TODO: Completion block
        }
        
        ViewModel.publicContainer.add(operation)
    }
    
    private static func queryPoll(with predicate: NSPredicate, limit: Int = 1, completionHandler: @escaping ([CKRecord]) -> Void) {
        let query = CKQuery(recordType: RecordType.poll.rawValue, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        if predicate == NSPredicate.ownPollPredicate() {
            operation.resultsLimit = 3
        } else {
            operation.resultsLimit = limit // TODO: Might want to be 3
        }
        var results = [CKRecord]()
        operation.recordFetchedBlock = { record in
            results.append(record)
        }
        operation.completionBlock = {
            // TODO: How to populate UI master poll Array?
            // TODO: Return how many records were fetched this time around?
            // results.count
            completionHandler(results)
        }
        ViewModel.publicContainer.add(operation)
    }
    
    // MARK: Static variables
    
    lazy var userCKName: String = {
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

extension NSPredicate {
    
    static var wildPollPredicate = {
        return NSPredicate(format: "%K != %@ AND %K NOT CONTAINS %@", Poll.PollKeys.creator.rawValue, ViewModel.shared.userCKName, Poll.PollKeys.seenBy.rawValue, ViewModel.shared.userCKName)
    }
    
    static var ownPollPredicate = {
        return NSPredicate(format: "%K == %@", User.UserKeys.accountName.rawValue, ViewModel.shared.userCKName)
    }
    
}
