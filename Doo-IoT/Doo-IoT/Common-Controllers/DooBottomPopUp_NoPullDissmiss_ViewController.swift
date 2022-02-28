//
//  DooBottomPopUp_NoPullDissmiss_ViewController.swift
//  Doo-IoT
//
//  Created by Akash on 10/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class DooBottomPopUp_NoPullDissmiss_ViewController: UIViewController {
    
    enum SelectionType {
        case typeOfEnterprise([DooBottomPopupGenericDataModel]),
             roleSelectionToInviteUser([DooBottomPopupGenericDataModel]),
             gateways([DooBottomPopupGenericDataModel]),
             applianceTypes([DooBottomPopupGenericDataModel]),
             smartRuleAction([DooBottomPopupGenericDataModel]),
             smartRuleCondition([DooBottomPopupGenericDataModel]),
             smartSpeedLevel([DooBottomPopupGenericDataModel]),
             none
        
        func getTitle() -> String {
            switch self {
            case .typeOfEnterprise(_):
                return localizeFor("type_of_enterprise")
            case .roleSelectionToInviteUser(_):
                return localizeFor("select_role")
            case .gateways(_):
                return localizeFor("gateway_list_popup_title")
            case .applianceTypes(_):
                return localizeFor("appliance_type_list_popup_title")
            case .smartRuleAction(_):
                return localizeFor("quick_actions")
            case .smartRuleCondition(_):
                return localizeFor("comparison")
            case .smartSpeedLevel(_):
                return localizeFor("speed_level")
            default: return "--"
            }
        }
        
        func getSubTitle() -> String {
            switch self {
            case .typeOfEnterprise(_):
                return localizeFor("type_of_enterprise_subtitle")
            case .roleSelectionToInviteUser(_):
                return localizeFor("select_role_menu_title")
            case .gateways(_):
                return localizeFor("gateway_list_popup_subtitle")
            case .applianceTypes(_):
                return localizeFor("appliance_type_list_popup_subtitle")
            case .smartRuleAction(_):
                return localizeFor("appliance_type_list_popup_subtitle")
            case .smartRuleCondition(_):
                return localizeFor("Here_you_can_select_type_comparison")
            case .smartSpeedLevel(_):
                return localizeFor("Here_you_can_select_type_comparison")
            default: return "-"
            }
        }
    }
    var selectionType: SelectionType = .none
    var dooViewModel: DooBottomPopUp_1ViewModel = DooBottomPopUp_1ViewModel()
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var labeNavigationDetailTitle: UILabel!
    @IBOutlet weak var labelNavigaitonDetailSubTitle: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var textfieldSearch: GenericTextField!
    @IBOutlet weak var tableViewValues: UITableView!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var constraintHeightTableView: NSLayoutConstraint!
    
    var selectionData: ((DooBottomPopupGenericDataModel) -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefault()
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 0.3) {
            self.constraintBottomTableView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func setDefault() {
        labeNavigationDetailTitle.font = UIFont.Poppins.semiBold(18)
        labeNavigationDetailTitle.textColor = UIColor.blueHeading
        labelNavigaitonDetailSubTitle.font = UIFont.Poppins.regular(11.3)
        labelNavigaitonDetailSubTitle.textColor = UIColor.blueHeadingAlpha60
        
        separatorView.backgroundColor = UIColor.blueHeadingAlpha06
        tableViewValues.dataSource = self
        tableViewValues.delegate = self
        tableViewValues.registerCellNib(identifier: DooTitle_1TVCell.identifier, commonSetting: true)
        tableViewValues.estimatedSectionHeaderHeight = UITableView.automaticDimension
        
        self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainView.layer.cornerRadius = 10.0
        
        // remove view when blank area gonna be tapped.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissViewTapGesture(tapGesture:)))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        
        self.labeNavigationDetailTitle.text = self.selectionType.getTitle()
        self.labelNavigaitonDetailSubTitle.text = self.selectionType.getSubTitle()
        
        // assign data:
        func setData(_ data: [DooBottomPopupGenericDataModel]) {
            self.dooViewModel.dataList = data
            self.dooViewModel.dataListAll = data
            self.tableViewValues.reloadData()
        }
        
        switch self.selectionType {
        case .typeOfEnterprise(let data):
            
            if data.count >= 10{
                textfieldSearch.isHidden = true
            }else{
                textfieldSearch.isHidden = false
            }
            setData(data)
        case .roleSelectionToInviteUser(let data):
            setData(data)
        case .smartRuleAction(let data):
            setData(data)
        case .smartRuleCondition(let data):
            setData(data)
            
        case .smartSpeedLevel(let data):
            setData(data)
        case .gateways(let data):
            setData(data)
        case .applianceTypes(let data):
            setData(data)
        case .none: return
        }
        
        // calculate height of top layout
        let totalDeviceHeight: Double = Double(UIScreen.main.bounds.size.height)
        let statusBarHeight = cueDevice.isDeviceXOrGreater ? 44.0 : 20.0
        let bottomOffsetHeight = cueDevice.isDeviceXOrGreater ? 83.0 : 49.0 // 83 = 34 (Bottom Activity Indicator) + 49 (Tabbar)
        let totalSpaceWehave = totalDeviceHeight - (statusBarHeight + bottomOffsetHeight)
        
        
        DispatchQueue.getMain(delay: 0.1) {
            var otherSpaceInView = Double(self.topStackView.bounds.size.height + 34.0) // 118.5 (for top title, subtitle and search stack) - above (46.9), plus 26 (top space), plus 8 (space between tableview and topview)
            let tableViewSpaceWeHave = totalSpaceWehave - otherSpaceInView
            
            let heightOfTableView = Double(self.tableViewValues.contentSize.height)
            let heightOfTableViewMustBe = min(heightOfTableView, tableViewSpaceWeHave)
            if heightOfTableViewMustBe < tableViewSpaceWeHave {
                // to keep some space at bottom
                otherSpaceInView += 16
                self.tableViewValues.isScrollEnabled = false
            }else{
                self.tableViewValues.isScrollEnabled = true
            }
            
            self.constraintHeightTableView.constant = CGFloat(heightOfTableViewMustBe)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension DooBottomPopUp_NoPullDissmiss_ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dooViewModel.dataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooTitle_1TVCell.identifier, for: indexPath) as! DooTitle_1TVCell
        let dataModel = self.dooViewModel.dataList[indexPath.row]
        cell.cellConfig(withTitle: dataModel.dataValue)
        cell.constraintSetupBottomView()
        cell.viewSeparator.isHidden = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        let dataModel = self.dooViewModel.dataList[selectedIndex]
        self.selectionData?(dataModel)
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
