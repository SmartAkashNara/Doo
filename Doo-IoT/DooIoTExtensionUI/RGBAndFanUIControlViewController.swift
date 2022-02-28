/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A view that lists the order invoice.
 */

import UIKit
import Intents

class RGBAndFanUIControlViewController: UIViewController {
    
    private let intent: ApplianceActionRgbIntent
    
    @IBOutlet weak var rgbAndFanUIView: RGBAndFanUIView!
    
    init(for applianceIntent: ApplianceActionRgbIntent) {
        intent = applianceIntent
        super.init(nibName: "RGBAndFanUIView", bundle: Bundle(for: RGBAndFanUIControlViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rgbAndFanUIView.configureTableView()
    }
}

