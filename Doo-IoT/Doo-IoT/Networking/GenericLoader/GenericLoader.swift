//
//  GenericLoader.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 21/12/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialActivityIndicator

protocol GenericLoaderProtocol {
    var backgroundView: UIView {get}
    var loaderView: UIView {get}
    var activityIndicator: UIImageView {get}
    
    func show(animated:Bool)
    func dismiss(animated:Bool)
    func informIndicatorStarted() -> Bool
    func informIndicatorDismissed()
}

extension GenericLoaderProtocol where Self: UIView{
    
    func showForWhile(animated:Bool){
        self.show(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
    
    func show(animated:Bool){
        
        guard self.informIndicatorStarted() else {return}
        
        self.backgroundView.alpha = 0
        
        // Show from bottom
        var dialogFrame = loaderView.frame; dialogFrame.origin.y = UIScreen.main.bounds.size.height + 200;  loaderView.frame = dialogFrame;
        
        SceneDelegate.getWindow?.rootViewController?.view.addSubview(self)
        SceneDelegate.getWindow?.rootViewController?.view.endEditing(true) // While processing, there is no requirement of keyboard.
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundView.alpha = 0.16
            })
            self.loaderView.alpha = 0.6
            UIView.animate(withDuration: 0.4, animations: {
                
                // Get it back from bottom to show in front.
                self.loaderView.alpha = 1.0
                
            }, completion: { (completed) in
                
            })
        }else{
            self.backgroundView.alpha = 0.66
            self.loaderView.center  = self.center
        }
    }
    
    func dismiss(animated:Bool){
        
        self.informIndicatorDismissed() // Loader not running
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: { (completed) in
                
            })
            UIView.animate(withDuration: 0.4, animations: {
                
                // Dismiss it back to bottom
                self.loaderView.alpha = 0.6
                
            }, completion: { (completed) in 
                self.removeFromSuperview()
            })
        }else{
            self.removeFromSuperview()
        }
        
    }
}

// Custom Alert View
protocol GenericLoaderViewDelegate {
    func apiCancellationRequested()
}
class GenericLoaderView: UIView, GenericLoaderProtocol{
    
    var backgroundView = UIView()
    var loaderView = UIView()
    var activityIndicator = UIImageView.init(frame: .zero)
    var isRunning: Bool = false
    
    var delegate: GenericLoaderViewDelegate? = nil
    
    convenience init() {
         self.init(frame: UIScreen.main.bounds)
        initialize()
    }
    override init(frame: CGRect) {
         super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
    
    func initialize(){
        
        // Other work
        loaderView.clipsToBounds = true
        
        self.backgroundView.frame = frame
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.8
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        addSubview(self.backgroundView)
        
        self.loaderView.translatesAutoresizingMaskIntoConstraints = false
        self.loaderView.backgroundColor = .white
        addSubview(self.loaderView)
        self.loaderView.addCenterX(inSuperView: self)
        self.loaderView.addCenterY(inSuperView: self)
        self.loaderView.addHeight(constant: 80)
        self.loaderView.addWidth(constant: 80)
        self.loaderView.cornerRadius = 20.0
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.backgroundColor = .white
        self.loaderView.addSubview(self.activityIndicator)
        self.activityIndicator.addCenterX(inSuperView: self.loaderView)
        self.activityIndicator.addCenterY(inSuperView: self.loaderView)
        self.activityIndicator.addHeight(constant: 30)
        self.activityIndicator.addWidth(constant: 30)
        self.activityIndicator.image = UIImage.gif(asset: "logo_loader")
         
        addSubview(loaderView)
    }
    
    @objc func didTappedOnBackgroundView(){
        // dismiss(animated: true) // belongs to modal protocol
        SceneDelegate.getWindow?.rootViewController?.popupAlert(message: "Cancel Request?", actionTitles: ["No", "Yes"], actions: [
                                                                    { (action1) in
                                                                        debugPrint("no called")
                                                                        // Don't do anything...
                                                                    },
                                                                    { (action2) in
                                                                        debugPrint("yes called")
                                                                        self.delegate?.apiCancellationRequested()
                                                                        self.dismiss(animated: true)
                                                                    }])
    }
    
    // Protocol Methods .........................
    func informIndicatorStarted() -> Bool{
        if !self.isRunning {
            self.isRunning = true
            return true
        }
        return false
    }
    
    func informIndicatorDismissed() {
        self.isRunning = false
    }
    
}
