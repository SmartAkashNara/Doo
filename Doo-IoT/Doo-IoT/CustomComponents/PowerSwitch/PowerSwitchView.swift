//
//  PowerSwitchView.swift
//  Doo-IoT
//
//  Created by Shraddha on 10/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class PowerSwitchView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var switchPower : DooSwitch!
    var selectedAppliance: ApplianceDataModel? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
        self.initialConfig()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.initialConfig()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.initialConfig()
    }
    
    func initialConfig() {
        self.labelTitle.font = UIFont.Poppins.medium(11.3)
        self.labelTitle.textColor = .black
        self.labelTitle.numberOfLines = 2
        self.labelTitle.lineBreakMode = .byWordWrapping
        self.labelTitle.textAlignment = .left
    }
    
    func configWithApplianceObj(appliance: ApplianceDataModel?) {
        self.labelTitle.text = "Power"
        if let objAppliance = appliance {
            self.selectedAppliance = objAppliance
            if appliance?.onOffStatus ?? false {
                self.switchPower.setOnSwitch()
            }else{
                self.switchPower.setOffSwitch()
            }
        }
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
}

//extension PowerSwitchView {
//    @objc func powerSwitchValueChanged(_ sender: UISwitch) {
//        print("changed status")
//        self.selectedAppliance?.onOffStatus = !(self.selectedAppliance?.onOffStatus ?? false)
//        sender.changeSwitchThumbColorBasedOnState()
//    }
//}
