//
//  EnterpriseTopMenuViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class EnterpriseTopMenuViewController: CardGenericViewController {

    @IBOutlet weak var toplayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labeNavigationDetailTitle: UILabel!
    @IBOutlet weak var labelNavigaitonDetailSubTitle: UILabel!
    @IBOutlet weak var buttonAddEnterprise: UIButton!
    @IBOutlet weak var buttonManageEnterprise: UIButton!
    
    @IBOutlet weak var enterpriseTableView: UITableView!
    var enterpriseChanged: ((Int) -> ())? = nil
    var manageEnterpriseOptionTapped: (() -> ())? = nil
    var addEnterpriseOptionTapped: (() -> ())? = nil
    
    var selectedEnterpriseDataModel: EnterpriseModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultTheme()
        configureTableView()
    }
    
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
    
    func openCard() {
        // open card from card base
        self.enterpriseTableView.reloadData()
        
        // calculate height of top layout
        let totalDeviceHeight: Int = Int(UIScreen.main.bounds.size.height)
        let statusBarHeight = cueDevice.isDeviceXOrGreater ? 44 : 20
        let bottomOffsetHeight = cueDevice.isDeviceXOrGreater ? 83 : 49 // 83 = 34 (Bottom Activity Indicator) + 49 (Tabbar)
        let totalSpaceWehave = totalDeviceHeight - (statusBarHeight + bottomOffsetHeight)
        let tableViewSpaceWeHave = totalSpaceWehave - 126 // 76 for top + 50 for bottom space.
        let contentSizeOfTableView = 60 * ENTERPRISE_LIST.count
        
        // if we have more tableview space than required. make tableview scrollable to false.
        let minSpace = min(tableViewSpaceWeHave, contentSizeOfTableView)
        let spaceDecided = (minSpace + statusBarHeight + 126)
        
        // Layout settings
        self.toplayoutConstraint.constant = CGFloat(statusBarHeight)
        if tableViewSpaceWeHave > contentSizeOfTableView {
            self.enterpriseTableView.isScrollEnabled = false
        }else{
            self.enterpriseTableView.isScrollEnabled = true
        }
        
        self.baseTabbarController?.openCardWithDynamicHeight(CGFloat(spaceDecided))
    }
    
    @IBAction func manageEnterpriseTapped(sender: UIButton) {
        self.baseTabbarController?.closeCard()
        self.manageEnterpriseOptionTapped?()
    }
    
    @IBAction func addEnterpriseTapped(sender: UIButton) {
        self.baseTabbarController?.closeCard()
        self.addEnterpriseOptionTapped?()
    }
    
    func resetEnterpriseList() {
        self.enterpriseTableView.reloadData()
    }
}

// MARK: - User defined methods
extension EnterpriseTopMenuViewController {
    func configureTableView() {
        enterpriseTableView.dataSource = self
        enterpriseTableView.registerCellNib(identifier: EnterpriseTitleTVCell.identifier, commonSetting: true)
    }
    
}

extension EnterpriseTopMenuViewController: UITableViewDataSource {
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
        self.enterpriseTableView.reloadData()
        DispatchQueue.getMain{
            NotificationCenter.default.post(name: Notification.Name("changedEnterpise"), object: nil)            
        }
        (TABBAR_INSTANCE as? DooTabbarViewController)?.refreshAllViewsOfTabsWhenEnterpriseChanges() // refresh tab views

        DispatchQueue.getMain(delay: 0.1) { [weak self] in
            self?.baseTabbarController?.closeCard()
        }
    }
}
