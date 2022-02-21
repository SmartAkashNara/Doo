//
//  CustomAlertView.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 18/12/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

//
// Reference - https://medium.com/@aatish.rajkarnikar/how-to-make-custom-alertview-dialogbox-with-animation-in-swift-3-2852f4e6f311
// Reference - https://github.com/aatish-rajkarnikar/ModalView/tree/master/ModalView
//

import UIKit

enum CustomAlertPurposeEnum {
    case success, failure
}

protocol CustomAlertProtocol {
    var backgroundView: UIView {get}
    var dialogView: UIView {get}
    
    func show(animated:Bool)
    func dismiss(animated:Bool)
    
    var purposeEnum: CustomAlertPurposeEnum {get}
}

var IS_CUSTOM_ALERT_VISIBLE: Bool = false
extension CustomAlertProtocol where Self: UIView{
    
    func showForWhile(animated:Bool){
        self.show(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
    
    func show(animated:Bool){
        
        guard !IS_CUSTOM_ALERT_VISIBLE else { return } // Normally success and failure won't collapse, so fine to keep at entry...
        
        self.backgroundView.alpha = 0
        
        switch self.purposeEnum {
        case .failure:
            IS_CUSTOM_ALERT_VISIBLE = true
            var dialogFrame = dialogView.frame; dialogFrame.origin.y = -200;  dialogView.frame = dialogFrame;
        case .success:
            var dialogFrame = dialogView.frame; dialogFrame.origin.y = UIScreen.main.bounds.size.height + 200;  dialogView.frame = dialogFrame;
        }
        
        SceneDelegate.getWindow?.rootViewController?.view.addSubview(self)
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundView.alpha = 0.0 // Set background alpha...
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                
                // self.dialogView.center  = CGPoint(x: self.center.x, y: 80)
                switch self.purposeEnum {
                case .failure:
                    var dialogFrame = self.dialogView.frame; dialogFrame.origin.y = 60; self.dialogView.frame = dialogFrame;
                case .success:
                    var dialogFrame = self.dialogView.frame;
                    dialogFrame.origin.y = (UIScreen.main.bounds.size.height - self.dialogView.frame.size.height - 60);
                    self.dialogView.frame = dialogFrame;
                }
                
            }, completion: { (completed) in
                
            })
        }else{
            self.backgroundView.alpha = 0.66
            self.dialogView.center  = self.center
        }
    }
    
    func dismiss(animated:Bool){
        IS_CUSTOM_ALERT_VISIBLE = false // any way we are just making false...
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: { (completed) in
                
            })
            UIView.animate(withDuration: 0.1, animations: {
                
                switch self.purposeEnum {
                case .failure:
                    var dialogFrame = self.dialogView.frame; dialogFrame.origin.y = -200;  self.dialogView.frame = dialogFrame;
                case .success:
                    var dialogFrame = self.dialogView.frame; dialogFrame.origin.y = UIScreen.main.bounds.size.height + 200;  self.dialogView.frame = dialogFrame;
                }
                
            }, completion: { (completed) in
                self.removeFromSuperview()
            })
        }else{
            self.removeFromSuperview()
        }
        
    }
}

// Custom Alert View
class CustomAlertView: UIView, CustomAlertProtocol{
    
    
    
    var purposeEnum: CustomAlertPurposeEnum = .failure
    var backgroundView = UIView()
    var dialogView = UIView()
    
    convenience init(title: String, forPurpose purpose: CustomAlertPurposeEnum = .failure) {
        self.init(frame: UIScreen.main.bounds)
        initialize(title: title, forPurpose: purpose)
    }
    override init(frame: CGRect) {
         super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
    
    func initialize(title: String, forPurpose purpose: CustomAlertPurposeEnum){
        
        // Assignment
        self.purposeEnum = purpose
        
        // Other work
        dialogView.clipsToBounds = true
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        addSubview(backgroundView)
        
        let dialogViewWidth = frame.width-64
        
        let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 30))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.Poppins.bold(16)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        dialogView.addSubview(titleLabel)
        
        let separatorLineView = UIView()
        separatorLineView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + 8)
        separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
        separatorLineView.backgroundColor = UIColor.clear
        dialogView.addSubview(separatorLineView)
        
        let titleHeight = titleLabel.textHeight(withWidth: dialogViewWidth-16)
        let dialogViewHeight = titleHeight + 8 + separatorLineView.frame.height + 8
        var titleFrame = titleLabel.frame; titleFrame.size.height = titleHeight;  titleLabel.frame = titleFrame;
        
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: frame.width-64, height: dialogViewHeight)
        
        switch self.purposeEnum {
        case .failure:
            dialogView.backgroundColor = .red
        break
        case .success:
            dialogView.backgroundColor = .app_green
        break
        }
         
        dialogView.layer.cornerRadius = 10
        addSubview(dialogView)
    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true) // belongs to modal protocol
    }
}
