//
//  FlexiPanGesture.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 09/07/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum PanDirection {
    case vertical
    case horizontal
}

class FlexiPanGesture: UIPanGestureRecognizer {
    let direction: PanDirection
    var panGestureCancellation: (()->())? = nil
    
    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if state == .began {
            let vel = velocity(in: view)
            switch direction {
            case .horizontal where abs(vel.y) > abs(vel.x):
                state = .cancelled
                self.panGestureCancellation?()
            case .vertical where abs(vel.x) > abs(vel.y):
                state = .cancelled
                self.panGestureCancellation?()
            default:
                break
            }
        }
    }
}
