//
//  PollItemView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-12-24.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct PollItemView: View {
    
    @State var pressing: Bool = false
    @State var location: CGPoint = CGPoint(x: Constant.pollItemInsetSize.height, y: 0)
    
    @ObservedObject var pollItem: PollItem
    
    var body: some View {
        let slideGesture =
            LongPressGesture(minimumDuration: 0.1, maximumDistance: 0).exclusively(before:
                DragGesture(minimumDistance: 0)//, coordinateSpace: .named("slide"))
                .onChanged({ (value) in
                    self.pressing = true
                    if value.location.x < Constant.pollItemInsetSize.width {
                        self.location = value.location
                    }
                    debugPrint("changing")
                })
                .onEnded({ (value) in
                    if value.location.x < Constant.pollItemInsetSize.width * (5/6) {
                        self.pressing = false
                        self.location = CGPoint(x: Constant.pollItemInsetSize.height, y: value.location.y)
                    } else {
                        let endPoint = CGPoint(x: Constant.pollItemInsetSize.width, y: value.location.y)
                        self.pressing = false
                        self.location = endPoint
                    }
                    debugPrint("ended gesture")
                })
            )
        
        return HStack {
            VStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(minWidth: location.x, minHeight: Constant.pollItemInsetSize.height, maxHeight: Constant.pollItemInsetSize.height)
                            .background(pressing ? Color.darkOrange : Color.mediumGrey)
                            .cornerRadius((Constant.pollItemInsetSize.height)/2)
//                            .opacity(pressing ? 1 : 0)
                            .animation(.easeIn)
//                            .coordinateSpace(name: "slide")
                            .gesture(slideGesture)
                        
                    }.padding(.leading, Constant.pollItemInset)

                    Group {
                        Text(pollItem.title)
                            .frame(maxWidth: Constant.pollItemSize.width - 30, alignment: .center)
                            .lineLimit(nil)
                            .foregroundColor(Color.navy)
                            .padding(.vertical, 7)
                            .layoutPriority(1) // Ensures that the frame matching the text is priority for every view involved
                    }
                    .frame(minWidth:Constant.pollItemSize.width, minHeight: Constant.pollItemSize.height)
                }
            }
            .frame(minWidth: Constant.pollItemSize.width, minHeight: Constant.pollItemSize.height)
            .background(pressing ? Color.lightOrange : Color.lightGrey)
            .cornerRadius(Constant.pollItemSize.height/2)
                
                    // TODO: Vote
                    
        }
    }
}
