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
                ScrollView {
                    ForEach(viewModel.pollItems) { item in
                        HStack {
                            if viewModel.editMode {
                                Text(item.itemName)
                                    .padding(.horizontal, 20)
                                    .multilineTextAlignment(.center)
                                    .frame(width: Constant.pollItemSize.width - 20, height: Constant.pollItemSize.height)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: Constant.pollItemSize.height/2)
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: Constant.pollItemSize.width - 20, height: Constant.pollItemSize.height))
                                Button("-") {
                                    viewModel.removeItem(at: viewModel.getIndexOf(item))
                                }
                                .frame(width: 20)
                                .foregroundColor(Color.red)

                            } else {
                                TextField("item name", text: $viewModel.pollItems[viewModel.getIndexOf(item)].itemName)
                                    .padding(.horizontal, 20)
                                    .multilineTextAlignment(.center)
                                    .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: Constant.pollItemSize.height/2)
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: Constant.pollItemSize.width, height: Constant.pollItemSize.height))
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .animation(nil)
                    }
                }.animation(.easeIn)
                HStack {
                    Button("add", action: viewModel.addNewItem)
                        .frame(width: Constant.pollItemSize.width*0.4, height: Constant.pollItemSize.height)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: Constant.pollItemSize.height/2)
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: Constant.pollItemSize.width*0.4, height: Constant.pollItemSize.height))
                        .opacity(0.7)
                        .padding()
                        .disabled(viewModel.editMode)
                    Button(viewModel.editMode ? "done" : "edit", action: viewModel.toggleEdit)
                        .frame(width: Constant.pollItemSize.width*0.4, height: Constant.pollItemSize.height)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: Constant.pollItemSize.height/2)
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: Constant.pollItemSize.width*0.4, height: Constant.pollItemSize.height))
                        .opacity(0.7)
                        .padding()

                }
                
                Spacer()
                Button("Done", action: viewModel.submit)
                    .font(.custom("Avenir-Heavy", size: 20))
                    .foregroundColor(.white)
                    .opacity(viewModel.deployable ? 1 : 0.5)
                    .padding()
                    .disabled(!viewModel.deployable)
                
            }
            .frame(width: Constant.pollSize.width, height: Constant.pollSize.height * 1.125)
            .background(RoundedGeoView(color: Color.darkOrange, tl: 0, tr: 0, bl: 50, br: 50))
            Spacer()

        }
        .animation(.easeIn)
        .offset(y: viewModel.showing ? 0 : -Constant.screenSize.height)
//        .edgesIgnoringSafeArea(.all)

    }
}
