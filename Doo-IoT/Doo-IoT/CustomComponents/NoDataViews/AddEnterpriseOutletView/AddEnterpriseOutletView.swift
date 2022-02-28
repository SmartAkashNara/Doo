//
//  AddEnterpriseOutletView.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 24/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class AddEnterpriseOutletView: UIView {
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var labelTitle1: UILabel!
    @IBOutlet weak var centralImageView: UIImageView!
    @IBOutlet weak var labelContent1: UILabel!
    @IBOutlet weak var labelContent2: UILabel!
    @IBOutlet weak var buttonAction1: UIButton!
    @IBOutlet weak var buttonOfLogout: UIButton!
    
    @IBOutlet weak var buttonContentAction1: UIButton!
    @IBOutlet weak var topConstraintToBottomContentAction: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    // Performs the initial setup.
    private func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        
        // Auto-layout stuff.
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        
        // Show the view.
        addSubview(view)
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        /* Usage for swift < 3.x
         let bundle = NSBundle(forClass: self.dynamicType)
         let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
         let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
         */
        
        return view
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func show(_ for: DooNoDataView_1.ShowIn) {
        
    }

}
