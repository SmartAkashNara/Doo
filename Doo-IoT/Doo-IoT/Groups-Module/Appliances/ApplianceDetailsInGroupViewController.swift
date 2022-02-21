//
//  ApplianceDetailsInGroupViewController.swift
//  Doo-IoT
//
//  Created by Shraddha on 10/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class ApplianceDetailsInGroupViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var viewSuperMain: UIView!
    @IBOutlet weak var viewSeperator: UIView!
    @IBOutlet weak var scrollViewApplianceDetailsMain: UIScrollView! {
        didSet {
            scrollViewApplianceDetailsMain.delegate = self
            scrollViewApplianceDetailsMain.isPagingEnabled = true
        }
    }
    
    @IBOutlet weak var collectionViewAppliances: UICollectionView!
    
    // MARK: - Variable Declaration
    private var selectedDevice: DeviceDataModel?{
        return deviceDetails
    }
    weak var deviceDetails: DeviceDataModel? = nil
    var selectedApplinceRow = 0
    var viewsToLoadInsideScroll:[UIView] = []
    var colorRGBSelected:UIColor!
    var fanSelectedSpeed:Int!
    var groupEnableDisable = false
    
    weak var selectedViewPowerSwitchView: PowerSwitchView? = nil
    var isRGBValueUpdaing = false
    weak var timerForCallApi: Timer? = nil
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.defaultConfig()
        self.configureCollectionView()
        
        // observer for on off status
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStateOfApplience(notification:)), name: Notification.Name(APPLIENCE_ON_OFF_UPDATE_STATUS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateOnlineOfflineDeviceStatus(notification:)), name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Other Methods
    func defaultConfig() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        self.setNavigationTitle()
        
        viewSeperator.backgroundColor = UIColor.blueHeadingAlpha10
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        self.viewsToLoadInsideScroll = createSlides()
        self.setupSlideScrollView(slidesInsideScroll: viewsToLoadInsideScroll)
        self.setSelectedPowerSwitchBasedOnCurrentView(indexAffected: self.selectedApplinceRow)
        self.changeSelectedValue()
    }
    
    func setSelectedPowerSwitchBasedOnCurrentView(indexAffected: Int) {
        if let objColorPicker = self.scrollViewApplianceDetailsMain.viewWithTag(indexAffected+100) as? ApplianceDetailColorPickerView {
            self.selectedViewPowerSwitchView = objColorPicker.viewSwitchOnOff
        } else if let objIntensityView = self.scrollViewApplianceDetailsMain.viewWithTag(indexAffected+100) as? ApplianceDetailIntensityView {
            self.selectedViewPowerSwitchView = objIntensityView.viewSwitchOnOff
        } else if let objDefaultView = self.scrollViewApplianceDetailsMain.viewWithTag(indexAffected+100) as? ApplianceDetailDefaultView {
            self.selectedViewPowerSwitchView = objDefaultView.viewSwitchOnOff
        }
    }
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionViewAppliances.setCollectionViewLayout(layout, animated: false)
        collectionViewAppliances.registerCellNib(identifier: FavouriteDeviceCVCell.identifier, commonSetting: true)
        collectionViewAppliances.delegate = self
        collectionViewAppliances.dataSource = self
        self.reloadCollectionAndScrollAtSelectedIndex()
    }
    
    func setNavigationTitle() {
        if let goupDetail = selectedDevice{
            let title = goupDetail.deviceName
            viewNavigationBarDetail.viewConfig(
                title: title,
                subtitle: localizeFor("total")+" \(goupDetail.appliances.count) "+localizeFor("active_devices"))
            navigationTitle.text = title
        }
    }
    
    // creation of views inside main scroll view based on number of groups
    func createSlides() -> ([UIView]) {
        var arrayViews = [UIView]()
        if self.selectedDevice?.appliances.count ?? 0 > 0 {
            for (index, applienceObj) in self.selectedDevice!.appliances.enumerated() {
                
                let isPowerOnOffSupportThenShowSwitch = applienceObj.checkApplianceTypeSupportedOrNot(enumType: .on) && applienceObj.checkApplianceTypeSupportedOrNot(enumType: .off)
                
                let isFanControlSupportedThenToShow = applienceObj.checkApplianceTypeSupportedOrNot(enumType: .fan)
                let isRGBControlSupportedThenToShow = applienceObj.checkApplianceTypeSupportedOrNot(enumType: .rgb)
                
                // here if rgb supported and is it rgb
                if isRGBControlSupportedThenToShow{
                    self.colorRGBSelected = applienceObj.applianceColor
                    let colorPickerView: ApplianceDetailColorPickerView = Bundle.main.loadNibNamed("ApplianceDetailColorPickerView", owner: self, options: nil)?.first as! ApplianceDetailColorPickerView
                    colorPickerView.tag = index+100
                    colorPickerView.configWithApplianceObj(applianceModel: applienceObj)
                    colorPickerView.viewSwitchOnOff.switchPower.tag = index
                    colorPickerView.viewSwitchOnOff.isHidden = !isPowerOnOffSupportThenShowSwitch
                    colorPickerView.buttonSave.tag = index
                    if self.selectedApplinceRow == index {
                        self.assignPowerSwitchToSelectedPowerSwitch(objSwitch: colorPickerView.viewSwitchOnOff)
                    }
                    colorPickerView.buttonSave.addTarget(self, action: #selector(self.buttonRGBSaveClicked), for: .touchUpInside)
                    colorPickerView.buttonCancel.addAction(for: .touchUpInside) { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    colorPickerView.powerSwitchOnOFF = { [weak self] (switchStatus, rowIndex) in
                        debugPrint("power status => ",switchStatus)
                        self?.checkGroupEnableOrDisable(applieneObj: applienceObj, index: rowIndex, switchObject: colorPickerView.viewSwitchOnOff.switchPower)
                    }
                    
                    colorPickerView.selectColorClouser = { [weak self] (rgbColor, hexColorCode) in
                        debugPrint("Hex Color: \(String(describing: hexColorCode))")
                        debugPrint("rgbColor: \(rgbColor)")
                        
                        guard let strongSelf = self else { return }
                        strongSelf.colorRGBSelected = rgbColor
                    }
                    arrayViews.append(colorPickerView)
                }else if isFanControlSupportedThenToShow{
                    
                    // here if fan supported and is it fan
                    let objSlide:ApplianceDetailIntensityView = Bundle.main.loadNibNamed("ApplianceDetailIntensityView", owner: self, options: nil)?.first as! ApplianceDetailIntensityView
                    objSlide.configWithApplianceObj(applianceModel: applienceObj)
                    objSlide.viewSwitchOnOff.switchPower.tag = index
                    objSlide.viewSwitchOnOff.isHidden = !isPowerOnOffSupportThenShowSwitch
                    if self.selectedApplinceRow == index {
                        self.assignPowerSwitchToSelectedPowerSwitch(objSwitch: objSlide.viewSwitchOnOff)
                    }
                    objSlide.powerSwitchOnOFF = { [weak self] (switchStatus, rowIndex) in
                        debugPrint("power status => ",switchStatus)
                        self?.checkGroupEnableOrDisable(applieneObj: applienceObj, index: rowIndex, switchObject: objSlide.viewSwitchOnOff.switchPower)
                    }
                    
                    objSlide.updateSpeedvalue = { [weak self] speedValue in
                        guard let strongSelf = self else { return }
                        strongSelf.fanSelectedSpeed = speedValue
                        strongSelf.timerForCallApi?.invalidate()
                        if self?.groupEnableDisable ?? false{
                            strongSelf.timerForCallApi = Timer.scheduledTimer(timeInterval: 1, target: strongSelf, selector: #selector(strongSelf.callFanControlApi), userInfo: applienceObj, repeats: false)
                        }else{
                            self?.showEnableDisbaleAlert()
                        }
                    }
                    arrayViews.append(objSlide)
                }else{
                    
                    // other case other than fan and RGB
                    let objSlide:ApplianceDetailDefaultView = Bundle.main.loadNibNamed("ApplianceDetailDefaultView", owner: self, options: nil)?.first as! ApplianceDetailDefaultView
                    objSlide.configWithApplianceObj(applianceModel: applienceObj)
                    objSlide.viewSwitchOnOff.switchPower.tag = index
                    objSlide.viewSwitchOnOff.isHidden = !isPowerOnOffSupportThenShowSwitch
                    if self.selectedApplinceRow == index {
                        self.assignPowerSwitchToSelectedPowerSwitch(objSwitch: objSlide.viewSwitchOnOff)
                    }
                    objSlide.powerSwitchOnOFF = {  [weak self] (switchStatus, rowIndex) in
                        debugPrint("power status => ",switchStatus)
                        self?.checkGroupEnableOrDisable(applieneObj: applienceObj, index: rowIndex, switchObject: objSlide.viewSwitchOnOff.switchPower)
                    }
                    arrayViews.append(objSlide)
                }
            }
        }
        return arrayViews
    }
    
    func checkGroupEnableOrDisable(applieneObj:ApplianceDataModel, index:Int, switchObject:DooSwitch){
        if groupEnableDisable{
            self.callAppliancePowerONOFFAPI(index: index)
        }else{
            showEnableDisbaleAlert()
            applieneObj.onOffStatus ? switchObject.setOnSwitch() : switchObject.setOffSwitch()
        }
    }
    
    @objc func buttonRGBSaveClicked(sender:UIButton){
        guard let applienceObj = self.selectedDevice?.appliances[sender.tag] else { return }
        if groupEnableDisable{
            self.callUpdateValueFanRGBApplienceApi(applienceObj: applienceObj, isRGBApplience: true)
        }else{
            showEnableDisbaleAlert()
        }
    }
    
    func showEnableDisbaleAlert(){
        self.showAlert(withMessage: "Please enable group to operate appliances!", withActions: UIAlertAction.init(title: "Ok", style: .default, handler: nil))
    }
    
    // fan control api call
    @objc func callFanControlApi(){
        
        guard let applienceObj = self.timerForCallApi?.userInfo as? ApplianceDataModel else { return }
        debugPrint("DispatchQueue updated speed value:- \(String(describing: fanSelectedSpeed))")
        self.timerForCallApi?.invalidate()
        if applienceObj.speed != self.fanSelectedSpeed{
            self.callUpdateValueFanRGBApplienceApi(applienceObj: applienceObj, isRGBApplience: false)
        }
    }
    
    // set the position of created views inside main scrollview
    func setupSlideScrollView(slidesInsideScroll : [UIView]) {
        
        //        scrollViewMain.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.height - 203)
        
        //        let statusBar = UIDevice.hasNotch ? 44 : 20
        //        let indicatorBarAtBottom = UIDevice.hasNotch ? 34 : 0
        scrollViewApplianceDetailsMain.frame = CGRect(x: 0, y: self.viewSeperator.frame.origin.y + self.viewSeperator.frame.size.height, width: view.frame.size.width, height: self.viewSuperMain.frame.size.height - (self.viewSeperator.frame.origin.y + self.viewSeperator.frame.size.height))
        
        scrollViewApplianceDetailsMain.contentSize = CGSize(width: view.frame.width * CGFloat(slidesInsideScroll.count), height: scrollViewApplianceDetailsMain.frame.size.height) 
        
        for i in 0 ..< slidesInsideScroll.count {
            if let slideIntensity = slidesInsideScroll[i] as? ApplianceDetailIntensityView {
                let viewFrame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: scrollViewApplianceDetailsMain.frame.width, height: scrollViewApplianceDetailsMain.frame.height)
                slideIntensity.reSizeXib(frame: viewFrame)
                slideIntensity.setSizeOfViewBasedOnContent(isAccordingSizeOfScreen: true)
                slideIntensity.scrollViewApplianceDetailIntensity.isPagingEnabled = false
                slideIntensity.tag = i + 100
                scrollViewApplianceDetailsMain.addSubview(slideIntensity)
            }
            
            if let slideColorPicker = slidesInsideScroll[i] as? ApplianceDetailColorPickerView {
                let viewFrame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: scrollViewApplianceDetailsMain.frame.width, height: scrollViewApplianceDetailsMain.frame.height)
                slideColorPicker.reSizeXib(frame: viewFrame)
                slideColorPicker.setSizeOfViewBasedOnContent(isAccordingSizeOfScreen: cueDevice.isDeviceSEOrLower ? false : true)
                slideColorPicker.scrollViewApplianceDetailColorPicker.isPagingEnabled = false
                slideColorPicker.tag = i + 100
                scrollViewApplianceDetailsMain.addSubview(slideColorPicker)
            }
            
            if let slideDefault = slidesInsideScroll[i] as? ApplianceDetailDefaultView {
                let viewFrame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: scrollViewApplianceDetailsMain.frame.width, height: scrollViewApplianceDetailsMain.frame.height)
                slideDefault.reSizeXib(frame: viewFrame)
                slideDefault.setSizeOfViewBasedOnContent(isAccordingSizeOfScreen: true)
                slideDefault.scrollViewApplianceDetailDefaultView.isPagingEnabled = false
                slideDefault.tag = i + 100
                scrollViewApplianceDetailsMain.addSubview(slideDefault)
            }
        }
        
        print("scrollViewApplianceDetailsMain.contentSiz:\(scrollViewApplianceDetailsMain.contentSize)\nscrollViewApplianceDetailsMain.frame:\(scrollViewApplianceDetailsMain.frame)")
    }
    
    // will set true or false for that particular object in array whose index matched with selectedappliance i.e selected slide
    func changeSelectedValue() {
        self.deviceDetails?.appliances.indices.forEach { if Int(self.deviceDetails?.appliances[$0].id ?? "0") == self.selectedApplinceRow { self.deviceDetails?.appliances[$0].isSelected = true } else { self.deviceDetails?.appliances[$0].isSelected = false }}
    }
    
    // calculation of current index from scrolled postion
    private func indexOfMajorCell(currentOffsetOfScrollViewMain: CGFloat) -> Int {
        let itemWidth = self.view.frame.size.width
        let proportionalOffset = currentOffsetOfScrollViewMain / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min((self.deviceDetails?.appliances.count ?? 0) - 1, index))
        print("proportionalOffset:\(proportionalOffset)\nindex: \(index)\nsafeIndex: \(safeIndex)\n\n")
        return safeIndex
    }
    
    func reloadCollectionAndScrollAtSelectedIndex() {
        let indexPath = IndexPath(item: self.selectedApplinceRow, section: 0)
        self.collectionViewAppliances.reloadData()
        self.collectionViewAppliances.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        // scroll to view of main scroll based on cell selected
        if let slideVw = self.scrollViewApplianceDetailsMain.viewWithTag(indexPath.row + 100) {
            self.scrollViewApplianceDetailsMain.setContentOffset(CGPoint(x: slideVw.frame.minX, y: slideVw.frame.minY), animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate Methods
extension ApplianceDetailsInGroupViewController: UIScrollViewDelegate {
    
    // on end of scrollview main slide, the index of selected view/group will be find
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewApplianceDetailsMain {
            let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
            self.selectedApplinceRow = self.indexOfMajorCell(currentOffsetOfScrollViewMain: currentHorizontalOffset)
            self.changeSelectedValue()
            let indexPath = IndexPath(item: self.selectedApplinceRow, section: 0)
            self.collectionViewAppliances.reloadData()
            self.collectionViewAppliances.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        addNavigationAnimation(scrollView)
        
        // Resolved bug: Holds position of scrollview to not bounce horizontally.
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    // uncomment this if navigationbardetails view added as a header inside tableview
    /*
     func addNavigationAnimation(_ scrollView: UIScrollView) {
     if scrollView.contentOffset.y >= 32.0 {
     navigationTitle.isHidden = false
     } else {
     navigationTitle.isHidden = true
     }
     if scrollView.contentOffset.y >= 76.0 {
     viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
     }else{
     viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
     }
     }
     */
}


// MARK: - IBActions
extension ApplianceDetailsInGroupViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Initial Handlings UINAvigationController Delegate methods
extension ApplianceDetailsInGroupViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        navigationController.interactivePopGestureRecognizer?.isEnabled = !isRootVC
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ApplianceDetailsInGroupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UICollectionViewDelegate methods
extension ApplianceDetailsInGroupViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedApplinceRow = indexPath.row
        self.changeSelectedValue()
        self.reloadCollectionAndScrollAtSelectedIndex()
    }
}

// MARK: - UICollectionViewDataSource methods
extension ApplianceDetailsInGroupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.deviceDetails?.appliances.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteDeviceCVCell.identifier, for: indexPath) as! FavouriteDeviceCVCell
        cell.cellConfigFromApplianceDetailsinGroupDetail(data: (self.deviceDetails?.appliances[indexPath.row])!, isSelected: selectedApplinceRow == indexPath.row)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ApplianceDetailsInGroupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 76.0, height: FavouriteDeviceCVCell.cellHeight)
    }
}

// MARK: - Applience Set Value With Speed and RGB
extension ApplianceDetailsInGroupViewController{
    func callUpdateValueFanRGBApplienceApi(applienceObj: ApplianceDataModel, isRGBApplience:Bool = false) {
        
        var param: [String: Any] = [:]
        param["applianceId"] = Int(applienceObj.id)
        param["endpointId"] = applienceObj.endpointId
        
        let action = isRGBApplience ? EnumApplianceSupportedOpration.rgb.action :  EnumApplianceSupportedOpration.fan.action
        if isRGBApplience{
            let decimalColorCode = self.colorRGBSelected.getDecimalCodeFromUIColor()
            param["applianceData"] = ["action":action, "value":decimalColorCode]
        }else{
            let speed = self.fanSelectedSpeed.getPercentageSpeed()
            param["applianceData"] = ["action":action, "value":speed]
        }
        
        if isRGBApplience{
            API_LOADER.show(animated: true)
        }
        
        self.isRGBValueUpdaing = true
        API_SERVICES.callAPI(param, path: .applienceONOFF, method: .post) { json in
            debugPrint(json ?? [])
            API_LOADER.dismiss(animated: true)
            self.isRGBValueUpdaing = false
        }  failureInform: { }
    }
}

// MARK: - Applience Power ON OFF APi
extension ApplianceDetailsInGroupViewController {
    func callAppliancePowerONOFFAPI(index: Int) {
        guard let objDeviceDataModel =  self.deviceDetails else { return }
        let applienceValue = objDeviceDataModel.appliances[index].onOffStatus ? 0 : 1
        let endpointId = objDeviceDataModel.appliances[index].endpointId
        
        let param: [String:Any] = [
            "applianceId": Int(objDeviceDataModel.appliances[index].id) ?? 0,
            "endpointId": endpointId,
            "applianceData":["action":EnumApplianceAction.onOff.rawValue, "value":applienceValue] // here passed action fix on off
        ]
        API_SERVICES.callAPI(param, path: .applienceONOFF, method:.post) { (parsingResponse) in } failureInform: { }
    }
    
    
    // update online and offline of device
    @objc func updateOnlineOfflineDeviceStatus(notification:Notification) {
        guard let dictObj = notification.object, let objDeviceDataModel =  self.deviceDetails else { return }
        let json = JSON.init(dictObj)
        let macAddresss = json["macAddress"].stringValue
        let statusOnlineOffline = json["status"].boolValue
        
        if objDeviceDataModel.macAddress == macAddresss{
            self.deviceDetails?.appliances.forEach({ objApplience in
                objApplience.deviceStatus = statusOnlineOffline
            })
            self.collectionViewAppliances.reloadData()
        }
    }

    @objc func updateStateOfApplience(notification:Notification){
        
        guard let dictObj = notification.object, let objDeviceDataModel =  self.deviceDetails else { return }
        let json = JSON.init(dictObj)
        debugPrint(json)
        
        let applianceId = json["applianceId"].intValue
        let applianceData = json["applianceData"].dictionaryValue
        let value = applianceData["value"]?.intValue ?? 0
        let action = applianceData["action"]?.intValue ?? 0
        let enumApplienceAction = EnumApplianceAction.init(rawValue: action) ?? .none
        
        let status = value == 0 ? false : true
        if let index = objDeviceDataModel.appliances.firstIndex(where: {$0.id == "\(applianceId)"}){
            self.setSelectedPowerSwitchBasedOnCurrentView(indexAffected: index)
            
            switch enumApplienceAction {
            case .onOff, .none:
                
                // here update value if greathen 0 that means previous stored fan value we are getting...
                if let objDetail = self.deviceDetails,  objDetail.appliances[index].arrayOprationSupported.contains(.fan) && value > 0{
                    self.deviceDetails?.appliances[index].speed = value.getSpeedFromPercentage()
                    if let fanControlSuperView = scrollViewApplianceDetailsMain.viewWithTag(index+100) as? ApplianceDetailIntensityView {
                        fanControlSuperView.slider.selectedSection = value.getSpeedFromPercentage()
                    }
                }else{
                    self.deviceDetails?.appliances[index].speed = 0
                    if let fanControlSuperView = scrollViewApplianceDetailsMain.viewWithTag(index+100) as? ApplianceDetailIntensityView {
                        fanControlSuperView.slider.selectedSection = 0
                    }
                }
                
                // here if RGB appliene get value then it set applience color
                if let objDetail = self.deviceDetails,  objDetail.appliances[index].arrayOprationSupported.contains(.rgb) && value > 0{
                    self.deviceDetails?.appliances[index].setRGBValueIfApplienceTypeRGB(value: value)
                    if let objColorPicker = self.scrollViewApplianceDetailsMain.viewWithTag(index+100) as? ApplianceDetailColorPickerView{
                        let updatedColor = objDetail.appliances[index].applianceColor ?? .red
                        objColorPicker.colorPicker.color = updatedColor
                        objColorPicker.colorPicker.setViewColor(updatedColor)
//                        objColorPicker.setColorAllComponent(color:                    objDetail.appliances[index].applianceColor)
                    }
                }
            case .fan:
                self.deviceDetails?.appliances[index].speed = value.getSpeedFromPercentage()
                if let fanControlSuperView = scrollViewApplianceDetailsMain.viewWithTag(index+100) as? ApplianceDetailIntensityView, fanControlSuperView.slider.selectedSection !=  value.getSpeedFromPercentage() {
                    fanControlSuperView.slider.selectedSection = value.getSpeedFromPercentage()
                }
            case .rgb:
                self.deviceDetails?.appliances[index].setRGBValueIfApplienceTypeRGB(value: value)
                if let objColorPicker = self.scrollViewApplianceDetailsMain.viewWithTag(index+100) as? ApplianceDetailColorPickerView{
                    let updatedColor = self.deviceDetails?.appliances[index].applianceColor ?? UIColor.red
                    objColorPicker.colorPicker.color = updatedColor
                    objColorPicker.colorPicker.setViewColor(updatedColor)
//                    objColorPicker.setColorAllComponent(color: self.deviceDetails?.appliances[index].applianceColor ?? UIColor.red)
                }
                CustomAlertView.init(title: "Color changed successfully",forPurpose: .success).showForWhile(animated: true)
            }
            
            // update switch status
            self.selectedViewPowerSwitchView?.selectedAppliance?.onOffStatus = status
            self.deviceDetails?.appliances[index].onOffStatus = status
            if status{
                self.selectedViewPowerSwitchView?.switchPower.setOnSwitch()
            }else{
                self.selectedViewPowerSwitchView?.switchPower.setOffSwitch()
            }
            self.collectionViewAppliances.reloadData()
        }else{
            debugPrint("out of index appliance")
        }
    }
    
    func assignPowerSwitchToSelectedPowerSwitch(objSwitch: PowerSwitchView) {
        self.selectedViewPowerSwitchView = objSwitch
    }
}
