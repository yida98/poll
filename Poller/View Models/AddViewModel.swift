//
//  AddViewModel.swift
//  Poller
//
//  Created by Yida Zhang on 2020-11-09.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import CloudKit
import Combine

class AddViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var pollItems: [PollItemWithIndex] = [PollItemWithIndex]()
    
    @Published var showing: Bool = false
    @Published var editMode: Bool = false
    @Published var deployable: Bool = false
    
    init() {
        isFormValid
            .receive(on: RunLoop.main)
            .assign(to: \.deployable, on: self)
            .store(in: &cancellableSet)
    }
    
    func addNewItem() {
        pollItems.append(PollItemWithIndex())
    }
    
    func removeItem(at index: Int) {
        pollItems.remove(at: index)
        if pollItems.count == 0 {
            addNewItem()
        }
    }
    
    func toggleShow() {
        showing.toggle()
        if pollItems.isEmpty {
            addNewItem()
        }
    }
    
    func toggleEdit() {
        editMode.toggle()
    }
    
    func getIndexOf(_ item: PollItemWithIndex) -> Int {
        return pollItems.firstIndex( where: {$0.id == item.id} )!
    }
    
    func submit() {
        let titleArray = pollItems.map {$0.itemName}
        AddViewModel.onSumbit(title: title, items: titleArray)
    }
    
    private static func onSumbit(title: String, items: [String]) {
        RecordOperation.fetch(UserConstants.userCKID) { (userRecord) in
//            var pollItems = [CKRecord]()
//            for item in items {
//                let pollItem = PollItem.create(title: item)
//                pollItems.append(pollItem)
//            }
//            let _ = Poll.create(title: title, creator: userRecord, pollRecords: pollItems)
            // Dismiss view
            DispatchQueue.main.async {
                MenuModel.shared.tapNewPoll()
            }
        }
    }
    
    
    // MARK: Publishers
    private var isTitleValidPublisher: AnyPublisher<Bool, Never> {
        $title
            .map {input in
                input.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    private var itemsValidPublisher: AnyPublisher<Bool, Never> {
        $pollItems
            .map {$0.allSatisfy {!$0.itemName.isEmpty} }
            .eraseToAnyPublisher()
    }
    
    private var isFormValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isTitleValidPublisher, itemsValidPublisher)
            .map {a, b in
                return a && b
            }
            .eraseToAnyPublisher()
    }
    
    private var cancellableSet: Set<AnyCancellable> = []
    
}

struct PollItemWithIndex: Identifiable {
    var id: UUID = UUID()
    var itemName: String = ""
}
