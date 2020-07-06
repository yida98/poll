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
    
    static var publicDB = CKContainer.default().publicCloudDatabase
    
    private init() {
        print("private init time")
        
//        initFetchPollArray()
        print(ViewModel.mockPolls)
    }
    
    // MARK: View Model
    
    var currPollArray: [Poll] = [Poll]()
    static var mockPolls: [Poll] = [Poll]() // This will effectively be overwritten at app launch
    
    /// Used to originally populate the currPollArray
    private func initFetchPollArray() {
        ViewModel.queryPoll(with: NSPredicate.wildPollPredicate(), limit: 3) { records in
            // TODO: Handle these records
            for record in records {
                self.currPollArray.append(Poll(record: record))
            }
            let pollsNeeded = 3 - self.currPollArray.count
            self.currPollArray.append(contentsOf: ViewModel.mockPolls[0..<pollsNeeded])
        }
    }
    
    private static func fetchOwnPolls() {
        ViewModel.queryPoll(with: NSPredicate.ownPollPredicate()) { records in
            // TODO: Handle these records
        }
    }
    
    // MARK: CKRecord methods
    
    /// Saves one record into the public container
    /// - Parameter record: One CKRecord to save
    static func save(_ record: CKRecord) {
        let group = DispatchGroup()
        group.enter()
        ViewModel.publicDB.save(record) { (savedRecord, error) in
            if let error = error {
                // TODO: Error handling
                fatalError("Encountered \(error) while singularly saving \(record)")
            } else {
                // TODO: What happens after a record is saved
                debugPrint("CKRecord of type \(savedRecord!.recordType.debugDescription) successfully saved")
                debugPrint("always first")
                group.leave()
            }
        }
        group.wait()
    }
    
    static func fetch(_ recordID: CKRecord.ID) {
        ViewModel.publicDB.fetch(withRecordID: recordID) { (record, error) in
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
        operation.isAtomic = false
        
        debugPrint("Attempting batch save")
        
        operation.perRecordCompletionBlock = { record, error in
            debugPrint("Attempting to save \(record)")
            if let _ = error {
                fatalError("Encountered \(error!) trying to save \(record)")
            }
        }
        
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedIDs, error in
            debugPrint("Records saved: \(String(describing: savedRecords)) \n Records deleted: \(String(describing: deletedIDs))")
        }
        
        ViewModel.publicDB.add(operation)
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
        ViewModel.publicDB.add(operation)
    }
    
    
    static func deleteAllRecords(of type: RecordType) {
        switch type {
        case .all:
            ViewModel.deleteAllRecords(of: RecordType.user)
            ViewModel.deleteAllRecords(of: RecordType.poll)
            ViewModel.deleteAllRecords(of: RecordType.pollItem)
        default:
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: type.rawValue, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            
            var results = [CKRecord.ID]()
            operation.recordFetchedBlock = { record in
                results.append(record.recordID)
            }
            operation.completionBlock = {
                debugPrint("delete time")
                ViewModel.batchSave(save: [], delete: results)
            }
            
            ViewModel.publicDB.add(operation)
        }
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
