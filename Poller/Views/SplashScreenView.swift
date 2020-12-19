//
//  SplashScreenView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-12.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct SplashScreenView: View {
    
    @ObservedObject var model = SplashModel.shared
    
    var body: some View {
        VStack {
            Spacer()
            HStack{
                Spacer()
                Text("Yello world")
                Spacer()
            }
            Spacer()
        }.edgesIgnoringSafeArea(.all)
        .background(Color.blue)
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 2)))
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
