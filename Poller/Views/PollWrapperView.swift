//
//  PollWrapperView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-06.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import CloudKit
import SwiftUI

struct PollWrapperView: View {
//    @ObservedObject var viewModel: ViewModel = ViewModel.shared

    @State var cardIndex: Int
    @State var offset: CGFloat = 0 // TODO: reset to 0 when view comes back
    
    @ObservedObject var poll: Poll

    var body: some View {
        VStack {
            PollView(poll: poll)
            
//            VStack {
//                ZStack(alignment: .bottom) {
//                    Spacer()
//                        .frame(width: 294, height: 8)
//                        .background(RoundedTitleGeoView())
//
//                    if (viewModel.currPoll != nil) {
//                        Text(viewModel.currPoll.title)
//
//                    } else {
//                        Text("title")
//                            .frame(width: 294, height: 130, alignment: .bottom)
//                            .font(.custom("Avenir-Heavy", size: 28))
//                            .multilineTextAlignment(.center)
//                            .minimumScaleFactor(0.4)
//                    }
//                }
//
//                Spacer()
//                    .frame(height: 20)
//
//                if (viewModel.currPoll != nil) {
//                    PollView(poll: viewModel.currPoll)
//                } else {
//                    // TODO: Items should be centred at the middle
//                    ScrollView (.vertical, showsIndicators: false) {
//                        ForEach(0..<7) { integer in
//                            Spacer()
//                                .frame(width: 1, height: 20)
//                            EmptyPollView(fingerObserver: FingerObserver())
//                        }
//                    }
//                    .frame(width: Constant.pollSize.width)
//                .gesture(DragGesture()
//                    .onChanged({ (value) in
//                        if (value.location.x - value.startLocation.x) < -40 {
//                            self.offset = (value.location.x - value.startLocation.x) + 40
//                        }
//                    })
//                    .onEnded({ (value) in
//                        if (value.location.x - value.startLocation.x) < -130 {
//
//                            withAnimation {
//                                self.offset = -900
//                            }
//
//                        } else {
//                            withAnimation(.interactiveSpring()) {
//                                self.offset = 0
//                            }
//                        }
//
//                    })
//                    )
//                }
//                Spacer()
//            }.padding(.vertical, 40)
        }
            .frame(width: Constant.pollSize.width, height: Constant.pollSize.height)
            .background(RoundedGeoView(color: Color.white, tl: 60, tr: 60, bl: 60, br: 0))
            .opacity(self.cardIndex == 0 ? 1 : 0.6)
            .scaleEffect(self.cardIndex == 0 ? 1 : 0.9, anchor: .bottom)
            .modifier(CardSwipeEffect(offset: offset))
            .padding()
    }
}

