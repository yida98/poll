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
    
    @Published var displayPolls = [Poll]()
    @Published var showSplash = true
    
    private var asyncFetch: AnyPublisher<[Poll], Never> {
        return Future<Poll, Never> { promise in
            // TODO: NOT OWN POLL IN THE FUTURE
            RecordOperation.queryPoll(with: NSPredicate.ownPollPredicate) { record in
                // TODO: Async query pollItems, too
                debugPrint("promise")
                let poll = Poll(record: record)
                poll.getPollItems() { results in
                    promise(.success(poll))
                }
            }
        }
        .map { [$0] }
        .eraseToAnyPublisher()
    }
    
    private var cancellableSet: Set<AnyCancellable> = []

    private init() {
        print("private init time")
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteRecordCompletion), name: .deleteRecordCompletion, object: nil)
        deleteRecords(of: RecordType.allCases)
        
//        let timer = Timer.publish(every: 1, on: RunLoop.main, in: .default)
//            .autoconnect()
        
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
        let originalCount = displayPolls.count
        if displayPolls.count < 3 {
            asyncFetch
                .receive(on: RunLoop.main)
                .handleEvents(receiveOutput: { (polls) in
                    debugPrint("received output \(polls)")
                }, receiveCompletion: { (subsComp) in
                    debugPrint("subs completion \(subsComp)")
                }, receiveRequest: { (demand) in
                    debugPrint("Demanda \(demand)")
                })
                .assign(to: \.displayPolls, on: self)
                .store(in: &cancellableSet)
            if displayPolls.count < 3 && originalCount != displayPolls.count {
                
                refresh()
            } else {
                // TODO: Done all refresh
                debugPrint("Done!")
                toggleShow()
            }
        }
    }
    
    func toggleShow() {
        self.showSplash = false
    }
    
    func removeOne() {
        if !displayPolls.isEmpty {
            displayPolls.remove(at: 0)
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
