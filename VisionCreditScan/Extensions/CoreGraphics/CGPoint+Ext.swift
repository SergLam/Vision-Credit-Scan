//
//  CGPoint+Ext.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 5/6/21.
//  Copyright © 2021 iowncode. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width,
                       y: self.y * size.height)
    }
    
}
