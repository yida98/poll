//
//  MenuBarView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-05.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct MenuBarView: View {
    
    @ObservedObject var menuModel: MenuModel = MenuModel.shared

    var body: some View {
        
        VStack {
            ZStack {
                MenuBarItemView()
                Circle()
                    .frame(width: 68
                        , height: 68)
                    .foregroundColor(Color.darkOrange)
                    .shadow(radius: 6)
                Image(menuModel.currMiddleImg)
            }.onTapGesture {
                self.menuModel.tapNewPoll()
            }
            .offset(y: -9)
            Spacer()
        }
            .frame(width: Constant.screenSize.width, height: Constant.menuBarHeight)
            .background(RoundedGeoView(color: Color.paleNavy,
                                    tl: 100, tr: 100, bl: 0, br: 0))
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}

struct menuBar: View {
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(Color.red)
    }
    
}
