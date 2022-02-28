//
//  LinkWithAlexaViewController.swift
//  Doo-IoT
//
//  Created by Akash on 28/01/22.
//  Copyright © 2022 SmartSense. All rights reserved.
//

import UIKit
import SafariServices

class LinkWithAlexaViewController: UIViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPermissionDetail: UILabel!
    @IBOutlet weak var labelLinkUnLinkTitle: UILabel!
    
    @IBOutlet weak var buttonAgreeLink: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageLogoWidthConstrain: NSLayoutConstraint!
    
    var viewModel = LinkWithAlexaViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
    }
    
    func setDefaults(){
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = false
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
        labelTitle.font = UIFont.Poppins.medium(14)
        labelTitle.textColor = .blueHeading
        labelTitle.numberOfLines = 0
        
        labelPermissionDetail.font = UIFont.Poppins.regular(11)
        labelPermissionDetail.textColor = .blueHeadingAlpha60
        labelPermissionDetail.numberOfLines = 0
        
        labelLinkUnLinkTitle.font = UIFont.Poppins.regular(9)
        labelLinkUnLinkTitle.textColor = .blueHeadingAlpha60
        labelLinkUnLinkTitle.numberOfLines = 0
        
        buttonCancel.backgroundColor = .grayCancelButtonAlexa
        buttonCancel.cornerRadius = 6.7
        buttonCancel.setTitleColor(.blueSwitch, for: .normal)
        buttonCancel.titleLabel?.font = UIFont.Poppins.medium(12)
        
        loadData()
    }
    
    func loadData(){
        
            let str = "Alexa, Turn on light \n\nAlexa, set Fan speed to level 4 \n\nAlexa, Turn off charger \n\nAlexa, Turn off fan"
            navigationTitle.text = "Link with Amazon Alexa"
            labelTitle.text = "Already linked \nwith Amazon Alexa"
            labelPermissionDetail.text = "You can control Alexa-enabled devices with Amazon Alexa speakers such as: \n\n\(str)"
            labelLinkUnLinkTitle.text = "*If you need to unlink, please go to Alexa app to disable DOO skill."
            
            buttonAgreeLink.setThemeAppBlue("Re-Login")
            buttonCancel.setTitle("Back", for: .normal)
            imageLogo.image = UIImage.init(named: "amazon-alexa")
            imageLogo.contentMode = .scaleAspectFit
            imageLogoWidthConstrain.constant = 50
    }
}

// MARK: - Action listeners
extension LinkWithAlexaViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonAgreeLinkActionListener(_ sender: UIButton) {
        self.viewModel.getAuthCodeForAlexaApi(viewController: self)
    }
    
    @IBAction func buttonCancelLinkActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
