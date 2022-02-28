//
//  DooNavigationBarDetailView_1.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class DooNavigationBarDetailView_1: UIView {
    
    //top(9) + labels(47) + Bottom(20) = 76
    static let viewHeight: CGFloat = 76
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    
    var mainView:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.initSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
        self.initSetUp()
    }
    
    // Performs the initial setup.
    private func setupView() {
        mainView = viewFromNibForClass()
        mainView.frame = bounds
        
        // Auto-layout stuff.
        mainView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        
        // Show the view.
        addSubview(mainView)
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    private func initSetUp() {
        labelTitle.font = UIFont.Poppins.semiBold(18)
        labelTitle.textColor = UIColor.blueHeading
        
        labelSubTitle.font = UIFont.Poppins.regular(12)
        labelSubTitle.textColor = UIColor.blueHeadingAlpha60

        mainView.backgroundColor = UIColor.grayCountryHeader
        mainView.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
    }
    
    func viewConfig(title: String, subtitle: String) {
        labelTitle.text = title
        if !subtitle.isEmpty {
            labelSubTitle.isHidden = false
            labelSubTitle.text = subtitle
        }else{
            labelSubTitle.isHidden = true
        }
    }
    
    
}

// set width equal to device width
extension DooNavigationBarDetailView_1 {
    func setWidthEqualToDeviceWidth() {
        for constraint in self.constraints {
            if constraint.firstAttribute == .width {
                constraint.constant = UIScreen.main.bounds.size.width
            }
        }
    }
}
