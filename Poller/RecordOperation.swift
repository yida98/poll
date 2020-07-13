//
//  RecordOperation.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-12.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class RecordOperation {
    
    static var publicDB = CKContainer.default().publicCloudDatabase
    static var privateDB = CKContainer.default().privateCloudDatabase
    
    static func save(_ record: CKRecord) {
        let group = DispatchGroup()
        group.enter()
        RecordOperation.publicDB.save(record) { (savedRecord, error) in
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
    
    static func fetch(_ recordID: CKRecord.ID, completionHandler: @escaping (CKRecord) -> Void) {
        RecordOperation.publicDB.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                // TODO: Error handling
                fatalError("\(error.localizedDescription)")
            } else {
                // TODO: What happens after a record is fetched
                debugPrint("CKRecord of ID \(record!.recordType.debugDescription) successfully fetched")
                completionHandler(record!)
            }
        }
    }
    
    static func fetchForDisplay(_ recordIDs: [CKRecord.ID]) {
        for id in recordIDs {
            RecordOperation.fetch(id) { (record) in
                ViewModel.shared.displayPolls.asyncInsert(Poll(record: record))
            }
        }
    }
    
    static func batchSave(save records: [CKRecord], delete delRecords: [CKRecord.ID], database: CKDatabase = RecordOperation.publicDB) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: delRecords)
        operation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.changedKeys
        operation.isAtomic = false
                
        operation.perRecordCompletionBlock = { record, error in
            debugPrint("Attempting to save \(record)")
            if let _ = error {
                fatalError("Encountered \(error!) trying to save \(record)")
            }
        }
        
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedIDs, error in
            debugPrint("Records saved: \(String(describing: savedRecords)) \n Records deleted: \(String(describing: deletedIDs))")
        }
        
        database.add(operation)
    }
        
    static func deleteAllRecords(of type: RecordType) {
        switch type {
        case .all:
            RecordOperation.deleteAllRecords(of: RecordType.user)
            RecordOperation.deleteAllRecords(of: RecordType.poll)
            RecordOperation.deleteAllRecords(of: RecordType.pollItem)
            RecordOperation.deleteAllRecords(of: RecordType.displayPolls)
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
                RecordOperation.batchSave(save: [], delete: results)
            }
            
            RecordOperation.publicDB.add(operation)
        }
    }

    // MARK: Query
    
    static func queryPoll(with predicate: NSPredicate, limit: Int = 1) {
        let query = CKQuery(recordType: RecordType.poll.rawValue, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        if predicate == NSPredicate.ownPollPredicate {
            operation.resultsLimit = 3
        } else {
            operation.resultsLimit = limit // TODO: Might want to be 3
        }
        operation.recordFetchedBlock = { record in
            ViewModel.shared.displayPolls.add(Poll(record: record))
        
        }
        RecordOperation.publicDB.add(operation)
    }
    
    static func queryPollItems(for poll: CKRecord) {
        let recordToMatch = CKRecord.Reference(recordID: poll.recordID, action: .none)
        let predicate = NSPredicate(format: "%K == %@", PollItem.PollItemKeys.poll.rawValue, recordToMatch)
        
        RecordOperation.queryPoll(with: predicate, limit: Int(Double.infinity))
    }
    
    static func queryDisplayPolls() -> DisplayPollsModel {
        let query = CKQuery(recordType: RecordType.displayPolls.rawValue, predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        
        var result: CKRecord?
        
        let group = DispatchGroup()
        group.enter()
        operation.recordFetchedBlock = { record in
            result = record
        }
        operation.queryCompletionBlock = { cursor, error in
            if result == nil {
                DisplayPollsModel.create()
            }
            group.leave()
        }
        RecordOperation.privateDB.add(operation)
        
        group.wait()
        
        if result == nil {
            return queryDisplayPolls() // TODO: Infinite loop...
        } else {
            return DisplayPollsModel(record: result!)
        }
    }
    
}

extension NSPredicate {
    
    static var wildPollPredicate: NSPredicate {
        let recordToMatch = CKRecord.Reference(recordID: ViewModel.userCKID, action: .none)
        return NSPredicate(format: "%K != %@ AND %K NOT CONTAINS %@", Poll.PollKeys.creator.rawValue, ViewModel.shared.userCKName, Poll.PollKeys.seenBy.rawValue, recordToMatch) // seenBy?
    }
    
    static var ownPollPredicate: NSPredicate {
        let recordToMatch = CKRecord.Reference(recordID: ViewModel.userCKID, action: .none)
        return NSPredicate(format: "%K == %@", Poll.PollKeys.creator.rawValue, recordToMatch)
    }
    
}
