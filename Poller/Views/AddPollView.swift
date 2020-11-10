//
//  AddPollView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-11-09.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct AddPollView: View {
    
    @ObservedObject var viewModel: AddViewModel = AddViewModel.shared
    
    @State private var textStyle = UIFont.TextStyle.body
    
    var body: some View {
        VStack {
            VStack {
                TextField("Ask something", text: $viewModel.title)
                    .frame(width: 294, height: 130, alignment: .bottom)
                    .font(.custom("Avenir-Heavy", size: 28))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.4)
                    .padding()
                    
                ForEach(0..<viewModel.pollItems.count) { integer in
                    TextField("poll item", text: $viewModel.pollItems[integer])
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: Constant.pollItemSize.height/2)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height))

                }
                Button("+", action: viewModel.addNewItem)
                    .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height)
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: Constant.pollItemSize.height/2)
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height))
                    .opacity(0.7)
                
                Spacer()
                Button("Done", action: viewModel.addNewItem)
                    .font(.custom("Avenir-Heavy", size: 20))
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .padding()
                    .disabled(viewModel.title == "" && viewModel.pollItems.count == 0)
                
            }
            .frame(width: Constant.pollSize.width, height: Constant.pollSize.height * 1.1)
            .background(RoundedGeoView(color: Color.darkOrange, tl: 0, tr: 0, bl: 50, br: 50))
            
            Spacer()

        }
        .animation(.easeIn)
        .offset(y: viewModel.showing ? 0 : -Constant.screenSize.height)
        .edgesIgnoringSafeArea(.all)

    }
}

struct AddPollView_Previews: PreviewProvider {
    static var previews: some View {
        AddPollView()
    }
}
