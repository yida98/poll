//
//  DisplayPollsModel.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-12.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit

class DisplayPollsModel: ObservableObject {
                    
    @Published var polls = [Poll]()
    
    private var sessionRecordIDs: [CKRecord.ID] = [CKRecord.ID]()
    var record: CKRecord
    
    // MARK: Constants
    
    private static let floor = 3
    private static let ceiling = 15
    
    init(record: CKRecord) {
        if let IDs = record[DisplayPollsKeys.recordIDs.rawValue] as? [CKRecord.ID] {
            self.sessionRecordIDs = IDs
        }
        RecordOperation.fetchForDisplay(sessionRecordIDs)
        self.record = record
    }
    
    static func create() { // Should only ever be called once
        let record = CKRecord(recordType: RecordType.displayPolls.rawValue)
        RecordOperation.batchSave(save: [record], delete: [], database: RecordOperation.privateDB)
        RecordOperation.queryPoll(with: NSPredicate.wildPollPredicate, limit: 15)
    }
    
    /// Async calls this func to update polls array
    /// - Parameter poll: a poll to add
    func add(_ poll: Poll) {
        if !polls.compactMap({ $0.record.recordID }).contains(poll.record.recordID) && polls.count <= DisplayPollsModel.ceiling {
            polls.append(poll)
            updateSessionRecords()
        }
    }
    
    func asyncInsert(_ poll: Poll) {
        polls.append(poll)
    }
    
    func removeFirst() -> Poll {
        let first = polls.removeFirst()
        if polls.count <= DisplayPollsModel.floor {
            DisplayPollsModel.repopulate()
        }
        return first
    }
    
    static private func repopulate() {
        RecordOperation.queryPoll(with: NSPredicate.wildPollPredicate, limit: 15)
    }
    
    private func updateSessionRecords() {
        sessionRecordIDs = polls.compactMap { $0.record.recordID }
        record.setValue(sessionRecordIDs, forKey: DisplayPollsKeys.recordIDs.rawValue)
        RecordOperation.batchSave(save: [record], delete: [], database: RecordOperation.privateDB)
    }
    
    enum DisplayPollsKeys: String {
       case recordIDs
    }
    
    static func decodeMockPolls() {
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

}
