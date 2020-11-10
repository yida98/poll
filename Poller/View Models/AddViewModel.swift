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
    @Published var pollItems: [String] = [""]
    
    @Published var showing: Bool = false
    
    func addNewItem() {
        pollItems.append("")
    }
    
    func toggleShow() {
        debugPrint("toggling", !showing)
        showing.toggle()
    }
    
}
