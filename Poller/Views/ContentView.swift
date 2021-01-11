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
                if viewModel.displayPolls.count > 0 { (ZStack {
                    ForEach(viewModel.displayPolls.indices, id: \.self) { index in
//                        Text(viewModel.displayPolls[0].title)
                        PollWrapperView(cardIndex: Double(index), total: Double(viewModel.displayPolls.count), poll: self.viewModel.displayPolls[index])
                        
                    }
                }) } else {
                    Text("hi")
                }
                MenuBarView()
            }.background(Color.navy)
            .edgesIgnoringSafeArea(.all)

            SplashScreenView()
                .opacity(viewModel.showSplash ? 1 : 0)
                .animation(.easeOut(duration: 0.3))
            
            AddPollView()

        }.edgesIgnoringSafeArea(.all)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
