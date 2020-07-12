//
//  RoundedTitleGeoView.swift
//  Poller
//
//  Created by Yida Zhang on 2020-07-05.
//  Copyright © 2020 Yida Zhang. All rights reserved.
//

import SwiftUI

struct RoundedTitleGeoView: View {
    var color: Color = .darkOrange
    
    var body: some View {
        Path { path in
            
            let w = 294
            let h = 8
            
            path.move(to: CGPoint(x: 1, y: 0))
            
            path.addLine(to: CGPoint(x: w - 1, y: 6))
            path.addArc(center: CGPoint(x: w - 2, y: 7), radius: 1, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 90), clockwise: false)
            
            path.addLine(to: CGPoint(x: 1, y: h))
            path.addArc(center: CGPoint(x: 1, y: h - 1), radius: 1, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            
            path.addLine(to: CGPoint(x: 0, y: 1))
            path.addArc(center: CGPoint(x: 1, y: 1), radius: 1, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        }
        .fill(color)
    }
}
