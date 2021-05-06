//
//  UIScreen+Ext.swift
//  VisionCreditScan
//
//  Created by Serhii Liamtsev on 5/6/21.
//  Copyright © 2021 Serhii Liamtsev. All rights reserved.
//

import UIKit

enum ScreenType: CGFloat, CaseIterable {
    case unknown = 0
    
    case iphoneSE = 1136
    case iphone678 = 1334
    case iphone678plus = 1920
    
    case iphoneXR = 1792
    case iphone12mini = 2430
    case iphoneXXs = 2436
    case iphone12 = 2532
    case iphoneXMax = 2688
    case iphone12Max = 2778
}

extension UIScreen {
    
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var pixelsHeight: CGFloat {
        return UIScreen.main.nativeBounds.height
    }
    static var pixelsWidth: CGFloat {
        return UIScreen.main.nativeBounds.width
    }
    
    static var pixelsScale: CGFloat {
        return UIScreen.main.nativeScale
    }
    
    static var model: ScreenType {
        return ScreenType(rawValue: self.pixelsHeight) ?? ScreenType.unknown
    }
    
}
