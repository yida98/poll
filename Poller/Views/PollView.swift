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
                .foregroundColor(.orange)
            VStack {
                ForEach(poll.pollItems.indices, id: \.self) { itemIndex in
                    Text(String(itemIndex))
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height)
                        .foregroundColor(Color.gray)
                        shadow(radius: 4)
                        .overlay(RoundedRectangle(cornerRadius: Constant.pollItemSize.height/2)
                            .stroke()
                            .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height)
                        )
                }
            }
        }
    }
    
}
