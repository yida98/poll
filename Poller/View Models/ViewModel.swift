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
    
    @Published var displayPolls: [Poll] = [Poll]() {
        didSet {
            debugPrint("Did set display polls with current count of \(displayPolls.count)")
            if oldValue.count != displayPolls.count && displayPolls.count < 3 {
                debugPrint("Retry refresh")
                update()
            } else {
                debugPrint("Done refresh with \(displayPolls.count) in the bag")
                if showSplash {
                    toggleShow()
                }
            }
        }
    }
    @Published var showSplash = true
        
    private var batchAsyncFetch: AnyPublisher<[Poll], Error> {
        return Future <[Poll], Error> { promise in
            /* This is for batch fetch which works for init and the user's own polls */
            RecordOperation.queryPoll(with: NSPredicate.ownPollPredicate, limit: 3) { records in
                
                var results = [Poll]()
                
                for record in records {
                    let _ = Future<Poll, Error> { promise in
                        let poll = Poll(record: record)
                        poll.getPollItems() { pollItemResults in
                            debugPrint("[iPromise] Was this ever called")
                            pollItemResults.count > 0 ? promise(.success(poll)) : promise(.failure(myError.noFetch))
                        }
                    }.sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(myError.noFetch):
                            debugPrint("[iPromise] Failed to complete sink...")
                        case .finished:
                            debugPrint("[iPromise] Finished individual sink...")
                            if results.count == records.count {
                                promise(.success(results))
                                debugPrint("[iPromise] Finished all sink...")
                            }
                        default: ()
                        }
                    }, receiveValue: {
                        debugPrint("[iPromise] Appending \($0.title)")
                        results.append($0)
                       })
                        .store(in: &self.cancellableSet)
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private var asyncFetch: AnyPublisher<[Poll], Error> {
        return Future <[Poll], Error> { promise in
            /* This is for individual fetch which works for updating */
            RecordOperation.queryPoll(with: NSPredicate.ownPollPredicate) { records in
            
                for record in records {
                    let _ = Future<Poll, Error> { promise in
                        let poll = Poll(record: record)
                        poll.getPollItems() { pollItemResults in
                            debugPrint("[iPromise] Was this ever called")
                            pollItemResults.count > 0 ? promise(.success(poll)) : promise(.failure(myError.noFetch))
                        }
                    }.sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(myError.noFetch):
                            debugPrint("[iPromise] Failed to complete sink...")
                        case .finished:
                            debugPrint("[iPromise] Finished all sink...")
                        default: ()
                        }
                    }, receiveValue: {
                        debugPrint("[iPromise] Appending \($0.title)")
                        promise(.success([$0]))
                       })
                        .store(in: &self.cancellableSet)
                }
            }
        }
        .eraseToAnyPublisher()
    }

    
    private var cancellableSet: Set<AnyCancellable> = []

    private init() {
        print("private init time")
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteRecordCompletion), name: .deleteRecordCompletion, object: nil)
        
        let allCases = RecordType.allCases
        let noCases = [RecordType]()
        deleteRecords(of: noCases)
        
    }
    
    @objc
    func deleteRecordCompletion() {
        DispatchQueue.main.async {
            if self.numTypesToDelete == 0 {
                self.upload()
            } else {
                self.completionCount += 1
                // Check size
                if self.completionCount >= self.numTypesToDelete {
                    // If size match: update()
                    self.update()
                    // Reset match and completionCount
                    self.completionCount = 0
                    self.numTypesToDelete = 0
                }
            }
        }
    }
    
    @Published var completionCount: Int = 0
    
    private var numTypesToDelete: Int = 0
    
    func deleteRecords(of types: [RecordType]) {
        if types.count == 0 {
            NotificationCenter.default.post(name: .deleteRecordCompletion, object: nil)
        } else {
            numTypesToDelete = types.count
            RecordOperation.deleteAllRecords(of: types)
        }
    }
    
    func upload() {
        debugPrint("Uploading...")
        batchAsyncFetch
            .receive(on: RunLoop.main)
            .catch({ (error) in Just([Poll]()) })
            .assign(to: \.displayPolls, on: self)
            .store(in: &cancellableSet)
    }
    
    func update() {
        debugPrint("Updating...")
        asyncFetch
            .receive(on: RunLoop.main)
            .catch({ error in Just([Poll]()) })
            .prepend(displayPolls.count > 0 ? displayPolls : [])
            .assign(to: \.displayPolls, on: self)
            .store(in: &cancellableSet)
    }
    
    func toggleShow() {
        self.showSplash = false
    }
    
    func removeOne() {
        if !displayPolls.isEmpty {
            displayPolls.removeFirst()
            // TODO: Display new one?
        }
    }
    
//    func setPolls() {
//        if displayPolls.count < 3 {
//            RecordOperation.queryPoll(with: NSPredicate.ownPollPredicate) {
//                if self.displayPolls.count > 0 {
//                    self.setPolls()
//                } else {
//                    // There are no records of this type to query
//                    debugPrint("Nothing was queried")
//                }
//            }
//        }
//    }
    // MARK: Model Methods
    
    func addPoll(_ poll: Poll) {
        displayPolls.append(poll)
    }
        
}
