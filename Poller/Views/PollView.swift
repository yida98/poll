//
//  PollView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-05.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct PollView: View {
    
    @ObservedObject var viewModel: ViewModel = ViewModel.shared
    @ObservedObject var poll: Poll
    var body: some View {
        
        VStack {
            Text(poll.title) // Title
                .foregroundColor(Color.orange)
                .frame(width: 294, height: 130, alignment: .bottom)
                .font(.custom("Avenir-Heavy", size: 28))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.4)
            ScrollView (.vertical, showsIndicators: false) {
                ForEach(poll.pollItems.indices, id: \.self) { itemIndex in
                    PollItemView(pollItem: poll.pollItems[itemIndex])
//                    Text(String(itemIndex))
//                        .padding(.horizontal, 20)
//                        .multilineTextAlignment(.center)
//                        .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height)
//                        .foregroundColor(Color.gray)
//                        .background(
//                            RoundedRectangle(cornerRadius: Constant.pollItemSize.height/2)
//                                .fill(Color.white)
//                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
//                    )
                }.padding()
            }
        }
    }
    
}
