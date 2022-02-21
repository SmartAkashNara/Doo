//
//  SignInWithAlexaAmazonViewController.swift
//  Doo-IoT
//
//  Created by Akash on 28/01/22.
//  Copyright © 2022 SmartSense. All rights reserved.
//

import UIKit
import SafariServices

class SignInWithAlexaAmazonViewController: UIViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonSignInAmazon: UIButton!
    
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
        
        labelTitle.font = UIFont.Poppins.regular(11)
        labelTitle.textColor = .blueHeadingAlpha60
        labelTitle.numberOfLines = 0
        buttonSignInAmazon.setThemeAppBlue("Sign In With Amazon")
        
        loadData()
    }
    
    func loadData(){
        labelTitle.text = "Binding DOO account with Amazon account allows you to control Alexa- enabled devices through Amazon Echo speaker. (For eg Alexa, turn on light)"
        navigationTitle.text = "Link with Amazon Alexa"
    }
}

// MARK: - Action listeners
extension SignInWithAlexaAmazonViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonSignInAmazonActionListener(_ sender: UIButton) {
        self.viewModel.getAuthCodeForAlexaApi(viewController: self)
    }
}

