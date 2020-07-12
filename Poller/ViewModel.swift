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
    static var privateDB = CKContainer.default().privateCloudDatabase
    
    private init() {
        print("private init time")
        
        ViewModel.decodeMockPolls()
        self.displayPolls = ViewModel.queryDisplayPolls()
    }
    
    // MARK: View Model
    
    static var mockPolls: [Poll] = [Poll]()
    var displayPolls: DisplayPolls

    class DisplayPolls: ObservableObject {
            
        @Published var polls = [Poll]()
        
        private static let floor = 3
        private static let ceiling = 15
        
        private var sessionRecordIDs: [CKRecord.ID] = [CKRecord.ID]()
        var record: CKRecord
        
        fileprivate init(record: CKRecord) {
            if let IDs = record[DisplayPollsKeys.recordIDs.rawValue] as? [CKRecord.ID] {
                self.sessionRecordIDs = IDs
            }
            // TODO: Make record IDs into Polls
            self.record = record
        }
        
        static func create() { // Should only ever be called once
            let record = CKRecord(recordType: RecordType.displayPolls.rawValue)
            ViewModel.batchSave(save: [record], delete: [], database: ViewModel.privateDB)
            ViewModel.queryPoll(with: NSPredicate.wildPollPredicate, limit: 15)
        }
        
        /// Async calls this func to update polls array
        /// - Parameter poll: a poll to add
        func add(_ poll: Poll) {
            if !polls.compactMap({ $0.record.recordID }).contains(poll.record.recordID) && polls.count <= DisplayPolls.ceiling {
                polls.append(poll)
                updateSessionRecords()
            }
        }
        
        func removeFirst() -> Poll {
            let first = polls.removeFirst()
            if polls.count <= DisplayPolls.floor {
                repopulate()
            }
            return first
        }
        
        private func repopulate() {
            ViewModel.queryPoll(with: NSPredicate.wildPollPredicate, limit: 15)
        }
        
        private func updateSessionRecords() {
            sessionRecordIDs = polls.compactMap { $0.record.recordID }
            record.setValue(sessionRecordIDs, forKey: DisplayPollsKeys.recordIDs.rawValue)
            ViewModel.batchSave(save: [record], delete: [], database: ViewModel.privateDB)
        }
        
        enum DisplayPollsKeys: String {
           case recordIDs
        }
        
    }
    
    static private func decodeMockPolls() {
        let url = Bundle.main.url(forResource: "MockPolls", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decodedJSON = try! JSONSerialization.jsonObject(with: data, options: [])

        var polls: [Poll] = [Poll]()

        if let listOfPolls = decodedJSON as? [Dictionary<String, Any>] {
            for pollDictionary in listOfPolls {
                var title = ""
                var creator: CKRecord?
                var pollItems = Array<String>()
                for key in pollDictionary.keys {
                    switch(key){
                    case "title":
                        title = pollDictionary[key] as! String
                    case "creator":
                        guard let name = pollDictionary[key] as? String else {
                            fatalError("Poll Items not iterable")
                        }
                        creator = User.create(with: name)
                    case "pollItems":
                        guard let items = pollDictionary[key] as? Array<String> else {
                            fatalError("Poll Items not iterable")
                        }
                        pollItems = items
                    default:
                        break
                    }
                }
                let pollRecord = Poll.create(title: title, creator: creator!)
                var pollItemRecord = [CKRecord]()
                for item in pollItems {
                    pollItemRecord.append(PollItem.create(title: item, parent: pollRecord))
                    debugPrint("second")
                }
                let poll = Poll(record: pollRecord)
                poll.addPollItems(itemRecords: pollItemRecord)
                polls.append(poll)
            }
            ViewModel.mockPolls = polls
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
    
    static func fetch(_ recordIDs: [CKRecord.ID]) {
        for id in recordIDs {
            ViewModel.fetch(id) { (record) in
                <#code#>
            }
        }
    }
    
    static func batchSave(save records: [CKRecord], delete delRecords: [CKRecord.ID], database: CKDatabase = ViewModel.publicDB) {
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
    
    // MARK: Queries
    
    private static func queryPoll(with predicate: NSPredicate, limit: Int = 1) {
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
        ViewModel.publicDB.add(operation)
    }
    
    static func queryPollItems(for poll: CKRecord) {
        let recordToMatch = CKRecord.Reference(recordID: poll.recordID, action: .none)
        let predicate = NSPredicate(format: "%K == %@", PollItem.PollItemKeys.poll.rawValue, recordToMatch)
        
        ViewModel.queryPoll(with: predicate, limit: Int(Double.infinity))
    }
    
    private static func queryDisplayPolls() -> DisplayPolls {
        let query = CKQuery(recordType: RecordType.displayPolls.rawValue, predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        
        var result: CKRecord?
        
        let group = DispatchGroup()
        group.enter()
        operation.recordFetchedBlock = { record in
            result = record
            group.leave()
        }
        operation.queryCompletionBlock = { cursor, error in
            if result == nil {
                DisplayPolls.create()
            }
        }
        ViewModel.privateDB.add(operation)
        
        group.wait()
        
        if result == nil {
            return queryDisplayPolls() // TODO: Infinite loop...
        } else {
            return DisplayPolls(record: result!)
        }
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


