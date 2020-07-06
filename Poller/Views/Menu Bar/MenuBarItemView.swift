//
//  MenuBarItemView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-05.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct MenuBarItemView: View {
    
    @ObservedObject var viewModel: ViewModel = ViewModel.shared

    var body: some View {
        HStack {
            VStack {
                Spacer()
                    .frame(width: Constant.menuBarItemSize.width, height: 4)
                    .background(RoundedGeoView(color: Color.white, tl: 0, tr: 0, bl: 4, br: 4))
                    .opacity(viewModel.cardDisplaying ? 1 : 0)
                Spacer()
                Image("PollStack")
            }.frame(width: Constant.menuBarItemSize.width, height: Constant.menuBarItemSize.height)
                .opacity(viewModel.cardDisplaying ? 1 : 0.3)
                .onTapGesture {
                    self.viewModel.tapCard()
            }
            
            Spacer()
            
            VStack {
                Spacer()
                    .frame(width: Constant.menuBarItemSize.width, height: 4)
                    .background(RoundedGeoView(color: Color.white, tl: 0, tr: 0, bl: 4, br: 4))
                    .opacity(viewModel.userDisplaying ? 1 : 0)
                Spacer()
                Image("YourPolls")
            }.frame(width: Constant.menuBarItemSize.width, height: Constant.menuBarItemSize.height)
                .opacity(viewModel.userDisplaying ? 1 : 0.3)
                    .onTapGesture {
                        self.viewModel.tapUser()
                }
        }.frame(width: Constant.screenSize.width - 200)
    }
}

struct MenuBarItemView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarItemView()
    }
}
