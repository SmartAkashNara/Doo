//
//  UIView-Extensions.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    func makeRoundByCorners(){
        self.cornerRadius = self.bounds.height / 2.0
    }

    enum enumCorners { case topLeft, topRight, bottomLeft, bottomRight }
  
    func selectedCorners(radius: CGFloat, _ corners: [enumCorners]){
        self.layer.cornerRadius = radius
        var arrayCorners = [CACornerMask]()
        corners.forEach { (corners) in
            switch corners {
            case .topLeft: arrayCorners.append(.layerMinXMinYCorner)
            case .topRight: arrayCorners.append(.layerMaxXMinYCorner)
            case .bottomLeft: arrayCorners.append(.layerMinXMaxYCorner)
            case .bottomRight: arrayCorners.append(.layerMaxXMaxYCorner)
            }
        }
        self.layer.maskedCorners = CACornerMask(arrayCorners)
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func addDashedBorder(color: UIColor) {
        layoutIfNeeded()
        let shapeRect = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = color.cgColor
        yourViewBorder.frame = bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.lineWidth = 2
        yourViewBorder.lineJoin = CAShapeLayerLineJoin.round
        yourViewBorder.lineDashPattern = [4,4]
        yourViewBorder.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath
        yourViewBorder.accessibilityLabel = "addDashedBorder"
        layer.addSublayer(yourViewBorder)
    }
}

extension UIView {
    // centerX and centerY constraint
    func addCenterX(inSuperView superView: UIView){
        superView.addConstraint(NSLayoutConstraint.init(item: self, attribute: .centerX, relatedBy: .equal, toItem: superView.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1.0, constant: 0))
    }
    func addCenterY(inSuperView superView: UIView, multiplier: CGFloat = 1.0){
        superView.addConstraint(NSLayoutConstraint.init(item: self, attribute: .centerY, relatedBy: .equal, toItem: superView.safeAreaLayoutGuide, attribute: .centerY, multiplier: multiplier, constant: 0))
    }
    
    // Edusense Take These two methods, having relateToView params
    @discardableResult
    func addCenterX(inSuperView superView: UIView, relateToView relateView: UIView) -> NSLayoutConstraint {
        let centerXConstraint = NSLayoutConstraint.init(item: self, attribute: .centerX, relatedBy: .equal, toItem: relateView, attribute: .centerX, multiplier: 1.0, constant: 0)
        superView.addConstraint(centerXConstraint)
        return centerXConstraint
    }
    @discardableResult
    func addCenterY(inSuperView superView: UIView, relateToView relateView: UIView, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        let centerYConstraint = NSLayoutConstraint.init(item: self, attribute: .centerY, relatedBy: .equal, toItem: relateView, attribute: .centerY, multiplier: multiplier, constant: 0)
        superView.addConstraint(centerYConstraint)
        return centerYConstraint
    }
    
    // width and height constraints
    @discardableResult
    func addWidth(constant: Double) -> NSLayoutConstraint {
        let widthConstraint = NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(constant))
        self.addConstraint(widthConstraint)
        return widthConstraint
    }
    @discardableResult
    func addHeight(constant: Double) -> NSLayoutConstraint {
        let heightConstraint = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(constant))
        self.addConstraint(heightConstraint)
        return heightConstraint
    }
    
    // left, top, bottom, right constraints
    @discardableResult
    func addLeft(isSuperView superView: UIView, constant: Float) -> NSLayoutConstraint  {
        let leftConstraint = NSLayoutConstraint.init(item: self, attribute: .left, relatedBy: .equal, toItem: superView.safeAreaLayoutGuide, attribute: .left, multiplier: 1.0, constant: CGFloat(constant))
        superView.addConstraint(leftConstraint)
        return leftConstraint
    }
    @discardableResult
    func addTop(isSuperView superView: UIView, constant: Float, toSafeArea: Bool = true) -> NSLayoutConstraint {
        let superViewLayout = toSafeArea ? superView.safeAreaLayoutGuide : superView
        let topConstraint = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: superViewLayout, attribute: .top, multiplier: 1.0, constant: CGFloat(constant))
        superView.addConstraint(topConstraint)
        return topConstraint
    }
    func addTop(isRelateTo relateView: UIView, isSuperView superView: UIView, constant: Float) {
        superView.addConstraint(NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: relateView.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: CGFloat(constant)))
    }
    @discardableResult
    func addBottom(isSuperView superView: UIView, constant: Float, toSafeArea: Bool = true) -> NSLayoutConstraint {
        let superViewLayout = toSafeArea ? superView.safeAreaLayoutGuide : superView
        let bottomConstraint = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: superViewLayout, attribute: .bottom, multiplier: 1.0, constant: CGFloat(constant))
        superView.addConstraint(bottomConstraint)
        return bottomConstraint
        
    }
    @discardableResult
    func addRight(isSuperView superView: UIView, constant: Float) -> NSLayoutConstraint{
        let rightConstraint = NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: superView.safeAreaLayoutGuide, attribute: .right, multiplier: 1.0, constant: CGFloat(constant))
        superView.addConstraint(rightConstraint)
        return rightConstraint
    }
    @discardableResult
    func addRight(isSuperView superView: UIView, constant: Float, relatedBy:NSLayoutConstraint.Relation) -> NSLayoutConstraint{
        let rightConstraint = NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: relatedBy, toItem: superView.safeAreaLayoutGuide, attribute: .right, multiplier: 1.0, constant: CGFloat(constant))
        superView.addConstraint(rightConstraint)
        return rightConstraint
    }
    func addSurroundingZero(isSuperView superView: UIView, constant: Float = 0.0) {
        self.addLeft(isSuperView: superView, constant: constant)
        self.addRight(isSuperView: superView, constant: -constant)
        self.addTop(isSuperView: superView, constant: constant)
        self.addBottom(isSuperView: superView, constant: -constant)
    }
    func addSurroundingZeroToSuperView(isSuperView superView: UIView, constant: Float = 0.0) {
        self.addLeft(isSuperView: superView, constant: constant)
        self.addRight(isSuperView: superView, constant: -constant)
        self.addTop(isSuperView: superView, constant: constant, toSafeArea: false)
        self.addBottom(isSuperView: superView, constant: -constant, toSafeArea: false)
    }
    func addLeftRightWithZero(isSuperView superView: UIView) {
        self.addLeft(isSuperView: superView, constant: 0)
        self.addRight(isSuperView: superView, constant: 0)
    }
}

extension UIView {
    func applyShadow(cornerRadius:CGFloat = 0, shadowOpacity:CGFloat = 0.3, size:CGSize = CGSize(width: 0, height: 0), shadowRadius:CGFloat = 1, shadowColor:UIColor = .black){
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = Float(shadowOpacity)
        self.layer.shadowRadius = shadowRadius
        self.layer.cornerRadius = cornerRadius
    }
    
    func applyShadowWithAboveBordersOnly(cornerRadius:CGFloat = 0, shadowOpacity:CGFloat = 0.3, size:CGSize = CGSize(width: 0, height: 0), shadowRadius:CGFloat = 1, shadowColor:UIColor = .black){
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = Float(shadowOpacity)
        self.layer.shadowRadius = shadowRadius
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func applyShadowWithBelowBordersOnly(cornerRadius:CGFloat = 0, shadowOpacity:CGFloat = 0.3, size:CGSize = CGSize(width: 0, height: 0), shadowRadius:CGFloat = 1, shadowColor:UIColor = .black){
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = Float(shadowOpacity)
        self.layer.shadowRadius = shadowRadius
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    func applyShadowJob(cornerRadius:CGFloat = 8.3){
        applyShadow(cornerRadius: cornerRadius, shadowOpacity: 0.16, size: CGSize(width: 0, height: 1), shadowRadius: 2)
    }
    
    func applyShadowJobWithAboveBordersOnly(cornerRadius:CGFloat = 8.3){
        applyShadowWithAboveBordersOnly(cornerRadius: cornerRadius, shadowOpacity: 0.16, size: CGSize(width: 0, height: 1), shadowRadius: 2)
    }
    
    func applyShadowJobWithBelowBordersOnly(cornerRadius:CGFloat = 8.3){
        applyShadowWithBelowBordersOnly(cornerRadius: cornerRadius, shadowOpacity: 0.16, size: CGSize(width: 0, height: 1), shadowRadius: 2)
    }
}
