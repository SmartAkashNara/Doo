//
//  AddEditBindingRuleViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 20/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class AddEditBindingRuleViewController: CardBaseViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var textFieldViewTrigerApplience: DooTextfieldView!
    @IBOutlet weak var textFieldViewBindingRuleName: DooTextfieldView!
    @IBOutlet weak var textFieldViewTrigerAction: DooTextfieldView!
    @IBOutlet weak var textFieldViewRuleExtTime: DooTextfieldView!
    @IBOutlet weak var textFieldViewConditionComparison: DooTextfieldView!
    @IBOutlet weak var textFieldViewConditionCelsius: DooTextfieldView!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var buttonAddApplience: UIButton!
    @IBOutlet weak var labelApplieneTitle: UILabel!
    @IBOutlet weak var tableViewBindingRuleFormDetail: UITableView!
    @IBOutlet weak var stackViewConditionContainer: UIStackView!
    @IBOutlet weak var imageViewBottomGradient: UIImageView!
    
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableSectionFooterView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var bindingRuleDataModel: SRBindingRuleDataModel? = nil
    private var isEdit:Bool{
        return bindingRuleDataModel == nil ? false : true
    }
    
    private var arrayOfTargetdApplience = [TargetApplianceDataModel]()
    private var addEditBindingRuleViewModel = AddEditBindingRuleViewModel()
    var didAddedOrUpdatedSmartRule:((SRBindingRuleDataModel?)->())? = nil
    private  var bottomTimePickerCard: TimeSelectionBottomViewController? = UIStoryboard.common.timeSelectionBottomVC
    private  var startTime = ""
    private  var endTime = ""
    private  var groupId:Int? = nil
    private  var triggerId:Int? = nil
    private  var selectedApplienceObject:PrivilegeGroupDeviceDataModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        configureTableView()
        loadEditedData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    override func keyboardShown(keyboardHeight: CGFloat, duration: Double) {
        DispatchQueue.getMain {
            UIView.animate(withDuration: duration) {
                self.bottomConstraint.constant = keyboardHeight - cueSize.bottomHeightOfSafeArea + 10
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func keyboardDismissed(keyboardHeight: CGFloat, duration: Double) {
        DispatchQueue.getMain {
            UIView.animate(withDuration: duration) {
                self.bottomConstraint.constant = 25
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension AddEditBindingRuleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfTargetdApplience.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartTargetApplianceTVCell.identifier, for: indexPath) as! SmartTargetApplianceTVCell
        
        cell.cellConfig(dataModel: arrayOfTargetdApplience[indexPath.row])
        cell.separator(hide: true)
        
        cell.buttonEdit.isHidden = false
        cell.setBackgroundCardColor()
        
        cell.buttonEdit.tag = indexPath.row
        cell.buttonEdit.addTarget(self, action: #selector(buttonEditClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    // redirection Target Applience
    @objc func buttonEditClicked(sender:UIButton){
        guard let smartAddTargetVC = UIStoryboard.smart.smartAddTargetVC else { return }
        smartAddTargetVC.isEdit = self.isEdit
        smartAddTargetVC.objTargetApplience = arrayOfTargetdApplience[sender.tag]
        smartAddTargetVC.selectionComplitionsBlock = { [weak self] (selectedtarget) in
            self?.arrayOfTargetdApplience[sender.tag] = selectedtarget
            self?.tableViewBindingRuleFormDetail.reloadData()
        }
        smartAddTargetVC.deleteTargetApplienceComplitionsBlock = { [weak self] (selectedTarget) in
            if let index = self?.arrayOfTargetdApplience.firstIndex(where: {$0.id == selectedTarget.id}){
                self?.arrayOfTargetdApplience.remove(at: index)
                self?.tableViewBindingRuleFormDetail.reloadData()
            }
        }
        self.navigationController?.pushViewController(smartAddTargetVC, animated: true)
    }
}

// MARK: - User defined methods
extension AddEditBindingRuleViewController {
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.stackViewConditionContainer.isHidden = true
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        let title = isEdit ? localizeFor("edit_binding_rule") : localizeFor("add_binding_rule")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        
        labelApplieneTitle.text = localizeFor("target_appliance")
        labelApplieneTitle.font = UIFont.Poppins.medium(13)
        labelApplieneTitle.textColor = UIColor.blueHeading
        
        buttonAddApplience.setTitle(localizeFor("target_appliance"), for: .normal)
        buttonAddApplience.titleLabel?.font = UIFont.Poppins.medium(11)
        buttonAddApplience.setTitleColor(UIColor.blueSwitch, for: .normal)
        
        textFieldViewBindingRuleName.titleValue = localizeFor("binding_rule_name")
        textFieldViewBindingRuleName.textfieldType = .generic
        textFieldViewBindingRuleName.genericTextfield?.addThemeToTextarea(localizeFor("binding_rule_name"))
        textFieldViewBindingRuleName.genericTextfield?.returnKeyType = .done
        textFieldViewBindingRuleName.activeBehaviour = true
        textFieldViewBindingRuleName.genericTextfield?.delegate = self
        textFieldViewBindingRuleName.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Binding rule name is required"
            }
            return nil
        }
        
        textFieldViewTrigerApplience.titleValue = localizeFor("trigger_appliance")
        textFieldViewTrigerApplience.textfieldType = .rightIcon
        textFieldViewTrigerApplience.rightIconTextfield?.addThemeToTextarea(localizeFor("trigger_appliance"))
        textFieldViewTrigerApplience.rightIconTextfield?.returnKeyType = .done
        textFieldViewTrigerApplience.rightIconTextfield?.clearButtonMode = .whileEditing
        textFieldViewTrigerApplience.rightIconTextfield?.delegate = self
        textFieldViewTrigerApplience.activeBehaviour = true
        textFieldViewTrigerApplience.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "imgDropDownArrow")
        textFieldViewTrigerApplience.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Trigger appliance is required"
            }
            return nil
        }
        
        textFieldViewTrigerAction.titleValue = localizeFor("trigger_action")
        textFieldViewTrigerAction.textfieldType = .rightIcon
        textFieldViewTrigerAction.rightIconTextfield?.addThemeToTextarea(localizeFor("trigger_action"))
        textFieldViewTrigerAction.rightIconTextfield?.returnKeyType = .done
        textFieldViewTrigerAction.activeBehaviour = true
        textFieldViewTrigerAction.rightIconTextfield?.delegate = self
        textFieldViewTrigerAction.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "imgDropDownArrow")
        textFieldViewTrigerAction.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Trigger action is required"
            }
            return nil
        }
        
        textFieldViewConditionComparison.titleValue = localizeFor("condition")
        textFieldViewConditionComparison.textfieldType = .rightIcon
        textFieldViewConditionComparison.rightIconTextfield?.addThemeToTextarea(localizeFor("condition"))
        textFieldViewConditionComparison.rightIconTextfield?.returnKeyType = .done
        textFieldViewConditionComparison.activeBehaviour = true
        textFieldViewConditionComparison.rightIconTextfield?.delegate = self
        textFieldViewConditionComparison.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "imgDropDownArrow")
        textFieldViewConditionComparison.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField) && self.addEditBindingRuleViewModel.currentSelectedAction == .compare{
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Condition is required"
            }
            return nil
        }
        
        textFieldViewConditionCelsius.titleValue = "ee"
        textFieldViewConditionCelsius.titleColor = UIColor.clear
        textFieldViewConditionCelsius.textfieldType = .generic
        textFieldViewConditionCelsius.genericTextfield?.addThemeToTextarea(localizeFor("40 C"))
        textFieldViewConditionCelsius.genericTextfield?.returnKeyType = .done
        textFieldViewConditionCelsius.activeBehaviour = false
        textFieldViewConditionCelsius.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField) && self.addEditBindingRuleViewModel.currentSelectedAction == .compare{
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Celsius is required"
            }
            return nil
        }
        
        textFieldViewRuleExtTime.titleValue = localizeFor("rule_execution_time")
        textFieldViewRuleExtTime.textfieldType = .rightIcon
        textFieldViewRuleExtTime.rightIconTextfield?.addThemeToTextarea(localizeFor("rule_execution_time"))
        textFieldViewRuleExtTime.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "watch")
        textFieldViewRuleExtTime.activeBehaviour = true
        textFieldViewRuleExtTime.rightIconTextfield?.delegate = self
        textFieldViewRuleExtTime.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Time is required"
            }
            return nil
        }
        
        //set button type Custom from storyboard
        buttonSubmit.setThemeAppBlueWithArrow(localizeFor(isEdit ? "update_button" : "save_button"))
        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")
    }
    
    // load data while editing flow
    func loadEditedData(){
        if let dataModel = bindingRuleDataModel {
            
            self.startTime = dataModel.startTime
            self.endTime = dataModel.endTime
            self.triggerId = dataModel.triggerId
            /*
             if let action = addEditBindingRuleViewModel.currentSelectedAction?.rawValue{
             param["triggerAction"] = action
             }
             
             if let condition = textFieldViewConditionCelsius.getText, !condition.isEmpty{
             param["conditionValue"] = condition
             }
             
             if let condition = addEditBindingRuleViewModel.currentSelectedCondition?.rawValue{
             param["triggerCondition"] = condition
             }*/
            
            textFieldViewRuleExtTime.setText = dataModel.fullTime
            textFieldViewBindingRuleName.setText = dataModel.bindingRuleName
            textFieldViewTrigerAction.setText = dataModel.objEnumTriggerAction.title
            textFieldViewTrigerApplience.setText = dataModel.triggerName
            
            self.addEditBindingRuleViewModel.currentSelectedAction = dataModel.objEnumTriggerAction
            if self.addEditBindingRuleViewModel.currentSelectedAction == .compare{
                self.stackViewConditionContainer.isHidden = false
                self.textFieldViewConditionComparison.setText = dataModel.objEnumConditionAction.title
            }else{
                self.stackViewConditionContainer.isHidden = true
            }
            arrayOfTargetdApplience = dataModel.arrayTargetApplience
            self.tableViewBindingRuleFormDetail.reloadData()
        }
    }
    
    func configureTableView() {
        tableViewBindingRuleFormDetail.autolayoutTableViewHeader = tableHeaderView
        tableViewBindingRuleFormDetail.autolayoutTableViewFooterHeader = tableSectionFooterView
        tableViewBindingRuleFormDetail.dataSource = self
        tableViewBindingRuleFormDetail.delegate = self
        tableViewBindingRuleFormDetail.registerCellNib(identifier: SmartTargetApplianceTVCell.identifier, commonSetting: true)
    }
    
    func sizeHeaderToFit() {
        let headerView = tableViewBindingRuleFormDetail.tableHeaderView!
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableViewBindingRuleFormDetail.tableHeaderView = headerView
    }
    
    func isValidateFields() -> Bool {
        if textFieldViewBindingRuleName.isValidated() && textFieldViewTrigerApplience.isValidated() && textFieldViewTrigerAction.isValidated() && textFieldViewConditionCelsius.isValidated() && textFieldViewConditionComparison.isValidated() && textFieldViewRuleExtTime.isValidated(){
            if arrayOfTargetdApplience.count == 0{
                CustomAlertView.init(title: "Select Target Appliance").showForWhile(animated: true)
                return true
            }
            return true
        }
        return false
    }
}

// MARK: - Actions listeners
extension AddEditBindingRuleViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if SMARTRULE_OFFLINE_LOAD_ENABLE {
            if isEdit {
                self.callOfflineData(msg: "Updated binding rule",ispopVC: true)
            } else {
                self.callOfflineData(msg: "Added binding rule",ispopVC: true)
            }
        } else {
            if isValidateFields() {
                if isEdit {
                    callUpdateBindingRuleAPI()
                } else {
                    callAddBindingRuleAPI()
                }
            }
        }
    }
    
    @IBAction func addApplienceClicked(sender:UIButton){
        guard let smartAddTargetVC = UIStoryboard.smart.smartAddTargetVC else { return }
        smartAddTargetVC.selectedApplienceObject = self.selectedApplienceObject
        smartAddTargetVC.selectionComplitionsBlock = { [weak self] (selectedtarget) in
            self?.arrayOfTargetdApplience.append(selectedtarget)
            self?.tableViewBindingRuleFormDetail.reloadData()
        }
        self.navigationController?.pushViewController(smartAddTargetVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddEditBindingRuleViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewTrigerApplience.rightIconTextfield:
            if let privilegesVC = UIStoryboard.enterpriseUsers.userPrivilegesVC {
                if let groupsId = self.groupId, let devicesId = self.triggerId, let applinceId = selectedApplienceObject?.dataId{
                    privilegesVC.redirectedFrom = .applienceSelectionForSmartRule(groupsId, devicesId, applinceId)
                }else{
                    privilegesVC.redirectedFrom = .applienceSelectionForSmartRule(nil, nil, nil)
                }
                privilegesVC.callBackWithSelectedData = { (parentNode, deviceNode, childNode) in
                    if let nodeParent = parentNode{
                        self.groupId = nodeParent.dataId
                    }
                    
                    if let nodeDevice = deviceNode{
                        self.triggerId = nodeDevice.dataId
                    }
                    
                    if let nodeChild = childNode{
                        self.textFieldViewTrigerApplience.setText = nodeChild.title
                        self.selectedApplienceObject = nodeChild
                        self.textFieldViewTrigerApplience.dismissError()
                    }
                }
                self.navigationController?.pushViewController(privilegesVC, animated: true)
            }
            
            return false
        case textFieldViewTrigerAction.rightIconTextfield:
            guard let bottomCard = UIStoryboard.common.dooBottomPopUp_NoPullDissmiss_VC else {
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
                return false
            }
            bottomCard.modalPresentationStyle = .overFullScreen
            bottomCard.selectionType = .smartRuleAction(self.addEditBindingRuleViewModel.listOfActions)
            bottomCard.selectionData = { [weak self] (dataModel) in
                self?.textFieldViewTrigerAction.setText = dataModel.dataValue
                self?.textFieldViewTrigerAction.dismissError()
                self?.addEditBindingRuleViewModel.currentSelectedAction = EnumTriggerAction.init(rawValue: Int(dataModel.dataId) ?? 0)
                if self?.addEditBindingRuleViewModel.currentSelectedAction == .compare{
                    self?.stackViewConditionContainer.isHidden = false
                }else{
                    self?.stackViewConditionContainer.isHidden = true
                }
                self?.sizeHeaderToFit()
                self?.tableViewBindingRuleFormDetail.reloadData()
            }
            self.present(bottomCard, animated: true, completion: nil)
            return false
        case textFieldViewConditionComparison.rightIconTextfield:
            
            guard let bottomCard = UIStoryboard.common.dooBottomPopUp_NoPullDissmiss_VC else {
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
                return false
            }
            bottomCard.modalPresentationStyle = .overFullScreen
            bottomCard.selectionType = .smartRuleCondition(self.addEditBindingRuleViewModel.listOfCondition)
            bottomCard.selectionData = { [weak self] (dataModel) in
                self?.textFieldViewConditionComparison.setText = dataModel.dataValue
                self?.textFieldViewConditionComparison.dismissError()
                self?.addEditBindingRuleViewModel.currentSelectedCondition = SRBindingRuleDataModel.EnumConditionAction.init(rawValue: Int(dataModel.dataId) ?? 0)
            }
            self.present(bottomCard, animated: true, completion: nil)
            return false
        case textFieldViewRuleExtTime.rightIconTextfield:
            if let bottomView = self.bottomTimePickerCard {
                bottomView.modalPresentationStyle = .overFullScreen
                bottomView.timeSelected = { (firstTime, secondTime) in
                    var finalStartEnd = ""
                    let startTime = firstTime.getDateInString(withFormat: .timeWithAMPM)
                    
                    finalStartEnd = startTime
                    if let endTIme = secondTime{
                        let strEndTime = endTIme.getDateInString(withFormat: .timeWithAMPM)
                        finalStartEnd = startTime+" - "+strEndTime
                        self.startTime = startTime
                        self.endTime = strEndTime
                    }
                    self.textFieldViewRuleExtTime.dismissError()
                    self.textFieldViewRuleExtTime.setText = finalStartEnd
                }
                self.present(bottomView, animated: true, completion: nil)
            }else{
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
            }
            return false
        default:
            break
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddEditBindingRuleViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Services
extension AddEditBindingRuleViewController {
    // add binding rule
    func callAddBindingRuleAPI() {
        guard let name = textFieldViewBindingRuleName.getText else { return }
        var param: [String: Any] = [
            "name": name,
            "triggerId":triggerId ?? 0,
            "startTime": self.startTime,
            "endTime": self.endTime
        ]
        
        if let action = addEditBindingRuleViewModel.currentSelectedAction?.rawValue{
            param["triggerAction"] = action
        }
        
        if let condition = textFieldViewConditionCelsius.getText, !condition.isEmpty{
            param["conditionValue"] = condition
        }
        
        if let condition = addEditBindingRuleViewModel.currentSelectedCondition?.rawValue{
            param["triggerCondition"] = condition
        }
        
        if arrayOfTargetdApplience.count != 0{
            let arrayOfDict = arrayOfTargetdApplience.map({$0.getJsonObject})
            param["appliances"] = arrayOfDict
        }
        
        DooAPILoader.shared.startLoading()
        addEditBindingRuleViewModel.callAddBindingRuleAPI(param: param) { [weak self] (msg, dataModel) in
            DooAPILoader.shared.stopLoading()
            CustomAlertView.init(title: msg , forPurpose: .success).showForWhile(animated: true)
            self?.didAddedOrUpdatedSmartRule?(dataModel)
            self?.navigationController?.popViewController(animated: true)
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
            //            debugPrint(msg)
        } failureInform: {
            DooAPILoader.shared.stopLoading()
        }
    }
    
    // Update ninding rule
    func callUpdateBindingRuleAPI() {
        
        guard let name = textFieldViewBindingRuleName.getText else { return }
        var param: [String: Any] = [
            "name": name,
            "triggerId":triggerId ?? 0,
            "startTime": self.startTime,
            "endTime": self.endTime,
            "id":bindingRuleDataModel?.id ?? 0
        ]
        
        if let action = addEditBindingRuleViewModel.currentSelectedAction?.rawValue{
            param["triggerAction"] = action
        }
        
        if let condition = textFieldViewConditionCelsius.getText, !condition.isEmpty{
            param["conditionValue"] = condition
        }
        
        if let condition = addEditBindingRuleViewModel.currentSelectedCondition?.rawValue{
            param["triggerCondition"] = condition
        }
        
        if arrayOfTargetdApplience.count != 0{
            let arrayOfDict = arrayOfTargetdApplience.map({$0.getJsonObject})
            param["appliances"] = arrayOfDict
        }
        
        DooAPILoader.shared.startLoading()
        addEditBindingRuleViewModel.callUpdateBindingRuleAPI(param: param) { [weak self] (msg, dataModel) in
            DooAPILoader.shared.stopLoading()
            CustomAlertView.init(title: msg , forPurpose: .success).showForWhile(animated: true)
            self?.didAddedOrUpdatedSmartRule?(dataModel)
            self?.navigationController?.popViewController(animated: true)
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
            //            debugPrint(msg)
        } failureInform: {
            DooAPILoader.shared.stopLoading()
        }
    }
}

// Temp code did for testing letter remove
extension UIViewController{
    func callOfflineData(msg:String, ispopVC:Bool=false){
        if SMARTRULE_OFFLINE_LOAD_ENABLE{
            self.view.makeToast(msg)
            if ispopVC {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
    }
}
