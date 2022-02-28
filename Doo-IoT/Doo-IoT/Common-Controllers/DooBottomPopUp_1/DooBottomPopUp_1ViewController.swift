//
//  DooBottomPopUp_1ViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooBottomPopUp_1ViewController: CardGenericViewController {
    
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
    
    var selectionData: ((DooBottomPopupGenericDataModel) -> ())? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefault()
        
        // mind change, keep it shown (false)
        self.separatorView.isHidden = false
        
        self.addKeyboardNotifs()
    }
   
    
    func setDefault() {
        labeNavigationDetailTitle.font = UIFont.Poppins.semiBold(18)
        labeNavigationDetailTitle.textColor = UIColor.blueHeading
        labelNavigaitonDetailSubTitle.font = UIFont.Poppins.regular(11.3)
        labelNavigaitonDetailSubTitle.textColor = UIColor.blueHeading
        
        textfieldSearch.addThemeToTextarea(localizeFor("search_placeholder"))
        textfieldSearch.returnKeyType = .done
        textfieldSearch.delegate = self
        
        tableViewValues.dataSource = self
        tableViewValues.delegate = self
        tableViewValues.registerCellNib(identifier: DooTitle_1TVCell.identifier, commonSetting: true)
        tableViewValues.estimatedSectionHeaderHeight = UITableView.automaticDimension
    }
    
    func openCard(dynamicHeight: Bool = true) {
        
        // set true by default
        self.textfieldSearch.isHidden = true
        textfieldSearch.text = ""
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
            if data.count <= 10{
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
        
        // Decision to show search option.
        if self.dooViewModel.dataList.count > 10 {
            self.textfieldSearch.isHidden = false
        }
        
        // if dynamic height require, continue ahead
        guard dynamicHeight else {
            self.baseController?.openCardWithDynamicHeight(CGFloat(totalSpaceWehave))
            return
        }
        
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
            
            var spaceDecided = (heightOfTableViewMustBe + otherSpaceInView)
            if cueDevice.isDeviceXOrGreater {
                spaceDecided += 40
            }
            self.baseController?.openCardWithDynamicHeight(CGFloat(spaceDecided))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

extension DooBottomPopUp_1ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dooViewModel.dataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooTitle_1TVCell.identifier, for: indexPath) as! DooTitle_1TVCell
        let dataModel = self.dooViewModel.dataList[indexPath.row]
        cell.cellConfig(withTitle: dataModel.dataValue)
        cell.viewSeparator.isHidden = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        let dataModel = self.dooViewModel.dataList[selectedIndex]
        self.selectionData?(dataModel)
        self.view.endEditing(true)
        self.baseController?.closeCard()
    }
}

//MARK: - UITextFieldDelegate
extension DooBottomPopUp_1ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.getSearchText(range: range, replacementString: string)
        if searchText.isEmpty {
            dooViewModel.dataList = dooViewModel.dataListAll
        } else {
            dooViewModel.dataList = dooViewModel.dataListAll.filter { (data) -> Bool in
                return data.dataValue.toNSString.localizedStandardContains(searchText)
            }
        }
        tableViewValues.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}


// MARK: Keyboard notifications
extension DooBottomPopUp_1ViewController {
    func addKeyboardNotifs() {
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.constraintBottomTableView.constant = keyboardSize.height - cueSize.bottomHeightOfSafeArea
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.constraintBottomTableView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
}
