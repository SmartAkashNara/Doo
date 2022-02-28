//
//  TargetAccessSegment.swift
//  Doo-IoT
//
//  Created by smartsense-kiran on 22/09/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class TargetAccessSegment: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var labelOfTitle: UILabel? = nil
    private var segmentOfAccess: UISegmentedControl? = nil
    private var labelOfNote: UILabel? = nil
    
    var titleValue: String? = nil // Title Setup
    var titleColor: UIColor? = nil // Title Setup
    var segmentValues: [String] = []
    var segmentNotes: [String] = []
    var selectedValue: ((Int)->())? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if labelOfTitle == nil {
            self.initSetUp()
        }
    }
    
    func initSetUp() {
        
        // Title Label...............
        self.labelOfTitle = UILabel.init(frame: .zero)
        self.labelOfTitle?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.labelOfTitle!)
        self.labelOfTitle?.text = self.titleValue ?? ""
        self.labelOfTitle?.textColor = (self.titleColor != nil) ? self.titleColor : UIColor.textfieldTitleColor
        self.labelOfTitle?.font = UIFont.Poppins.medium(11.3)
        self.labelOfTitle?.addTop(isSuperView: self, constant: 0)
        self.labelOfTitle?.addLeft(isSuperView: self, constant: 0)
        self.labelOfTitle?.addRight(isSuperView: self, constant: 0)
        
        // Segement...............
        self.segmentOfAccess = UISegmentedControl.init(items: self.segmentValues)
        self.segmentOfAccess?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.segmentOfAccess!)
        self.segmentOfAccess?.addTop(isSuperView: self, constant: 24)
        self.segmentOfAccess?.addLeft(isSuperView: self, constant: 0)
        self.segmentOfAccess?.addRight(isSuperView: self, constant: 0)
        self.segmentOfAccess?.selectedSegmentIndex = 0
        //Change text color of UISegmentedControl
        self.segmentOfAccess?.selectedSegmentTintColor = UIColor.blueSwitch
        //Change UISegmentedControl background colour
        self.segmentOfAccess?.backgroundColor = UIColor.blueHeadingAlpha50
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.segmentOfAccess?.setTitleTextAttributes(titleTextAttributes, for: .normal)
        self.segmentOfAccess?.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        // Add function to handle Value Changed events
        self.segmentOfAccess?.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
        self.addSubview(self.segmentOfAccess!)
        
        // Note Label.................
        self.labelOfNote = UILabel.init(frame: .zero)
        self.labelOfNote?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.labelOfNote!)
        self.labelOfNote?.text = self.titleValue ?? ""
        
        self.labelOfNote?.textColor = UIColor.blueHeadingAlpha60
        self.labelOfNote?.font = UIFont.Poppins.regular(12)
        self.labelOfNote?.addTop(isSuperView: self, constant: 64)
        self.labelOfNote?.addLeft(isSuperView: self, constant: 0)
        self.labelOfNote?.addRight(isSuperView: self, constant: 0)
        self.labelOfNote?.lineBreakMode = .byWordWrapping
        self.labelOfNote?.numberOfLines = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.labelOfNote?.text = "NOTE: \(self.segmentNotes[self.segmentOfAccess?.selectedSegmentIndex ?? 0])"
        }
    }

    @objc func segmentedValueChanged(_ sender: UISegmentedControl!)
    {
        print("Selected Segment Index is : \(sender.selectedSegmentIndex)")
        self.labelOfNote?.text = "NOTE: \(self.segmentNotes[sender.selectedSegmentIndex]    )"
        self.selectedValue?(sender.selectedSegmentIndex)
    }
    
    func setTargetSegment(value: Int) {
        self.segmentOfAccess?.selectedSegmentIndex = value
    }
}
