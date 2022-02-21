//
//  DooAPILoader.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class DooAPILoader: UIView {

    private static var dooTabbarLoader: DooAPILoader? = nil
    
    class var shared: DooAPILoader {
        if dooTabbarLoader == nil {
            dooTabbarLoader = DooAPILoader()
            if let window = SceneDelegate.getWindow, let apiLoaderView = dooTabbarLoader {
                window.addSubview(apiLoaderView)
                dooTabbarLoader?.backgroundColor = .clear
            }
        }
        return dooTabbarLoader!
    }
    class func reassignWindow() {
        dooTabbarLoader = DooAPILoader()
        if let window = SceneDelegate.getWindow, let apiLoaderView = dooTabbarLoader {
            window.addSubview(apiLoaderView)
            dooTabbarLoader?.backgroundColor = .clear
        }
    }
    
    var backgroundMainView: UIView = UIView.init(frame: .zero)
    var loadingHolderView: UIView = UIView.init(frame: .zero)
    var imageviewDooLoader: UIImageView = UIImageView.init(frame: .zero)
    
    func allocate() {}
    
    convenience init() {
        self.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        self.backgroundMainView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundMainView.backgroundColor = .black
        addSubview(self.backgroundMainView)
        self.backgroundMainView.addSurroundingZeroToSuperView(isSuperView: self)
        
        self.loadingHolderView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingHolderView.backgroundColor = .white
        addSubview(self.loadingHolderView)
        self.loadingHolderView.addCenterX(inSuperView: self)
        self.loadingHolderView.addCenterY(inSuperView: self)
        self.loadingHolderView.addHeight(constant: 80)
        self.loadingHolderView.addWidth(constant: 80)
        self.loadingHolderView.cornerRadius = 20.0
        
        self.imageviewDooLoader.translatesAutoresizingMaskIntoConstraints = false
        self.imageviewDooLoader.backgroundColor = .white
        self.loadingHolderView.addSubview(self.imageviewDooLoader)
        self.imageviewDooLoader.addCenterX(inSuperView: self.loadingHolderView)
        self.imageviewDooLoader.addCenterY(inSuperView: self.loadingHolderView)
        self.imageviewDooLoader.addHeight(constant: 30)
        self.imageviewDooLoader.addWidth(constant: 30)
        self.imageviewDooLoader.image = UIImage.gif(asset: "logo_loader")
        
        self.backgroundMainView.alpha = 0.0
        self.loadingHolderView.alpha = 0.0
        
        self.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func startLoading() {
        SceneDelegate.getWindow?.endEditing(true)
        self.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.loadingHolderView.backgroundColor = .white
            self.backgroundMainView.alpha = 0.4
            self.loadingHolderView.alpha = 1.0
            self.layoutIfNeeded()
        }
    }
    func stopLoading() {
        self.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.loadingHolderView.backgroundColor = .clear
            self.backgroundMainView.alpha = 0.0
            self.loadingHolderView.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
