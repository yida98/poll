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
    
//    var polls: AnyPublisher<Poll, Never> {
//        RecordOperation.queryPoll(with: NSPredicate.ownPollPredicate) {}
////            .map { }
//            .eraseToAnyPublisher()
//    }
    
//    private var allPolls: AnyPublisher<[Poll], Never> {
//        // something happens
//        $displayPolls
//            .filter({ $0.count < 3 })
//
//            .eraseToAnyPublisher()
//    }
    
    private var asyncFetch: AnyPublisher<[Poll], Never> {
        return Future<Poll, Never> { promise in
            debugPrint("I'm inside a promise")
            RecordOperation.queryPoll(with: NSPredicate.ownPollPredicate) { record in
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
        // Increment
        debugPrint("Incrementing")
        DispatchQueue.main.async {
            self.completionCount += 1
            debugPrint("Completion count: \(self.completionCount) match count: \(self.match)")
            // Check size
            if self.match > 0 {
                debugPrint("matching")
                if self.completionCount >= self.match {
                    debugPrint("refresh soon")
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
        match = types.count
        RecordOperation.deleteAllRecords(of: types)
    }
    
    func refresh() {
        print("refreshing...")
        let originalCount = displayPolls.count
        if displayPolls.count < 3 {
            asyncFetch
                .receive(on: RunLoop.main)
                .prepend(displayPolls)
                .assign(to: \.displayPolls, on: self)
                .store(in: &cancellableSet)
            if displayPolls.count < 3 && originalCount != displayPolls.count {
                
                refresh()
            }
        }
    }
    
    func toggleShow() {
        self.showSplash.toggle()
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
