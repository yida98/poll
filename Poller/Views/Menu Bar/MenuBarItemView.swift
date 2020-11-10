//
//  MenuBarItemView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-05.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct MenuBarItemView: View {
    
    @ObservedObject var menuModel: MenuModel = MenuModel.shared

    var body: some View {
        HStack {
            VStack {
                Spacer()
                    .frame(width: Constant.menuBarItemSize.width, height: 4)
                    .background(RoundedGeoView(color: Color.white, tl: 0, tr: 0, bl: 4, br: 4))
                    .opacity(menuModel.cardDisplaying ? 1 : 0)
                Spacer()
                Image("pollStack")
            }.frame(width: Constant.menuBarItemSize.width, height: Constant.menuBarItemSize.height)
                .opacity(menuModel.cardDisplaying ? 1 : 0.3)
                .onTapGesture {
                    self.menuModel.tapCard()
            }
            
            Spacer()
            
            VStack {
                Spacer()
                    .frame(width: Constant.menuBarItemSize.width, height: 4)
                    .background(RoundedGeoView(color: Color.white, tl: 0, tr: 0, bl: 4, br: 4))
                    .opacity(menuModel.userDisplaying ? 1 : 0)
                Spacer()
                Image("yourPolls")
            }.frame(width: Constant.menuBarItemSize.width, height: Constant.menuBarItemSize.height)
                .opacity(menuModel.userDisplaying ? 1 : 0.3)
                    .onTapGesture {
                        self.menuModel.tapUser()
                }
        }.frame(width: Constant.screenSize.width - 200)
    }
}

struct MenuBarItemView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarItemView()
    }
}
