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
        ViewModel.queryPoll(with: NSPredicate.wildPollPredicate, limit: 3)
            // TODO: Handle these records
//            for record in records {
//                self.currPollArray.append(Poll(record: record))
//            }
//            let pollsNeeded = 3 - self.currPollArray.count
//            self.currPollArray.append(contentsOf: ViewModel.mockPolls[0..<pollsNeeded])
        
    }
    
    // MARK: CKRecord methods
    

    class DisplayPolls: ObservableObject {
            
        @Published var polls = [Poll]()
        
        private let floor = 3
        private let ceiling = 15
        
        init() {
            ViewModel.queryPoll(with: NSPredicate.wildPollPredicate, limit: 15)
        }
        
        /// Async calls this func to update polls array
        /// - Parameter poll: a poll to add
        func add(_ poll: Poll) {
            if !polls.compactMap({ $0.record.recordID }).contains(poll.record.recordID) && polls.count <= ceiling {
                polls.append(poll)
            }
        }
        
        func removeFirst() -> Poll {
            let first = polls.removeFirst()
            if polls.count <= floor {
                repopulate()
            }
            return first
        }
        
        private func repopulate() {
            ViewModel.queryPoll(with: NSPredicate.wildPollPredicate, limit: 15)
        }
        
    }
        
    var displayPolls = DisplayPolls()
    
    static var pollPublisher = PassthroughSubject<[Poll], Never>()
//        .receive(on: RunLoop.main)
    
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
    
    static func fetch(_ recordID: CKRecord.ID, completionHandler: @escaping (CKRecord) -> Void) {
        ViewModel.publicDB.fetch(withRecordID: recordID) { (record, error) in
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
    
    private static func queryPoll(with predicate: NSPredicate, limit: Int = 1) {
        let query = CKQuery(recordType: RecordType.poll.rawValue, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        if predicate == NSPredicate.ownPollPredicate {
            operation.resultsLimit = 3
        } else {
            operation.resultsLimit = limit // TODO: Might want to be 3
        }
        operation.recordFetchedBlock = { record in
//            pollPublisher.send(Poll(record: record))
            ViewModel.shared.displayPolls.add(Poll(record: record))
        
        }
        ViewModel.publicDB.add(operation)
    }
    
    func queryPollItems(for poll: CKRecord) {
        let recordToMatch = CKRecord.Reference(recordID: poll.recordID, action: .none)
        let predicate = NSPredicate(format: "%K == %@", PollItem.PollItemKeys.poll.rawValue, recordToMatch)
        
        ViewModel.queryPoll(with: predicate, limit: Int(Double.infinity))
    }
    
    private static func queryOwnPolls() -> AnyPublisher<[CKRecord], Error> {
        let future = Future<[CKRecord], Error> { promise in
            let query = CKQuery(recordType: RecordType.poll.rawValue, predicate: NSPredicate.ownPollPredicate)
            let operation = CKQueryOperation(query: query)
            var results = [CKRecord]()
            operation.resultsLimit = 3
            operation.queryCompletionBlock = { cursor, error in
                if let error = error {
                    promise(.failure(error))
                }
            }
            operation.recordFetchedBlock = { record in
                results.append(record)
            }
            operation.completionBlock = {
                promise(.success(results))
            }
        }
        return future.eraseToAnyPublisher()
    //            .map { $0.map { PollItem(record: $0) } }
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
    
    static var userCKID: CKRecord.ID = CKRecord.ID()
    
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
    
    
    // MARK: Menu Model
        
    @Published var cardDisplaying: Bool = true
    @Published var userDisplaying: Bool = false
    
    @Published var currMiddleImg: String = "AddPoll"
    
    func tapCard() {
        if currMiddleImg != "bigX" {
            cardDisplaying = true
            userDisplaying = false
        }
    }
    
    func tapUser() {
        if currMiddleImg != "bigX" {
            cardDisplaying = false
            userDisplaying = true
        }
    }
    
    func newPoll() {
        if cardDisplaying == false && userDisplaying == false {
            resetMiddelImg()
            tapCard()
        } else {
            currMiddleImg = "bigX"
            cardDisplaying = false
            userDisplaying = false
        }
    }
    
    private func resetMiddelImg() {
        currMiddleImg = "AddPoll"
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


