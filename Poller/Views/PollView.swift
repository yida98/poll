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
    @State var index: Int = 0
    var body: some View {
        VStack {
            if viewModel.displayPolls.count > 0 {
                Text(viewModel.displayPolls[index].title) // Title
                    .foregroundColor(.blue)
                VStack {
                    ForEach(viewModel.displayPolls[index].pollItems.indices, id: \.self) { itemIndex in
                        Text(String(viewModel.displayPolls[index].pollItemRefs.count))
                            .foregroundColor(.blue)
                            .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height)
                            .cornerRadius(Constant.pollItemSize.height/2)
                            .shadow(radius: 4)
                    }
                }
            } else {
                Text("pop")
            }
        }
    }
    
}

struct PollView_Previews: PreviewProvider {
    static var previews: some View {
        PollView()
    }
}
