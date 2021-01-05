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
            if oldValue.count != displayPolls.count && displayPolls.count < 3 {
                debugPrint("Retry refresh")
                refresh()
            } else {
                debugPrint("Done refresh with \(displayPolls.count) in the bag")
                if showSplash {
                    toggleShow()
                }
            }
        }
    }
    @Published var showSplash = true
        
    private var asyncFetch: AnyPublisher<[Poll], Error> {
        return Future<[Poll], Error> { promise in
            // TODO: NOT OWN POLL IN THE FUTURE
            RecordOperation.queryPoll(with: NSPredicate.ownPollPredicate) { records in
                
                // WARNING: Query limit is 1
                if records.count > 0 {
                    for record in records {
                        let poll = Future<Poll, Error> { promise in
                            let promisedPoll = Poll(record: record)
                            promisedPoll.getPollItems() { results in
                                promise(.success(promisedPoll))
                            }
                        }.eraseToAnyPublisher()
                        
                        poll.sink(
                            receiveCompletion: { _ in },
                            receiveValue: {finishedPolls.append($0)}
                        )
                    }
                    promise(.success(finishedPolls))
                } else {
                    promise(.failure(myError.noFetch))
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
                self.refresh()
            } else {
                self.completionCount += 1
                // Check size
                if self.completionCount >= self.numTypesToDelete {
                    // If size match: refresh()
                    self.refresh()
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
    
    func refresh() {
        // TODO: if not full, refresh automatically 
        debugPrint("refreshing...")
        if displayPolls.count < 3 {
            asyncFetch
                .receive(on: RunLoop.main)
                .handleEvents(receiveOutput: { (polls) in
                    if polls.isEmpty {
                        debugPrint("Received nothing as output")
                    } else {
                        debugPrint("received output: \(polls.first!.pollItems.first!.title)")
                    }
                }, receiveCompletion: { [self]  (subsComp) in
                    debugPrint("subs completion status: \(subsComp)")
                }, receiveCancel: {
                    debugPrint("Cancelled")
                }, receiveRequest: { (demand) in
                    debugPrint("Demanda: \(demand)")
                })
                .catch({ (error) in
                    Just([Poll]())
                })
                .prepend(displayPolls.count > 0 ? displayPolls : [])
                .assign(to: \.displayPolls, on: self)
                .store(in: &cancellableSet)


        }
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
