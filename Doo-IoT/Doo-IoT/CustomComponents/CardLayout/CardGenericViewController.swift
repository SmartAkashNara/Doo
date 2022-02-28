//
//  CardGenericViewController.swift
//  CardViewAnimation
//
//  Created by Kiran Jasvanee on 03/10/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

import UIKit

class CardGenericViewController: UIViewController {

    weak var baseController: CardBaseViewController? = nil
    weak var baseTabbarController: CardTabbarBaseViewController? = nil
    @IBOutlet weak var handleArea: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
