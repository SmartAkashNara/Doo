//
//  AddDeviceViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import CoreLocation

class AddDeviceViewController: CardBaseViewController {

    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var textFieldViewSerialNumber: DooTextfieldView!
    @IBOutlet weak var textFieldViewName: DooTextfieldView!
    @IBOutlet weak var textFieldViewType: DooTextfieldView!
    @IBOutlet weak var textFieldViewGateway: DooTextfieldView!
    @IBOutlet weak var textFieldViewInstallationDate: DooTextfieldView!
    @IBOutlet weak var buttonSubmit: UIButton!
    
    @IBOutlet weak var stackViewStatus: UIStackView!
    @IBOutlet weak var viewDotStatus: UIView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var textViewLocation: ExpandableTextViewWIthErrorAtBottom!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomGradient: UIImageView!

    let addDeviceViewModel = AddDeviceViewModel()
    var locationManager = LocationManager()
    var location: LocationManager.LocationDataModel?
    var deviceData: DeviceDataModel!
    var isEdit = false
    // Card Work
    var bottomCard: DooBottomPopUp_1ViewController? = UIStoryboard.common.bottomGenericVC

    override func viewDidLoad() {
        super.viewDidLoad()

        addDeviceViewModel.deviceData = deviceData
        setDefaults()
        loadData()
        if !deviceData.productIsGateway {
            callGetGatewayListAPI()
        }
    }
}

// MARK: - Actions listeners
extension AddDeviceViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if isValidateFields() {
            if isEdit {
                callUpdateDeviceAPI()
            } else {
                callAddDeviceAPI()
            }
        }
    }
}

// MARK: - Services
extension AddDeviceViewController {
    func callAddDeviceAPI() {
        
        guard let deviceName = textFieldViewName.getText else { return }
        var param: [String: Any] = [
            "serialNumber": deviceData.serialNumber,
            "deviceName": deviceName,
        ]
        if deviceData.productIsGateway {
            //device is gateway
            
            // If location not selected using live location...
            if location == nil {
                // Check that location is empty?, if not then set location data model with manual location entered, otherwise show error...
                if self.textViewLocation.getText().isEmpty {
                    self.textViewLocation.showError(withMessage: "Please enter location!")
                }else{
                    self.location = LocationManager.LocationDataModel.init(manualLocation: self.textViewLocation.getText())
                }
            }
            
            guard let locationStrong = location else { return }
            param["latitude"] = locationStrong.lat
            param["longitude"] = locationStrong.long
            param["location"] = locationStrong.cityStateCountryLatLong
            debugPrint(locationStrong.country)
            debugPrint(locationStrong.state)
            debugPrint(locationStrong.city)

             param["countryId"] = 1 // locationStrong.country
             param["stateId"] = 1 // locationStrong.state
             param["cityId"] = 1 // locationStrong.city
        } else {
            
            //device is not gateway
            guard let selectedGateway = addDeviceViewModel.selectedGateway else { return }
            param["gatewayId"] = Int(selectedGateway.dataId)
        }
        debugPrint(param)
        addDeviceViewModel.callAddDeviceAPI(param: param) {
            guard let destView = UIStoryboard.devices.deviceDetailVC else { return }
            destView.deviceData = self.deviceData
            destView.isFromAddDevice = true
            self.navigationController?.pushViewController(destView, animated: true)
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .failure).showForWhile(animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }

    func callUpdateDeviceAPI() {
        guard let name = textFieldViewName.getText else { return }
        let routingParam: [String: Any] = ["deviceId": deviceData.enterpriseDeviceId, "name": name]
        API_SERVICES.callAPI(path: .updateDevice(routingParam), method: .put) { (_) in
            self.deviceData.deviceName = name
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func callGetGatewayListAPI() {
        addDeviceViewModel.callGetGatewayListAPI()
    }
    
}

// MARK: - User defined methods
extension AddDeviceViewController {
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
        viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])

        let title = isEdit ? (deviceData.productIsGateway ? "Edit gateway" : localizeFor("edit_device_title")) : localizeFor("add_device_title")
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: isEdit ? (deviceData.productIsGateway ? "Update gateway details" : "Update device details") : "Add device details")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true

        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)

        textFieldViewSerialNumber.titleValue = localizeFor("serial_number")
        textFieldViewSerialNumber.textfieldType = .generic
        textFieldViewSerialNumber.genericTextfield?.addThemeToTextarea(localizeFor("enter_serial_number"))
        textFieldViewSerialNumber.genericTextfield?.returnKeyType = .done
        textFieldViewSerialNumber.disabled = true
        textFieldViewSerialNumber.activeBehaviour = true
        
        textFieldViewName.titleValue = localizeFor("name")
        textFieldViewName.textfieldType = .generic
        textFieldViewName.genericTextfield?.addThemeToTextarea(localizeFor("enter_name"))
        textFieldViewName.genericTextfield?.returnKeyType = .done
        textFieldViewName.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewName.genericTextfield?.delegate = self
        textFieldViewName.activeBehaviour = true
        textFieldViewName.disabled = !isEdit

        textFieldViewType.titleValue = localizeFor("type")
        textFieldViewType.textfieldType = .generic
        textFieldViewType.genericTextfield?.addThemeToTextarea(localizeFor("enter_type"))
        textFieldViewType.genericTextfield?.returnKeyType = .done
        textFieldViewType.disabled = true
        textFieldViewType.activeBehaviour = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textViewLocation.showTitle(withValue: "Location")
        }
        textViewLocation.locationTapped = {
            self.locationManager.config()
        }
        textViewLocation.isUserInteractionEnabled = false

        textFieldViewGateway.titleValue = localizeFor("gateway")
        textFieldViewGateway.textfieldType = .rightIcon
        textFieldViewGateway.rightIconTextfield?.addThemeToTextarea(localizeFor("select_gateway"))
        textFieldViewGateway.rightIconTextfield?.rightIcon = UIImage(named: "arrowDownBlue")!
        textFieldViewGateway.rightIconTextfield?.delegate = self
        textFieldViewGateway.activeBehaviour = true

        textFieldViewInstallationDate.titleValue = localizeFor("installation_date")
        textFieldViewInstallationDate.textfieldType = .rightIcon
        textFieldViewInstallationDate.rightIconTextfield?.addThemeToTextarea(localizeFor("select_installation_date"))
        textFieldViewInstallationDate.rightIconTextfield?.rightIcon = UIImage(named: "calendar1")!
        textFieldViewInstallationDate.disabled = true
        textFieldViewInstallationDate.activeBehaviour = true

        //set button type Custom from storyboard
        buttonSubmit.setThemeAppBlueWithArrow(localizeFor(isEdit ? "update_button" : "submit_button"))

        scrollView.addBounceViewAtTop()
        scrollView.delegate = self
        
        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")

        locationManager.delegate = self
        
        labelStatus.font = UIFont.Poppins.semiBold(14)
        viewDotStatus.makeRoundByCorners()

        setControlsTypeWise()
        setControlsAddEditFlowWise()
    }
    
    func disableLocation(disabled: Bool) {
        textViewLocation.showDisabledEnabled(isDisabled: disabled)
        if disabled {
            textViewLocation.isUserInteractionEnabled = false
            textViewLocation.alpha = 0.8
            textViewLocation.showDashedBorder()
        } else {
            textViewLocation.isUserInteractionEnabled = true
            textViewLocation.alpha = 1.0
            textViewLocation.removeDashedBorder()
        }
    }
    
    func setLocationText(text: String) {
        self.textViewLocation.dismissError()
        self.textViewLocation.setText(text)
        
        if isEdit{
            DispatchQueue.getMain(delay: 0.2) {
                if (self.textViewLocation.expandableTextView?.textviewHeightConstraint.constant ?? 0.0) > 45.3{
                    self.textViewLocation.expandableTextView?.textviewHeightConstraint.constant += 14
                }
                self.textViewLocation.expandableTextView?.layoutIfNeeded()
                self.disableLocation(disabled: self.isEdit) // disable location while edit
            }
        } else {
            self.disableLocation(disabled: self.isEdit)
        }
    }
   
    func setControlsTypeWise() {
        if deviceData.productIsGateway {
            // gateway
            textViewLocation.isHidden = false
            textFieldViewGateway.isHidden = true
        } else {
            // device
            textViewLocation.isHidden = true
            textFieldViewGateway.isHidden = false
        }
    }
    
    func setControlsAddEditFlowWise() {
        if isEdit {
            stackViewStatus.isHidden = false
            setStatus()
            textFieldViewInstallationDate.isHidden = false
            textFieldViewGateway.disabled = true
        } else {
            stackViewStatus.isHidden = true
            textFieldViewInstallationDate.isHidden = true
        }
    }

    func setStatus() {
        guard let status = deviceData.getEnumStatus else { return }
        labelStatus.text = status.name
        labelStatus.textColor = status.color
        viewDotStatus.backgroundColor = status.color
    }
    
    func loadData() {
        textFieldViewSerialNumber.setText = deviceData.serialNumber
        textFieldViewName.setText = deviceData.deviceName
        if deviceData.productIsGateway {
            textFieldViewType.setText = "Gateway"
            setLocationText(text: deviceData.location)
            
        } else {
            textFieldViewType.setText = deviceData.productTypeName
            if isEdit {
                textFieldViewGateway.setText = deviceData.gatewayName
            } else {
                textFieldViewGateway.setText = ""
            }
        }
        textFieldViewInstallationDate.setText = deviceData.getInstallationDate
    }
    
    func isValidateFields() -> Bool {
        let validationStatus = addDeviceViewModel.validateFields(serialNumber: textFieldViewSerialNumber.getText, deviceName: textFieldViewName.getText, deviceType: textFieldViewType.getText, location: self.textViewLocation.getText(), gateway: textFieldViewGateway.getText)
        switch validationStatus.state{
        case .serialNumber:
            textFieldViewSerialNumber.showError(validationStatus.errorMessage)
        case .deviceName:
            textFieldViewName.showError(validationStatus.errorMessage)
        case .deviceType:
            textFieldViewType.showError(validationStatus.errorMessage)
        case .location:
            textViewLocation.showError(withMessage: validationStatus.errorMessage)
        case .gateway:
            textFieldViewGateway.showError(validationStatus.errorMessage)
        case .none:
            return true
        }
        return false
    }
}


// MARK: - UITextFieldDelegate
extension AddDeviceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == textFieldViewGateway.rightIconTextfield {
            view.endEditing(true)
            openGatewayListCard()
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func openGatewayListCard() {
        if let bottomView = self.bottomCard {
            self.setLayout(withCard: bottomView, cardPosition: .bottom)
            bottomView.selectionType = .gateways(addDeviceViewModel.gateways)
            bottomView.openCard(dynamicHeight: true)
            bottomView.selectionData = { dataModel in
                self.textFieldViewGateway.setText = dataModel.dataValue
                self.addDeviceViewModel.selectedGateway = dataModel
            }
        }else{
            self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
        }
    }
}

// MARK: - LocationManagerDelegate
extension AddDeviceViewController : LocationManagerDelegate {
    func locationFound(withCoordinates coordinates: CLLocationCoordinate2D) {
        locationManager.removeManager()
        locationManager.coordinatesToAddressWithLatLong(withCoordinates: coordinates) { (location) in
            guard let locationStrong = location else { return }
            self.location = locationStrong
            self.setLocationText(text: locationStrong.cityStateCountryLatLong)
        }
    }
    func locationDenied() {
        let goToSettings = UIAlertAction.init(title: "Settings", style: .default) { alertAction in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        self.showAlert(withTitle: "App Permission Denied",
                       withMessage: "To re-enable, please go to Settings and turn on Location Service for this app.\n We do require location to add device and enhance it's usage experience",
                       withActions: goToSettings, withStyle: .alert)

    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddDeviceViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension AddDeviceViewController: UIScrollViewDelegate {
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
