//
//  SmartAddTargetViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 29/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class SmartAddTargetViewController: CardBaseViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomGradient: UIImageView!
    
    @IBOutlet weak var textFieldViewTargetAppName: DooTextfieldView!
    @IBOutlet weak var viewToTargetAccess: TargetAccessSegment!
    @IBOutlet weak var textFieldViewTargetAction: DooTextfieldView!
    @IBOutlet weak var textFieldViewTargetRGB: DooTextfieldView!
    @IBOutlet weak var textFieldViewTargetFan: DooTextfieldView!
    @IBOutlet weak var buttonDelete: UIButton!
    
    
    var isEdit = false
    var selectionComplitionsBlock: ((TargetApplianceDataModel) -> ())? = nil
    var deleteTargetApplienceComplitionsBlock: ((TargetApplianceDataModel) -> ())? = nil
    var smartAddTargetViewModel = SmartAddTargetViewModel()
    
    private var targetAction = 0 // for 1,2,3 onoff, fan, rgb
    private var targetAccess = 2 // enable disable, na
    private var targetvalue = 0 // on, off, na
    private var targetFanSpeed:Int? = nil
    var groupId:Int? = nil
    var selectedApplianceId:Int? = nil
    
    var selectedApplienceObject: PrivilegeGroupDeviceDataModel? = nil
    var objTargetApplience:TargetApplianceDataModel? = nil
    var applianceImage: String = ""
    var selectedApplianceDeviceName: String = ""
    var enumApplieceType :EnumApplianceAction{
        return EnumApplianceAction.init(rawValue: targetAction) ?? .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        loadData()
    }
    
    func setTargetAccessApplienceValueFromId(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewToTargetAccess.setTargetSegment(value: EnumTargetAccess.init(rawValue: self.targetAccess)?.indexValue ?? 0)
        }
    }
}

// MARK: - Actions listeners
extension SmartAddTargetViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitActionListener(_ sender: UIButton) {
        view.endEditing(true)
        
        if isValidateFields() {
            let obTargetApp = TargetApplianceDataModel(param: [:])
            obTargetApp.targetAction = targetAction
            obTargetApp.targetAccess = targetAccess
            obTargetApp.applianceId = selectedApplianceId ?? 0
            obTargetApp.applianceName = textFieldViewTargetAppName.getText ?? ""
            obTargetApp.applianceImage = self.applianceImage
            obTargetApp.deviceName = self.selectedApplianceDeviceName
            obTargetApp.targetValue = targetvalue
            obTargetApp.enumApplianceAction = EnumApplianceAction.init(rawValue: targetAction) ?? .none
            obTargetApp.operationsArray = selectedApplienceObject?.arrayOprationSupported ?? []
            if obTargetApp.enumApplianceAction == .rgb{
                obTargetApp.setColorFromDecimalColorCode()
            }
            if isEdit {
                selectionComplitionsBlock?(obTargetApp)
                self.navigationController?.popViewController(animated: true)
            } else {
                selectionComplitionsBlock?(obTargetApp)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func buttonDeleteActionListener(_ sender: UIButton) {
        print("buttonDeleteActionListener")
        guard let targetDataModelObject  = objTargetApplience else {
            return
        }
        deleteTargetApplienceComplitionsBlock?(targetDataModelObject)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - User defined methods
extension SmartAddTargetViewController {
    // Card Work
    func setLayout(withCard cardVC: CardGenericViewController, cardPosition: CardPosition) {
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
    
    func setDefaults() {
        
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        let title = isEdit ? localizeFor("edit_target_appliance") : localizeFor("addTarget_appliance")
        navigationTitle.text = title
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        
        textFieldViewTargetAppName.titleValue = "Target Appliance"
        textFieldViewTargetAppName.textfieldType = .rightIcon
        textFieldViewTargetAppName.rightIconTextfield?.addThemeToTextarea("Select Target Appliance")
        textFieldViewTargetAppName.rightIconTextfield?.returnKeyType = .done
        textFieldViewTargetAppName.rightIconTextfield?.clearButtonMode = .whileEditing
        textFieldViewTargetAppName.rightIconTextfield?.delegate = self
        textFieldViewTargetAppName.activeBehaviour = true
        textFieldViewTargetAppName.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "imgDropDownArrow")
        textFieldViewTargetAppName.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Target appliance is required"
            }
            return nil
        }
        
        // Segment
        viewToTargetAccess.titleValue = localizeFor("target_access")
        viewToTargetAccess.segmentValues = ["N/A", "Enable", "Disable"]
        viewToTargetAccess.segmentNotes = ["It will keep the Target appliance in same state!",
                                           "It will enable the Target appliance after selection.",
                                           "It will disable the Target appliance after selection."]
        self.setTargetAccessApplienceValueFromId()
        viewToTargetAccess.selectedValue = { value in
            debugPrint("Selected value: \(value)")
            self.targetAccess = self.checkTargetAccessBasedOnSegmentIndex(segmentIndex: value) // here pass enable, disable, na
            self.enableDisableSaveButton()
        }
        
        textFieldViewTargetAction.titleValue = localizeFor("target_action")
        textFieldViewTargetAction.textfieldType = .rightIcon
        textFieldViewTargetAction.rightIconTextfield?.addThemeToTextarea(localizeFor("select_target_action"))
        textFieldViewTargetAction.rightIconTextfield?.returnKeyType = .done
        textFieldViewTargetAction.activeBehaviour = true
        textFieldViewTargetAction.rightIconTextfield?.delegate = self
        textFieldViewTargetAction.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "imgDropDownArrow")
        textFieldViewTargetAction.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField) && self.enumApplieceType == .onOff{
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Target action is required"
            }
            return nil
        }
        
        textFieldViewTargetRGB.titleValue = localizeFor("color_picker")
        textFieldViewTargetRGB.textfieldType = .rightIcon
        textFieldViewTargetRGB.rightIconTextfield?.addThemeToTextarea(localizeFor("color_picker"))
        textFieldViewTargetRGB.rightIconTextfield?.returnKeyType = .done
        textFieldViewTargetRGB.activeBehaviour = true
        textFieldViewTargetRGB.rightIconTextfield?.delegate = self
        textFieldViewTargetRGB.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "rgbColorIcon")
        textFieldViewTargetRGB.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField) && !self.textFieldViewTargetRGB.isHidden && self.enumApplieceType == .rgb{
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Color picker selection is required"
            }
            return nil
        }
        
        textFieldViewTargetFan.titleValue = localizeFor("speed")
        textFieldViewTargetFan.textfieldType = .rightIcon
        textFieldViewTargetFan.rightIconTextfield?.addThemeToTextarea(localizeFor("speed"))
        textFieldViewTargetFan.rightIconTextfield?.returnKeyType = .done
        textFieldViewTargetFan.activeBehaviour = true
        textFieldViewTargetFan.rightIconTextfield?.delegate = self
        textFieldViewTargetFan.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "imgDropDownArrow")
        
        textFieldViewTargetFan.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField) && !self.textFieldViewTargetFan.isHidden && self.enumApplieceType == .fan{
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Fan speed is required"
            }
            return nil
        }
        
        //set button type Custom from storyboard
        buttonSubmit.setThemeAppBlue(localizeFor(isEdit ? "update_button" : "save_button"))
        scrollView.addBounceViewAtTop()
        
        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")
        
        buttonDelete.setTitle(localizeFor("delete_target_appliance"), for: .normal)
        buttonDelete.setTitleColor(UIColor.textFieldErrorColor, for: .normal)
        buttonDelete.titleLabel?.font = UIFont.Poppins.medium(13)
        buttonDelete.isHidden = true
        
        textFieldViewTargetRGB.isHidden = true
        textFieldViewTargetFan.isHidden = true
        enableDisableSaveButton()
    }
    
    func loadData(){
        if let objTargetAppl = objTargetApplience{
            
            buttonDelete.isHidden = false // show while edit...
            textFieldViewTargetAppName.setText = objTargetAppl.applianceName
            
            // alloc becouse default nil
            selectedApplienceObject = PrivilegeGroupDeviceDataModel.init(jsonObject: JSON())
            selectedApplienceObject?.dataId = objTargetAppl.applianceId
            selectedApplienceObject?.arrayOprationSupported = objTargetAppl.operationsArray
            
            targetAction = objTargetAppl.targetAction
            targetAccess = objTargetAppl.targetAccess
            targetvalue = objTargetAppl.targetValue
            applianceImage = objTargetAppl.applianceImage
            self.setTargetAccessApplienceValueFromId()
            
            // check if rgb or fan control then will show here acording applience support
            self.textFieldViewTargetFan.isHidden = true
            self.textFieldViewTargetRGB.isHidden = true
            
            let enumSelectedAction = EnumTargetActionValue.init(rawValue: targetvalue) ?? .none
            if enumSelectedAction == .on{
                if objTargetAppl.operationsArray.contains(.fan){
                    self.textFieldViewTargetFan.isHidden = false
                }else if objTargetAppl.operationsArray.contains(.rgb){
                    self.textFieldViewTargetRGB.isHidden = false
                }
            }
            
            /*
            textFieldViewTargetAction.isHidden = true
            if objTargetAppl.operationsArray.contains(.on) && objTargetAppl.operationsArray.contains(.off){
                textFieldViewTargetAction.isHidden = false
            }*/
            
            func setLightEnableDisableFanRGB(){
                textFieldViewTargetAction.setText = objTargetAppl.actionValueDisplay
                textFieldViewTargetAction.alpha = 1
                textFieldViewTargetFan.alpha = 1
                textFieldViewTargetRGB.alpha = 1
                
                // set deafult speed value
                textFieldViewTargetFan.setText = EnumFanSpeed.verySlow.title

                // set default color
                setRGBToTextfield(color: objTargetAppl.applianceColor)

                /*
                textFieldViewTargetFan.alpha = 0.5
                textFieldViewTargetRGB.alpha = 0.5
                 */
            }
            
            // here set value according action selected
            let enumApplienceType = EnumApplianceAction.init(rawValue: targetAction) ?? .none
            switch enumApplienceType {
            case .onOff:
                setLightEnableDisableFanRGB()
            case .fan:
                let speedValue = objTargetAppl.targetValue
//                if speedValue > 1{
                    targetFanSpeed = speedValue
                    self.smartAddTargetViewModel.currentSelectedCondition = DooBottomPopupGenericDataModel.init(dataId: "\(speedValue)", dataValue: objTargetAppl.fanSppedDisplay)
                    textFieldViewTargetFan.setText = objTargetAppl.fanSppedDisplay
                    self.textFieldViewTargetFan.isHidden = false
                    /* textFieldViewTargetAction.alpha = 0.5 */
                    textFieldViewTargetAction.setText = EnumTargetActionValue.on.title
//                }else{
//                    setLightEnableDisableFanRGB()
//                }
            case .rgb:
                /* textFieldViewTargetAction.alpha = 0.5 */
                guard objTargetAppl.applianceColor != nil else { return }
                setRGBToTextfield(color: objTargetAppl.applianceColor)
                textFieldViewTargetRGB.isHidden = false
                textFieldViewTargetAction.setText = EnumTargetActionValue.on.title
            default:break
            }
            self.selectedApplianceId = objTargetApplience?.applianceId
            self.enableDisableSaveButton()
        }
    }
    
    func checkTargetAccessBasedOnSegmentIndex(segmentIndex: Int) -> Int{
        switch segmentIndex {
        case 0:
            return EnumTargetAccess.na.rawValue
        case 1:
            return EnumTargetAccess.enable.rawValue
        case 2:
            return EnumTargetAccess.disable.rawValue
        default:
            return 2
        }
    }
    
    func getTargetAccessValueBasedOnSegmentValue() -> String {
        switch self.targetAccess {
        case 0:
            return EnumTargetAccess.na.title
        case 1:
            return EnumTargetAccess.enable.title
        case 2:
            return EnumTargetAccess.disable.title
        default:
            return EnumTargetAccess.na.title
        }
    }
    
    func isValidateFields() -> Bool {
        if textFieldViewTargetAppName.isValidated() && textFieldViewTargetAction.isValidated() && textFieldViewTargetRGB.isValidated() &&  textFieldViewTargetFan.isValidated(){
            return true
        }
        return false
    }
    
    // here mension 1,2,3 onoff, fan, RGb while validation perfome it check && condition alomg with tagetAction
    func checkAllFieldsBlank() -> Bool {
        if textFieldViewTargetAppName.getText?.isEmptyOrDash ?? false ||
            (textFieldViewTargetAction.getText?.isEmptyOrDash ?? false && self.enumApplieceType == .onOff) ||
            (textFieldViewTargetFan.isHidden == false && textFieldViewTargetFan.getText?.isEmptyOrDash ?? false && self.enumApplieceType == .fan) ||
            (textFieldViewTargetRGB.isHidden == false && textFieldViewTargetRGB.getText?.isEmptyOrDash ?? false && self.enumApplieceType == .rgb){
            return false
        }
        
        return true
    }
    
    func enableDisableSaveButton(){
        buttonSubmit.alpha = checkAllFieldsBlank() ? 1 : 0.5
        buttonSubmit.isUserInteractionEnabled = checkAllFieldsBlank() ? true : false
    }
}

// MARK: - UITextFieldDelegate
extension SmartAddTargetViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewTargetAppName.rightIconTextfield:
            if let privilegesVC = UIStoryboard.enterpriseUsers.userPrivilegesVC {
                
                if let groupsId = self.groupId, let devicesId = self.selectedApplianceId, let applinceId = selectedApplienceObject?.dataId{
                    privilegesVC.selectedUsersId = "\(APP_USER?.userId ?? 0)"
                    privilegesVC.redirectedFrom = .applienceSelectionForSmartRule(groupsId, devicesId, applinceId)
                }else{
                    privilegesVC.selectedUsersId = "\(APP_USER?.userId ?? 0)"
                    privilegesVC.redirectedFrom = .applienceSelectionForSmartRule(nil, nil, nil)
                }
                privilegesVC.callBackWithSelectedData = { (parentNode, deviceNode, childNode) in
                    if let nodeParent = parentNode{
                        self.groupId = nodeParent.dataId
                    }
                    if let nodeDevice = deviceNode {
                        self.selectedApplianceDeviceName = nodeDevice.title
                    }
                    
                    if let nodeChild = childNode{
                        self.selectedApplianceId = nodeChild.dataId
                        self.textFieldViewTargetAppName.setText = nodeChild.title
                        self.selectedApplienceObject = nodeChild
                        
                        self.textFieldViewTargetRGB.isHidden = true
                        self.textFieldViewTargetFan.isHidden = true
                        self.targetAction = EnumApplianceAction.onOff.rawValue//nodeChild.applienceAction
                        self.textFieldViewTargetAction.setText = ""

                        /*
                        // set alpha 1 when applience select
                        self.textFieldViewTargetRGB.alpha = 1
                        self.textFieldViewTargetFan.alpha = 1
                        self.textFieldViewTargetAction.alpha = 1
                         self.textFieldViewTargetAction.setText = ""
                         */
                        
                        /*
                        if nodeChild.arrayOprationSupported.contains(.rgb){
                            self.textFieldViewTargetRGB.isHidden = false
                            self.targetAction = EnumApplianceAction.rgb.rawValue
                        }
                        
                        if nodeChild.arrayOprationSupported.contains(.fan){
                            self.textFieldViewTargetFan.isHidden = false
                            self.targetAction = EnumApplianceAction.fan.rawValue
                        }*/
                        
                        /*
                        // here check
                        self.textFieldViewTargetAction.isHidden = true
                        if nodeChild.arrayOprationSupported.contains(.on) && nodeChild.arrayOprationSupported.contains(.off){
                            self.textFieldViewTargetAction.isHidden = false
                        }*/
                        
                        self.applianceImage = nodeChild.image
                        self.enableDisableSaveButton()
                    }
                }
                self.navigationController?.pushViewController(privilegesVC, animated: true)
            }
            return false
            
        case textFieldViewTargetAction.rightIconTextfield:
            self.openApplienceActionValueOptions() { (id) in
                
                /*
                // set alpho 0.5 becouse we can only select at time one either onoff or fan rgb
                let enumApplianceAction = EnumApplianceAction.init(rawValue: self.targetAction) ?? .none
                if enumApplianceAction == .rgb{
                    self.textFieldViewTargetRGB.alpha = 0.5
                }else if enumApplianceAction == .fan{
                    self.textFieldViewTargetFan.alpha = 0.5
                }*/
                
                self.targetvalue = id  // here pass on,off,na
                let enumSelectedActions = EnumTargetActionValue.init(rawValue: id) ?? .none
                if let selectedAppliObject = self.selectedApplienceObject, enumSelectedActions == .on{
                    if selectedAppliObject.arrayOprationSupported.contains(.rgb){
                        self.textFieldViewTargetRGB.isHidden = false
//                        self.textFieldViewTargetRGB.setText = ""
//                        self.textFieldViewTargetRGB.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "rgbColorIcon")
                        self.targetAction = EnumApplianceAction.rgb.rawValue
                        self.targetvalue = UIColor.red.getDecimalCodeFromUIColor()
                        self.setRGBToTextfield(color: UIColor.red)
                    }
                    
                    if selectedAppliObject.arrayOprationSupported.contains(.fan){
                        self.textFieldViewTargetFan.isHidden = false
//                        self.textFieldViewTargetFan.setText = ""
                        self.targetAction = EnumApplianceAction.fan.rawValue
                        self.targetvalue = EnumFanSpeed.verySlow.value.getSpeedFromPercentage()
                        self.textFieldViewTargetFan.setText = EnumFanSpeed.verySlow.title
                    }
                }else{
                    self.textFieldViewTargetRGB.isHidden = true
                    self.textFieldViewTargetFan.isHidden = true
                    self.targetAction = EnumApplianceAction.onOff.rawValue
                }
                
                self.textFieldViewTargetAction.alpha = 1
                self.textFieldViewTargetAction.setText = enumSelectedActions?.title ?? ""
                self.enableDisableSaveButton()
            }
            return false
        case textFieldViewTargetRGB.rightIconTextfield:
            
            guard let colorPickerSelectionBottomVC = UIStoryboard.common.colorPickerSelectionBottomVC else {
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
                return false }
            
            if let objTargetObj = objTargetApplience{
                colorPickerSelectionBottomVC.setColorToPickers(color: objTargetObj.applianceColor)
            }else if let rgbCode = self.textFieldViewTargetRGB.getText, !rgbCode.isEmpty{
                colorPickerSelectionBottomVC.setColorToPickers(color: self.targetvalue.getUIColorFromDecimalCode())
            }
            
            colorPickerSelectionBottomVC.modalPresentationStyle = .overFullScreen
            colorPickerSelectionBottomVC.didTap = { (selectedColor) in
                /*
                 // set alpho 0.5 becouse we can only select at time one either onoff or fan rgb
                 self.textFieldViewTargetAction.alpha = 0.5
                 */
                
                self.targetAction = EnumApplianceAction.rgb.rawValue
                self.targetvalue = selectedColor.getDecimalCodeFromUIColor()
                self.textFieldViewTargetRGB.alpha = 1
                self.setRGBToTextfield(color: selectedColor)
                // self.textFieldViewTargetRGB.setText = strHexCode
                self.textFieldViewTargetRGB.dismissError()
                self.enableDisableSaveButton()
            }
            self.present(colorPickerSelectionBottomVC, animated: true, completion: nil)
            return false
        case textFieldViewTargetFan.rightIconTextfield:
            guard let bottomCard = UIStoryboard.common.dooBottomPopUp_NoPullDissmiss_VC else {
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
                return false
            }
            bottomCard.modalPresentationStyle = .overFullScreen
            bottomCard.selectionType = .smartSpeedLevel(smartAddTargetViewModel.listOfCondition)
            bottomCard.selectionData = { [weak self] (dataModel) in
                /*
                // set alpho 0.5 becouse we can only select at time one either onoff or fan control
                self?.textFieldViewTargetAction.alpha = 0.5
                */
                
                self?.targetvalue = (Int(dataModel.dataId) ?? 0).getSpeedFromPercentage()
                self?.textFieldViewTargetFan.setText = dataModel.dataValue
                self?.textFieldViewTargetFan.alpha = 1
                self?.targetAction = EnumApplianceAction.fan.rawValue
                
                self?.textFieldViewTargetFan.dismissError()
                self?.smartAddTargetViewModel.currentSelectedCondition = dataModel
                self?.targetFanSpeed = Int(dataModel.dataId)
                self?.enableDisableSaveButton()
            }
            self.present(bottomCard, animated: true, completion: nil)
            return false
        default: break
        }
        return true
    }
    
    func setRGBToTextfield(color:UIColor){
        let r = color.rgb()?.red ?? 0
        let g = color.rgb()?.green ?? 0
        let b = color.rgb()?.blue ?? 0
        self.textFieldViewTargetRGB.setText = "RGB(\(r),\(g),\(b))"
        self.textFieldViewTargetRGB.rightIconTextfield?.rightIcon = color.image(CGSize.init(width: 20, height: 20))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.enableDisableSaveButton()
        return true
    }
    
    func openApplienceAccessOptions(callBackBlock: @escaping (Int)->()){
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            let action1 = DooBottomPopupActions_1ViewController.PopupOption.init(title: EnumTargetAccess.na.title, color: UIColor.blueHeading, action: {
                callBackBlock(2)
            })
            let action2 = DooBottomPopupActions_1ViewController.PopupOption.init(title: EnumTargetAccess.enable.title, color: UIColor.blueHeading, action: {
                callBackBlock(1)
            })
            let action3 = DooBottomPopupActions_1ViewController.PopupOption.init(title:  EnumTargetAccess.disable.title, color: UIColor.blueHeading, action: {
                callBackBlock(0)
            })
            
            let actions = [action1, action2, action3]
            actionsVC.popupType = .generic(localizeFor("target_access"), "Set parental control access.", actions)
            self.present(actionsVC, animated: true, completion: nil)
        }
    }
    
    func openApplienceActionValueOptions(callBackBlock: @escaping (Int)->()){
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            let action1 = DooBottomPopupActions_1ViewController.PopupOption.init(title: EnumTargetActionValue.na.title, color: UIColor.blueHeading, action: {
                callBackBlock(2)
            })
            let action2 = DooBottomPopupActions_1ViewController.PopupOption.init(title: EnumTargetActionValue.on.title, color: UIColor.blueHeading, action: {
                callBackBlock(1)
            })
            let action3 = DooBottomPopupActions_1ViewController.PopupOption.init(title: EnumTargetActionValue.off.title, color: UIColor.blueHeading, action: {
                callBackBlock(0)
            })
            
            let actions = [action1, action2, action3]
            actionsVC.popupType = .generic(localizeFor("target_action"), "Select scheduler/scene actions", actions)
            self.present(actionsVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SmartAddTargetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
}
