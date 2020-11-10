//
//  AddViewModel.swift
//  Poller
//
//  Created by Yida Zhang on 2020-11-09.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation

class AddViewModel: ObservableObject {
    
    static let shared = AddViewModel()
    
    @Published var title: String = ""
    @Published var pollItems: [PollItemWithIndex] = [PollItemWithIndex()]
    
    @Published var showing: Bool = false
    
    func addNewItem() {
        pollItems.append(PollItemWithIndex())
    }
    
    func removeItem(at index: Int) {
        debugPrint(pollItems[index])
        pollItems.remove(at: index)
    }
    
    func toggleShow() {
        debugPrint("toggling", !showing)
        showing.toggle()
    }
    
    func getIndexOf(_ item: PollItemWithIndex) -> Int {
        return pollItems.firstIndex( where: {$0.id == item.id} )!
    }
}

struct PollItemWithIndex: Identifiable {
    var id: UUID = UUID()
    var str: String = ""
}
