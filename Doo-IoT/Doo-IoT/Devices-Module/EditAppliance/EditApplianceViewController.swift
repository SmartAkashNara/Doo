//
//  EditApplianceViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class EditApplianceViewController: CardBaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var textfieldName: DooTextfieldView!
    @IBOutlet weak var textfieldType: DooTextfieldView!
    @IBOutlet weak var labelAccessStatus: UILabel!
    @IBOutlet weak var switchStatus: DooSwitch!
    @IBOutlet weak var buttonUpdate: UIButton!
    
    var applianceData: ApplianceDataModel!
    private var editApplianceViewModel = EditApplianceViewModel()
    private var bottomCard: DooBottomPopUp_1ViewController? = UIStoryboard.common.bottomGenericVC
    var applianceUpdated:((ApplianceDataModel)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard applianceData != nil else { return }
        editApplianceViewModel.applianceData = applianceData
        setDefaults()
        loadData()
        callGetApplianceTypeListAPI()
    }
    
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
}

// MARK: - Services
extension EditApplianceViewController {
    func callGetApplianceTypeListAPI() {
        API_LOADER.show(animated: true)
        editApplianceViewModel.callGetApplianceTypeListAPI([:]) {
            API_LOADER.dismiss(animated: true)
        } failureMessageBlock: { msg in
            API_LOADER.dismiss(animated: true)
            
        }
    }
    
    func callUpdateApplianceAPI() {
        guard let name = textfieldName.getText,
              let selectedApplianceType = editApplianceViewModel.selectedApplianceType else { return }
        let param: [String: Any] = [
            "id" : applianceData.id,
            "name" : name,
            "applianceTypeId" : selectedApplianceType.dataId,
            "accessStatus" : switchStatus.isON,
        ]
        API_LOADER.show(animated: true)
        editApplianceViewModel.callUpdateApplianceAPI(param) {
            API_LOADER.dismiss(animated: true)
            self.applianceData.applianceName = name
            self.applianceData.applianceTypeId = Int(selectedApplianceType.dataId) ?? 0
            self.applianceData.accessStatus = self.switchStatus.isON
            self.applianceData.applianceTypeName = selectedApplianceType.dataValue
            self.applianceUpdated?(self.applianceData)
            self.navigationController?.popViewController(animated: true)
        } failureMessageBlock: { msg in
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: msg, forPurpose: .failure).showForWhile(animated: true)
        }
    }
    
    func callUpdateAccessOfAppliance() {
        // 1 for enable
        //2 for disable
        guard let id =  Int(applianceData.id) else { return }
        API_SERVICES.callAPI(path: .applianceToggleEnable(["applianceId": id,
                                                           "flag": switchStatus.isON ? 1 : 2]),
                             method: .put) { [weak self] (parsingResponse) in
            if let json = parsingResponse, let strongSelf = self{
                debugPrint(json)
                strongSelf.applianceData.accessStatus = strongSelf.switchStatus.isON
                strongSelf.applianceUpdated?(strongSelf.applianceData)
            }
        } internetFailure: {
            API_LOADER.dismiss(animated: true)
        }
    }

}

// MARK: - Action listener
extension EditApplianceViewController {
    @objc func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @objc func updateActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if isValidateFields() {
            callUpdateApplianceAPI()
        }
    }
    
    func enableDisableSaveButton() {
        let validate = !(textfieldName.getText ?? "").isEmpty && !(textfieldType.getText ?? "").isEmpty
        buttonUpdate.alpha = validate ? 1 : 0.5
        buttonUpdate.isUserInteractionEnabled = validate ? true : false
    }

}

// MARK: - User defined methods
extension EditApplianceViewController {
    func setDefaults() {
        
        
        switchStatus.isHidden = true // here hidden set confirmed by IOT team apurv
        labelAccessStatus.isHidden =  true
        
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
        let title = localizeFor("edit_application")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: "Update appliance details")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonBack.addTarget(self, action: #selector(backActionListener(_:)), for: .touchUpInside)
        
        textfieldName.titleValue = localizeFor("name")
        textfieldName.textfieldType = .generic
        textfieldName.genericTextfield?.addThemeToTextarea(localizeFor("name"))
        textfieldName.genericTextfield?.returnKeyType = .done
        textfieldName.genericTextfield?.clearButtonMode = .whileEditing
        textfieldName.genericTextfield?.delegate = self
        textfieldName.genericTextfield?.addAction(for: .editingChanged, { [weak self] in
            self?.enableDisableSaveButton()
        })
        textfieldType.titleValue = localizeFor("type")
        textfieldType.textfieldType = .rightIcon
        textfieldType.rightIconTextfield?.addThemeToTextarea(localizeFor("type"))
        textfieldType.rightIconTextfield?.delegate = self
        textfieldType.rightIconTextfield?.rightIcon = UIImage(named: "arrowDownBlue")!
        textfieldType.activeBehaviour = true
        
        switchStatus.switchStatusChanged = { [weak self] result in
            self?.callUpdateAccessOfAppliance()
        }
        labelAccessStatus.font = UIFont.Poppins.medium(12)
        labelAccessStatus.textColor = UIColor.blueSwitch
        labelAccessStatus.text = "Access Status"
        
        //set button type Custom from storyboard
        buttonUpdate.setThemeAppBlueWithArrow(localizeFor("update_button"))
        buttonUpdate.addTarget(self, action: #selector(updateActionListener(_:)), for: .touchUpInside)
        
        scrollView.delegate = self
    }
    
    func loadData() {
        textfieldName.setText = applianceData.applianceName
        setApplianceType(DooBottomPopupGenericDataModel(dataId: String(applianceData.applianceTypeId), dataValue: applianceData.applianceTypeName))
        if applianceData.accessStatus {
            switchStatus.setOnSwitch(isWithAnimation: true)
        }else{
            switchStatus.setOffSwitch(isWithAnimation: true)
        }
    }
    
    func isValidateFields() -> Bool {
        let validationStatus = editApplianceViewModel.validateFields(applianceName: textfieldName.getText, applianceType: textfieldType.getText)
        switch validationStatus.state{
        case .applianceName:
            textfieldName.showError(validationStatus.errorMessage)
        case .applianceType:
            textfieldType.showError(validationStatus.errorMessage)
        case .none:
            return true
        }
        return false
    }
}

// MARK: - UITextFieldDelegate
extension EditApplianceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textfieldType.rightIconTextfield:
            view.endEditing(true)
            openApplianceTypeListCard()
            return false
        default:
            enableDisableSaveButton()
            break
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func openApplianceTypeListCard() {
        if let bottomView = self.bottomCard {
            self.setLayout(withCard: bottomView, cardPosition: .bottom)
            bottomView.selectionType = .applianceTypes(editApplianceViewModel.applianceTypes)
            bottomView.openCard(dynamicHeight: true)
            bottomView.selectionData = { dataModel in
                self.setApplianceType(dataModel)
            }
        }else{
            self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
        }
    }
    
    func setApplianceType(_ applianceType: DooBottomPopupGenericDataModel) {
        self.textfieldType.setText = applianceType.dataValue
        self.editApplianceViewModel.selectedApplianceType = applianceType
        self.enableDisableSaveButton()
    }
}

// MARK: - UIScrollViewDelegate Methods
extension EditApplianceViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
    }
    
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 32.0 {
            navigationTitle.isHidden = false
        } else {
            navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= 76.0 {
            viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        } else {
            viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EditApplianceViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
