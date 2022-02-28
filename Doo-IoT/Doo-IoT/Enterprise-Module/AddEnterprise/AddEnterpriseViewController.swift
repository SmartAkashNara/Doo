//
//  AddEnterpriseViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import CoreLocation

class AddEnterpriseViewController: CardBaseViewController {
    
    enum RedirectedFrom {
        case addFirstEnterprise, addEnterprise
    }
    var redirectedFrom: RedirectedFrom = .addEnterprise
    enum ErrorState { case type, name, location, none } // For validations
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var textFieldViewEnterpriseType: DooTextfieldView!
    @IBOutlet weak var textFieldViewName: DooTextfieldView!
    @IBOutlet weak var textViewLocation: ExpandableTextViewWIthErrorAtBottom!
    @IBOutlet weak var textFieldViewEnterpriseGroups: DooTextfieldView!
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Variables
    var selectEnterpriseGroupsViewModel = SelectEnterpriseGroupsViewModel()
    var locationManager = LocationManager()
    var enterpriseModel: EnterpriseModel!
    // Type of enterprise helper properties
    // This flag is true when types of enterprise API is in progress, so its in progress and user taps on type of enterprise,
    // then this will start loader and stops when API done with fetching and auto opens types of enterprise.
    var isFetchingTypesOfEnterpriseIsInProgress: Bool = false
    // this will help above flag to auto open types of enterprise.
    var isTypesOfEnterpriseTappedByUserBeforeFetching: Bool = false
    
    // Card Work
    var bottomCard: DooBottomPopUp_1ViewController? = UIStoryboard.common.bottomGenericVC
    var isEditFlow = false
    var preserveNewlyAddedGroupsTillUserInAddEnterprise = [EnterpriseGroup]()
    
    // Data holdings
    var listOfTypesOfEnterprises: [DooBottomPopupGenericDataModel] = []
    var arrayOfGroupWhitchAlreadExitsInServer = [String]()
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load edit flow data if update flow working.
        let isAdd = (enterpriseModel == nil)
        if isAdd {
            enterpriseModel = EnterpriseModel()
        }
        
        setDefaults()
        
        // this check will update when whole added object will come instead of enterpriseId
        // then put check on added object
        if isAdd {
            //Setup location config.
            // locationManager.config()
        } else {
            arrayOfGroupWhitchAlreadExitsInServer = enterpriseModel.groups.map({$0.name.lowercased()})
            //Load edit mode data.
            loadEditModeData()
        }
        
        self.scrollView.addBounceViewAtTop() // Screen might be fitting in smaller device, but when keyboard opens, height of occupying data decreases. This is for default layout of header we follows.
        
        // Fetching types of Enterprises here only, so user don't need to wait when opening enterprises types window.
        self.getTypesOfEnterpriseAPI()
    }
    
    // Card to select types of enterprises
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

// MARK: API
extension AddEnterpriseViewController {
    func callAddUpdateEnterpriseAPI() {
        guard let name = textFieldViewName.getText,
              !textViewLocation.getText().isEmpty  else { return }
        
        let groupMasterIds = enterpriseModel.groups.filter({$0.enumGroupType == .masterGroup}).map({$0.groupMasterId})
        
        var param = [
            "name": name,
            "city": enterpriseModel.cityName,
            "state": enterpriseModel.stateName,
            "country": enterpriseModel.countryName,
            "location": textViewLocation.getText(),
            "latitude": enterpriseModel.lat,
            "longitude": enterpriseModel.long,
            "enterpriseTypeId": enterpriseModel.enterpriseTypeId,
            "groupMasterIds": groupMasterIds,
            "privateAccess": true,
        ] as [String:Any]
        
        var arrayGroupCreated = [[String:Any]]()
        let filterGroupArrayOfSimple = enterpriseModel.groups.filter({$0.enumGroupType == .simpleGroup})
        filterGroupArrayOfSimple.forEach { (objGroup) in
            arrayGroupCreated.append([
                "name": objGroup.name,
            ])
        }
        
        // below remove object if already exits in server no need to pass again same
        arrayGroupCreated.removeAll { dictObejct in
            guard let jsonDict = JSON.init(dictObejct).dictionary, let name = jsonDict["name"]?.string else  {return false }
            if arrayOfGroupWhitchAlreadExitsInServer.contains(name.lowercased()){
                return true
            }
            return false
        }
        
        if arrayGroupCreated.count  != 0 {
            param["groupRequests"] = arrayGroupCreated
        }
        
        // Decide routing between Add/Edit enterprise
        var routingTo: Routing = .addEnterprise
        if isEditFlow {
            routingTo = .updateEnterprise(String(self.enterpriseModel.id))
        }
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: routingTo, method: isEditFlow ? .put : .post) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            
            guard let payload = parsingResponse?["payload"] else { return }
            if !self.isEditFlow {
                // Add flow.
                self.enterpriseModel = EnterpriseModel(dict: payload)
            }else{
                // Edit flow.
                self.enterpriseModel.parseEnterprise(dict: payload)
            }
            
            // Add Enterprise: External work, add inside enterprise list and make it selected by default.
            if let user = APP_USER, !self.isEditFlow {
                
                user.selectedEnterprise = self.enterpriseModel // Set newly addeded one as new enterprise.
                UserManager.saveUser()
                
                // If his/her first enterprise added by user as owner.
                if let _ = self.navigationController?.viewControllers.first as? AddEnterpriseWhenNotAvailableViewController {
                    // Switch to home when very first enterprise accepted.
                    SceneDelegate.getWindow?.rootViewController = UIStoryboard.dooTabbar.instantiateInitialViewController()
                }else{
                    ENTERPRISE_LIST.append(self.enterpriseModel) // Add new enterprise in global array.
                    (TABBAR_INSTANCE as? DooTabbarViewController)?.refreshAllViewsOfTabsWhenEnterpriseChanges() // Refresh all views as new enterprise assigns
                    self.navigationController?.popViewController(animated: true)
                }
            }else{
                self.navigationController?.popViewController(animated: true)
            }
            
            // self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Action listeners
extension AddEnterpriseViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if isValidateFields() {
            callAddUpdateEnterpriseAPI()
        }
    }
    
    func isValidateFields() -> Bool {
        let validationStatus = self.validateFields(type: textFieldViewEnterpriseType.getText, name: textFieldViewName.getText, location: textViewLocation.getText())
        switch validationStatus.state{
        case .type:
            textFieldViewEnterpriseType.showError(validationStatus.errorMessage)
        case .name:
            textFieldViewName.showError(validationStatus.errorMessage)
        case .location:
            textViewLocation.showError(withMessage: validationStatus.errorMessage)
        case .none:
            return true
        }
        return false
    }
    
    func validateFields(type: String?, name: String?, location: String?) -> (state: ErrorState, errorMessage: String){
        if InputValidator.checkEmpty(value: type){
            return (.type , localizeFor("enterprise_type_is_required"))
        }
        if InputValidator.checkEmpty(value: name){
            return (.name , localizeFor("enterprise_name_is_required"))
        }
        if !InputValidator.isEnterpriseNameLength(name){
            return (.name , localizeFor("enterprise_name_2_to_40"))
        }
//        if !InputValidator.isEnterpriseName(name){
//            return (.name , localizeFor("plz_valid_enterprise_name"))
//        }
        if InputValidator.checkEmpty(value: location){
            return (.location , localizeFor("location_is_required"))
        }
        return (.none ,"")
    }
}

// MARK: - User defined methods
extension AddEnterpriseViewController {
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
        let title = self.isEditFlow ? localizeFor("edit_enterprise_title") : localizeFor("add_enterprise_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: self.isEditFlow ? "Fill in the below details to update the enterprise" : "Fill in the below details to add an enterprise")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        
        textFieldViewEnterpriseType.titleValue = localizeFor("type")
        textFieldViewEnterpriseType.textfieldType = .rightIcon
        textFieldViewEnterpriseType.rightIconTextfield?.addThemeToTextarea(localizeFor("select_type_of_enterprise"))
        textFieldViewEnterpriseType.rightIconTextfield?.rightIcon = UIImage(named: "arrowDownBlue")!
        textFieldViewEnterpriseType.rightIconTextfield?.delegate = self
        
        textFieldViewName.titleValue = localizeFor("name")
        textFieldViewName.textfieldType = .generic
        textFieldViewName.genericTextfield?.addThemeToTextarea(localizeFor("enter_name"))
        textFieldViewName.genericTextfield?.returnKeyType = .done
        textFieldViewName.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewName.genericTextfield?.delegate = self
        textFieldViewName.activeBehaviour = true

        textViewLocation.showDisabledEnabled(isDisabled: false)
        textViewLocation.locationTapped = {
            self.locationManager.config()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textViewLocation.showTitle(withValue: "Location")
        }
        
        textFieldViewEnterpriseGroups.titleValue = localizeFor("groups")
        textFieldViewEnterpriseGroups.textfieldType = .rightIcon
        textFieldViewEnterpriseGroups.rightIconTextfield?.addThemeToTextarea(localizeFor("add_groups_to_enterprise"))
        textFieldViewEnterpriseGroups.rightIconTextfield?.rightIcon = UIImage(named: "imgAddBlue")!
        textFieldViewEnterpriseGroups.rightIconTextfield?.delegate = self
        textFieldViewEnterpriseGroups.disabled = true
        textFieldViewEnterpriseGroups.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.showAlertToAddEnterpriseFirst(sender:))))
        
        //set button type Custom from storyboard
        buttonSubmit.setThemeAppBlueWithArrow(self.isEditFlow ? localizeFor("update_button") : localizeFor("submit_button"))
        
        locationManager.delegate = self
        scrollView.delegate = self
    }
    
    @objc func showAlertToAddEnterpriseFirst(sender: UITapGestureRecognizer) {
        if let typeText = textFieldViewEnterpriseType.getText, typeText.isEmpty {
            self.showAlert(withMessage: "Please select enterprise type first to add groups!", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        }
    }
}

// MARK: - Edit Mode
extension AddEnterpriseViewController {
    func loadEditModeData() {
        textFieldViewEnterpriseType.setText = enterpriseModel.enterpriseTypeName
        textFieldViewName.setText = enterpriseModel.name
        textViewLocation.setText(enterpriseModel.location)
        for i in 0..<enterpriseModel.groups.count {
            enterpriseModel.groups[i].groupOfAddTime = true
        }
        setGroupsToTextFieldWithEnable()
    }
}

// MARK: - Types of Enterprises for types dropdown selection.
extension AddEnterpriseViewController {
    // Calling this API earlier, So we can figure out the height of Enterprise opening DooBottomPopUp_1ViewController.
    func getTypesOfEnterpriseAPI() {
        let param:[String:Any] = ["page": 0,
                                  "size": 0,
                                  "sort": ["column": "name",
                                           "sortType": "asc"
                                  ],
                                  "criteria": [
                                    ["column": "name",
                                     "operator": "like",
                                     "values": [""]
                                    ]
                                  ]
        ]
        
        self.isFetchingTypesOfEnterpriseIsInProgress = true
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .getTypesOfEnterprises) { parsingResponse in
            API_LOADER.dismiss(animated: true)
            self.isFetchingTypesOfEnterpriseIsInProgress = false
            if let types = parsingResponse?["payload"]?.dictionary?["content"]?.arrayValue{
                self.listOfTypesOfEnterprises.removeAll()
                for typeInJSON in types {
                    if let typeId = typeInJSON["id"].int, typeId > 0, let typeName = typeInJSON["name"].string, !typeName.isEmpty {
                        let type = DooBottomPopupGenericDataModel.init(dataId: String(typeId), dataValue: typeName)
                        self.listOfTypesOfEnterprises.append(type)
                    }
                }
                // Open type of enteprise card if user tried to open it.
                if self.isTypesOfEnterpriseTappedByUserBeforeFetching{
                    self.openTypeOfEnterpriseCard()
                }
            }
        } failureInform: {
            API_LOADER.dismiss(animated: true)
            // This block will be called, no matter success or any failure.
            self.isFetchingTypesOfEnterpriseIsInProgress = false
        }
    }
    
    // Open card with tyeps of enterprises
    func openTypeOfEnterpriseCard() {
        guard self.listOfTypesOfEnterprises.count != 0 else {
            CustomAlertView.init(title: "Enterprise type not available").showForWhile(animated: true)
            return
        }
        if let bottomView = self.bottomCard {
            self.setLayout(withCard: bottomView, cardPosition: .bottom)
            bottomView.selectionType = .typeOfEnterprise(self.listOfTypesOfEnterprises)
            bottomView.openCard(dynamicHeight: true)
            bottomView.selectionData = { dataModel in
                self.textFieldViewEnterpriseType.setText = dataModel.dataValue
                self.enterpriseModel.enterpriseTypeId = dataModel.dataId
                self.enterpriseModel.groups.removeAll (where: { !$0.groupOfAddTime })
                self.setGroupsToTextFieldWithEnable()
            }
        }else{
            self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
        }
    }
    
    @IBAction func unwindSegueFromSelectEnterpriseGroupsToAddEnterprise(segue: UIStoryboardSegue) {
        if let fromView = segue.source as? SelectEnterpriseGroupsViewController {
            enterpriseModel.groups = fromView.selectEnterpriseGroupsViewModel.arraySelectedGroups
            setGroupsToTextFieldWithEnable()
        }
    }
    
    func setGroupsToTextFieldWithEnable() {
        textFieldViewEnterpriseGroups.disabled = InputValidator.checkEmpty(value: textFieldViewEnterpriseType.getText) // show group textfield enabled only if enterprise type selected.
        textFieldViewEnterpriseGroups.setText = enterpriseModel.groups.count.setSufix(single: " \(localizeFor("group_sufix"))", multiple: " \(localizeFor("groups_sufix"))")
    }
}

// MARK: - UITextFieldDelegate
extension AddEnterpriseViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldViewEnterpriseType.rightIconTextfield:
            view.endEditing(true)
            if self.isFetchingTypesOfEnterpriseIsInProgress == true {
                self.isTypesOfEnterpriseTappedByUserBeforeFetching = true // This flags inform enterprise types success block to even open card from your side, once done with fetching types. as user already tried to select enterprise type.
                API_LOADER.show(animated: true) // start loading to show enterprise types being fetched and wait for some time.
            }else{
                openTypeOfEnterpriseCard() // if already fetched in mean time. just open the card.
            }
            return false
        case textFieldViewEnterpriseGroups.rightIconTextfield:
            view.endEditing(true)
            if let destiView = UIStoryboard.enterprise.selectEnterpriseGroupsVC {
                destiView.preSelectedGroupsForEditEnterpriseMode = enterpriseModel.groups
                destiView.selectEnterpriseGroupsViewModel = selectEnterpriseGroupsViewModel
                destiView.enterpriseTypeId = enterpriseModel.enterpriseTypeId
                if self.isEditFlow {
                    destiView.enterpriseId = String(self.enterpriseModel.id) // pass id for fetching groups based on enterprise.
                }
                destiView.isEditFlow = self.isEditFlow
                destiView.objAddEnterpriseVC = self
                navigationController?.pushViewController(destiView, animated: true)
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
extension AddEnterpriseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: Location stuff
extension AddEnterpriseViewController : LocationManagerDelegate {
    func locationFound(withCoordinates coordinates: CLLocationCoordinate2D) {
        locationManager.removeManager()
        locationManager.coordinatesToAddressWithLatLong(withCoordinates: coordinates) { (location) in
            guard let locationStrong = location else { return }
            self.textViewLocation.setText(locationStrong.cityStateCountry)
            self.enterpriseModel.cityName = locationStrong.city
            self.enterpriseModel.stateName = locationStrong.state
            self.enterpriseModel.countryName = locationStrong.country
            self.enterpriseModel.lat = locationStrong.lat
            self.enterpriseModel.long = locationStrong.long
        }
    }
    func locationDenied() {
        let goToSettings = UIAlertAction.init(title: "Settings", style: .default) { alertAction in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        self.showAlert(withTitle: "App Permission Denied",
                       withMessage: "To re-enable, please go to Settings and turn on Location Service for this app. We do require location to add enterprise and enhance it's usage experience",
                       withActions: goToSettings, withStyle: .alert)

    }
}

// MARK: - UIScrollViewDelegate Methods
extension AddEnterpriseViewController: UIScrollViewDelegate {
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
