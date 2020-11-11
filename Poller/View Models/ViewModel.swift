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
        refresh()
    }
    
    func refresh() {
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


