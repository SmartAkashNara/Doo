//
//  DooTabbarViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 20/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

enum DooTabs: Int {
    case menu = 0, home, groups, smart
}
class DooTabbarViewController: CardTabbarBaseViewController {
    
    private var dooTab: DooTabs = .home // default seelcted tab
    
    @IBOutlet weak var TabbarView: UIView!
    @ObservedObject var dooTabbarSelection: DooTabbarObservable = DooTabbarObservable.shared
    private var tabbarController: UIHostingController<DooTabbarView>? = nil
        
    // Card Work
    // var topCard: EnterpriseTopMenuViewController? = UIStoryboard.menu.enterpriseTopMenuVC
    var topUpdatedLayoutCard: EnterpriseTopLayoutViewController? = UIStoryboard.menu.enterpriseTopLayoutVC

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TABBAR_INSTANCE = self // allocate globally.
        DooAPILoader.shared.allocate()
        
        // self.topCard?.view.layoutIfNeeded() // load top card. this will call its view did load and make its layout assigned. Otherwise you can face crashes of tableview or other layouts not found.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.addTabbar()
    }
    
    func addTabbar() {
        // Add custom tabbar as subview
        guard self.tabbarController == nil else {return}
        
        // Configure and add tabbar.
        self.tabbarController = UIHostingController(rootView: DooTabbarView())
        self.tabBar.addSubview(tabbarController!.view)
        tabbarController!.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 49)
        self.dooTabbarSelection.indexChanged { (index) in
            print(index)
            self.selectedIndex = index
            self.dooTab = DooTabs.init(rawValue: index) ?? .home // Change doo tab case, based on tab changes.
            
            self.informViewsToUpdate(atIndex: index)
        }
        
        self.dooTabbarSelection.selection = self.dooTab.rawValue // Default selected tab
    }
    
    func informViewsToUpdate(atIndex index: Int) {
        
        let controller = (self.viewControllers?[index] as? UINavigationController)?.viewControllers.first
        if controller is MenuViewController {
            (controller as? MenuViewController)?.viewAppearedUsingTab()
        }else if controller is HomeViewController {
            (controller as? HomeViewController)?.viewAppearedUsingTab()
        }else if controller is GroupsMainViewController {
            (controller as? GroupsMainViewController)?.viewAppearedUsingTab()
        }else if controller is SmartMainViewController {
            (controller as? GroupsMainViewController)?.callApiWhenChangeEnterprise() // Only refresh API stuff.
        }
    }
    
    // Change tab manually from outside.
    func setTabManually(_ caseValue: DooTabs) {
        self.dooTab = caseValue
        self.dooTabbarSelection.selection = self.dooTab.rawValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var selectedIndex: Int {
        didSet {
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

// MARK: Set & Open Enterprise Work
extension DooTabbarViewController {
    
    func openEnterpriseSwitchMenuCard() {
        /*
        if let topView = self.topCard {
            self.setLayout(withCard: topView, cardPosition: .top)
            self.topCard?.openCard()
        }
 */
        if let topLayoutCard = topUpdatedLayoutCard{
            topLayoutCard.modalPresentationStyle = .overFullScreen
            topLayoutCard.loadViewIfNeeded()
            topLayoutCard.openCard()
            self.present(topLayoutCard, animated: false, completion: nil)
        }
    }
    
    // Card Work
    private func setLayout(withCard cardVC: CardGenericViewController, cardPosition: CardPosition) {
        // Setup dynamic card.
        // card setup
        self.cardPosition = cardPosition
        self.setupCard(cardVC)
        
        self.setCardHandleAreaHeight = 0
        // self.offCurveInCard()
        self.applyDarkOnlyOnCard = true
        self.updateProgress = { name in
            // print("Happy birthday, \(name)!")
        }
    }
}

// MARK: Set & Open Enterprise Work
extension DooTabbarViewController {
    
    func configureTopLayoutForEntepriseChange() {
        
    }
}

// MARK: Refresh views when tab option taps
extension DooTabbarViewController {
    
    func refreshAllViewsOfTabsWhenEnterpriseChanges() {
        self.refreshMenuView()
        self.refreshHomeView()
        self.refreshGroupsView()
        self.refreshSmartViews()
    }
    
    // Refresh specific views of tabbar
    private func refreshMenuView() {
        let controller = (self.viewControllers?[DooTabs.menu.rawValue] as? UINavigationController)?.viewControllers.first
        if controller is MenuViewController {
            (controller as? MenuViewController)?.switchToNewEnterpriseAndRefreshMenulistUsingAPI()
        }
    }
    func refreshHomeView() {
        let controller = (self.viewControllers?[DooTabs.home.rawValue] as? UINavigationController)?.viewControllers.first
        if controller is HomeViewController {
            if controller?.isViewLoaded ?? false{
                (controller as? HomeViewController)?.callApiWhenChangeEnterprise(isPullToRefresh: true) // keep pull to refresh true to refresh all stuff from scratch... 
            }
        }
    }
    private func refreshGroupsView() {
        let controller = (self.viewControllers?[DooTabs.groups.rawValue] as? UINavigationController)?.viewControllers.first
        if controller is GroupsMainViewController {
            if controller?.isViewLoaded ?? false{
                (controller as? GroupsMainViewController)?.callApiWhenChangeEnterprise()
            }
        }
    }
    private func refreshSmartViews() {
        let controller = (self.viewControllers?[DooTabs.smart.rawValue] as? UINavigationController)?.viewControllers.first
        if controller is SmartMainViewController {
            if controller?.isViewLoaded ?? false{
                // ON THIS IF REQUIRED TO HIDE SCHEDULER BASED ON USER OR ADMIN ROLE....
                // (controller as? SmartMainViewController)?.defaultConfig() // reset content views (In-short layout)
                (controller as? SmartMainViewController)?.callApiWhenChangeEnterprise()
            }
        }
    }
}
