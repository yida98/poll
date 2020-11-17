//
//  ContentView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-06-23.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: ViewModel = ViewModel.shared

    var body: some View {
        ZStack {
            VStack{
                Spacer()
                if viewModel.displayPolls.count >= 1 { (ZStack {
                    ForEach(viewModel.displayPolls.indices, id: \.self) { int in 
//                        Text(viewModel.displayPolls[0].title)
                        PollWrapperView(cardIndex: 0)//, poll: self.viewModel.displayPolls[int])
                    }
                }) } else {
                    Text("hi")
                }
                MenuBarView()
            }.background(Color.navy)
            .edgesIgnoringSafeArea(.all)
            
            AddPollView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
