//
//  EnterpriseTopLayoutViewController.swift
//  Doo-IoT
//
//  Created by smartsense-kiran on 23/09/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class EnterpriseTopLayoutViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var totalHeightOfMainView: NSLayoutConstraint!
    @IBOutlet weak var constraintOfTopToShowViewUpAndDown: NSLayoutConstraint!
    @IBOutlet weak var constraintOfStatusBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var labeNavigationDetailTitle: UILabel!
    @IBOutlet weak var labelNavigaitonDetailSubTitle: UILabel!
    @IBOutlet weak var buttonAddEnterprise: UIButton!
    @IBOutlet weak var viewOfManageEnterpriseOption: UIView!
    @IBOutlet weak var buttonManageEnterprise: UIButton!
    @IBOutlet weak var enterpriseTableView: UITableView!
    
    var enterpriseChanged: ((Int) -> ())? = nil
    var manageEnterpriseOptionTapped: (() -> ())? = nil
    var addEnterpriseOptionTapped: (() -> ())? = nil
    
    var selectedEnterpriseDataModel: EnterpriseModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animation Work....
        self.constraintOfTopToShowViewUpAndDown.constant = -UIScreen.main.bounds.size.height // default
        self.mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.mainView.layer.cornerRadius = 10.0
        if cueDevice.isDeviceXOrGreater {
            self.constraintOfStatusBarHeight.constant = 34
        }else{
            self.constraintOfStatusBarHeight.constant = 20
        }
        
        // remove view when blank area gonna be tapped.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissViewTapGesture(tapGesture:)))
        backgroundView.addGestureRecognizer(tapGesture)
        
        // Extra work....
        self.defaultTheme()
        self.configureTableView()
        self.addingSwipeUpGestureToCloseLayoutUponManageEnterpriseView()
        
        self.enterpriseTableView.reloadData() // load
    }
    
    func openCard() {
        self.setDynamicHeight()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.2) {
                self.constraintOfTopToShowViewUpAndDown.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func closeCard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: false, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            UIView.animate(withDuration: 0.2) {
                if self.constraintOfTopToShowViewUpAndDown != nil{
                    self.constraintOfTopToShowViewUpAndDown.constant = -UIScreen.main.bounds.size.height
                    self.view.layoutIfNeeded()                    
                }
            }
        }
    }
    
    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.closeCard()
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

extension EnterpriseTopLayoutViewController {
    func defaultTheme() {
        self.labeNavigationDetailTitle.text = localizeFor("enterprises")
        self.labeNavigationDetailTitle.font = UIFont.Poppins.semiBold(18)
        self.labeNavigationDetailTitle.textColor = UIColor.blueHeading

        self.labelNavigaitonDetailSubTitle.text = localizeFor("enterprise_top_menu_subtitle")
        self.labelNavigaitonDetailSubTitle.font = UIFont.Poppins.regular(11.3)
        self.labelNavigaitonDetailSubTitle.textColor = UIColor.blueHeading
        
        self.buttonManageEnterprise.titleLabel?.font = UIFont.Poppins.semiBold(11.3)
        self.buttonManageEnterprise.setTitleColor(UIColor.blueSwitch, for: .normal)
    }
}

extension EnterpriseTopLayoutViewController {
    func addingSwipeUpGestureToCloseLayoutUponManageEnterpriseView() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
            case .down:
                print("Swiped down")
            case .left:
                print("Swiped left")
            case .up:
                print("Swiped up")
                self.closeCard()
            default:
                break
            }
        }
    }
}

extension EnterpriseTopLayoutViewController {
    @IBAction func manageEnterpriseTapped(sender: UIButton) {
        self.closeCard()
        self.manageEnterpriseOptionTapped?()
    }
    
    @IBAction func addEnterpriseTapped(sender: UIButton) {
        self.closeCard()
        self.addEnterpriseOptionTapped?()
    }
}


// MARK: - User defined methods
extension EnterpriseTopLayoutViewController {
    func configureTableView() {
        enterpriseTableView.dataSource = self
        enterpriseTableView.registerCellNib(identifier: EnterpriseTitleTVCell.identifier, commonSetting: true)
    }
    func resetEnterpriseList() {
        if self.enterpriseTableView != nil {
            self.enterpriseTableView.reloadData()
        }
    }
    func setDynamicHeight() {
        // height of status bar - self.constraintOfStatusBarHeight.constant
        // 76 for top
        // 50 for bottom
        self.enterpriseTableView.reloadData()
        self.enterpriseTableView.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let restHeight = self.constraintOfStatusBarHeight.constant + 126
            // (ENTERPRISE_LIST.count * 60) height of tableview.
            let totalPopupHeight = CGFloat(ENTERPRISE_LIST.count * 60) + restHeight
            
            var gapToBeKept: CGFloat = 0
            if cueDevice.isDeviceXOrGreater {
                // considered bottom indicator
                gapToBeKept = (UIScreen.main.bounds.size.height - 84)
            }else{
                gapToBeKept = (UIScreen.main.bounds.size.height - 50)
            }
            if totalPopupHeight > gapToBeKept {
                self.totalHeightOfMainView.constant = gapToBeKept
                self.enterpriseTableView.isScrollEnabled = true
            }else{
                self.totalHeightOfMainView.constant = totalPopupHeight
                self.enterpriseTableView.isScrollEnabled = false
            }
        }
    }
}

extension EnterpriseTopLayoutViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ENTERPRISE_LIST.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EnterpriseTitleTVCell.identifier, for: indexPath) as! EnterpriseTitleTVCell
        let enterprise = ENTERPRISE_LIST[indexPath.row]
        if let user = APP_USER, enterprise.id == user.userSelectedEnterpriseID {
            cell.entepriseCellConfig(cellType: .selectedTopRightTick, data: ENTERPRISE_LIST[indexPath.row])
            self.selectedEnterpriseDataModel = enterprise
        }else{
            cell.entepriseCellConfig(cellType: .plain, data: ENTERPRISE_LIST[indexPath.row])
        }
        cell.controlMain.tag = indexPath.row
        cell.controlMain.addTarget(self, action: #selector(setNewEnterpriseIfItsNotTheCurrentSelectedOne(_:)), for: .touchUpInside)
        return cell
    }
    
    // New enterprise been selected.
    @objc func setNewEnterpriseIfItsNotTheCurrentSelectedOne(_ sender: UIControl) {
        if ENTERPRISE_LIST.indices.contains(sender.tag) {
            let enterprise = ENTERPRISE_LIST[sender.tag]
            if self.selectedEnterpriseDataModel != enterprise {
                callSwitchEnterpriseAPI(enterprise, atIndex: sender.tag)
                print("\(enterprise.name) tapped")
            }
        }
    }
    
    // API to switch to new enterprise.
    func callSwitchEnterpriseAPI(_ enterprise: EnterpriseModel, atIndex index: Int) {
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .switchEnterprise(["enterpriseId": enterprise.id])) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            self.switchEnterpriseInUserObject(enterprise, atIndex: index)
        }
    }
    
    // Set new enterprise in User object.
    func switchEnterpriseInUserObject(_ enterprise: EnterpriseModel, atIndex index: Int) {
        if let user = APP_USER {
            user.selectedEnterprise = enterprise
        }
        
        // inform others.
        self.enterpriseChanged?(index)
        if self.enterpriseTableView != nil{
            self.enterpriseTableView.reloadData()            
        }
        DispatchQueue.getMain{
            NotificationCenter.default.post(name: Notification.Name("changedEnterpise"), object: nil)
        }
        (TABBAR_INSTANCE as? DooTabbarViewController)?.refreshAllViewsOfTabsWhenEnterpriseChanges() // refresh tab views

        DispatchQueue.getMain(delay: 0.1) { [weak self] in
            self?.closeCard()
        }
    }
}
