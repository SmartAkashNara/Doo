//
//  SplashViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 25/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    var splashViewModel: SplashViewModel = SplashViewModel()
    @IBOutlet weak var imageViewOfSplash: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callGetUserInformaiton()
        
        // Animation.
        self.imageViewOfSplash.image = UIImage.gif(asset: "SplashWhiteAnimation")
        // self.splashViewModel.isAnimationCompleted = true // START ANIMATION
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.splashViewModel.isAnimationCompleted = true
            self.imageViewOfSplash.image = UIImage.gif(asset: "frame_124_delay-0.04s")
        }
    }
    
    func callGetUserInformaiton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.splashViewModel.callFetchProfileInfo {
            }
        }
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
