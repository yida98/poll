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
                // TODO: NOT BLOCKING?!
                promise(.success(Poll(record: record)))
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
//        refresh()
    }
    
    @objc
    func deleteRecordCompletion() {
        DispatchQueue.main.async {
            if self.match == 0 {
                self.refresh()
            } else {
                self.completionCount += 1
                // Check size
                if self.completionCount >= self.match {
                    // If size match: refresh()
                    self.refresh()
                    // Reset match and completionCount
                    self.completionCount = 0
                    self.match = 0
                }
            }
        }
    }
    
    @Published var completionCount: Int = 0
    
    private var match: Int = 0
    
    func deleteRecords(of types: [RecordType]) {
        if types.count == 0 {
            NotificationCenter.default.post(name: .deleteRecordCompletion, object: nil)
        } else {
            match = types.count
            RecordOperation.deleteAllRecords(of: types)
        }
    }
    
    func refresh() {
        debugPrint("refreshing...")
        let originalCount = displayPolls.count
        if displayPolls.count < 3 {
            asyncFetch
                .receive(on: RunLoop.main)
                .prepend(displayPolls)
                .handleEvents(receiveOutput: { (publisher) in
                    // Each fetch
                    debugPrint("receive output")
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
