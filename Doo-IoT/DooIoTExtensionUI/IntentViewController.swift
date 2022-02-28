//
//  IntentViewController.swift
//  DooIotExtensionUI
//
//  Created by Shraddha on 07/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import IntentsUI
import UIKit

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        guard let intent = interaction.intent as? ApplianceActionRgbIntent else {
            completion(true, parameters, .zero)
            return
        }
        
        if interaction.intentHandlingStatus == .success {
            let viewController = RGBAndFanUIControlViewController(for: intent)
            attachChild(viewController)
            viewController.view.layoutIfNeeded()
            completion(true, parameters, viewController.rgbAndFanUIView.tableViewUIContainer.contentSize)
        }
        
        completion(false, parameters, .zero)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
    @IBAction func buttonSiriClicked(_ sender: UIButton) {
       print("HIIIIII")
    }
}

extension IntentViewController{
    private func attachChild(_ viewController: UIViewController) {
        addChild(viewController)
        
        if let subview = viewController.view {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
            
            // Set the child controller's view to be the exact same size as the parent controller's view.
            subview.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            subview.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            
            subview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            subview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        viewController.didMove(toParent: self)
    }
}
