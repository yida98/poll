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
        set { offset = newValue
            if offset == -900 {
                viewModel.removeOne()
            }
        }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        var transformationOffset = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
        var rad = Angle(degrees: Double(0)).radians
        var transformationRotation = CGAffineTransform(rotationAngle: CGFloat(rad))
        if offset < -40 {
            transformationOffset = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: offset + 40, ty: 0)
            rad = Angle(degrees: Double((offset + 40)/20)).radians
            transformationRotation = CGAffineTransform(rotationAngle: CGFloat(rad))
            // if the offset becomes less than -900, change binding to 0?????
            
            return ProjectionTransform(transformationRotation.concatenating(transformationOffset))
        }
        return ProjectionTransform(transformationRotation.concatenating(transformationOffset))
    }
    
}
