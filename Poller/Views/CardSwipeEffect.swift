//
//  CardSwipeEffect.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-05.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import Foundation
import SwiftUI

struct CardSwipeEffect: GeometryEffect {
    
    var offset: CGFloat//CGSize
//    var rotation: Angle
    @ObservedObject var viewModel: ViewModel = ViewModel.shared
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        
        // if the offset becomes less than -900, change binding to 0
        let transformationOffset = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: offset, ty: -offset)
        let rad = Angle(degrees: Double((offset - 40)/20)).radians
        let transformationRotation = CGAffineTransform(rotationAngle: CGFloat(rad))
        if offset < -40 && offset > -900 {
            
            return ProjectionTransform(transformationRotation.concatenating(transformationOffset))
        } else if offset == -900 {
            DispatchQueue.main.async {
                viewModel.removeOne()
            }
            return ProjectionTransform(transformationRotation.concatenating(transformationOffset))
        }

        return ProjectionTransform(CGAffineTransform(rotationAngle: 0))
    }
    
}
