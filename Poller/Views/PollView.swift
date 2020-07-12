//
//  PollView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-05.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct PollView: View {
    
//    @ObservedObject var poll: Poll = ViewModel.mockPolls.first!
    
    var body: some View {
        VStack {
            Text("Poooooop")
//            Text(poll.title) // Title
//            VStack {
//                ForEach(poll.pollItems, id: \.self.insertionIndex) {pollItem in
//                    Text(pollItem.itemTitle)
//                        .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height)
//                        .cornerRadius(Constant.pollItemSize.height/2)
//                        .shadow(radius: 4)
//                }
//            }
        }
    }
    
}

struct PollView_Previews: PreviewProvider {
    static var previews: some View {
        PollView()
    }
}
