//
//  HomeViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var tableViewHome: SayNoForDataTableView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!
    @IBOutlet weak var buttonNotification: NotifButton!
    
    var homeViewModel = HomeViewModel()
    var sceneViewModel = SceneViewModel()
    var cellWidthFavDevices: CGFloat = 0
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DooAPILoader.shared.allocate()
        
        configureTableView()
        setDefaults()
        callApiWhenChangeEnterprise()
        
        // Not required. tabbar will going to handle it.
        //NotificationCenter.default.addObserver(self, selector: #selector(self.callApiWhenChangeEnterprise), name: Notification.Name("changedEnterpise"), object: nil)
        
        // observer for on off status
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStateOfAppliences(notification:)), name: Notification.Name(APPLIENCE_ON_OFF_UPDATE_STATUS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getFavourtiteList(isPullToRefresh:)), name: Notification.Name(UPDATE_APPLIENCE_FAVOURITE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gatewayInfoChanged), name: Notification.Name(GATEWAY_STATUS_CHANGE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateOnlineOfflineDeviceStatus(notification:)), name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)

    }
    
    // MARK: Hanlde gateway change effect.
    @objc func gatewayInfoChanged() {
        self.tableViewHome.reloadData() // reload data to get gateway effect.
    }
    
    @objc func updateOnlineOfflineDeviceStatus(notification:Notification) {
        guard let dictObj = notification.object else { return }
        let json = JSON.init(dictObj)
        let macAddresss = json["macAddress"].stringValue
        let statusOnlineOffline = json["status"].boolValue

        if let index = self.homeViewModel.homeLayouts.firstIndex(where: {$0.layoutFor == .favAppliances}){
            if let arrayData:[ApplianceDataModel] = (self.homeViewModel.homeLayouts[index].layoutData as? [ApplianceDataModel]) {
                arrayData.forEach { objApplince in
                    if objApplince.macAddress == macAddresss{
                        objApplince.deviceStatus = statusOnlineOffline
                    }
                }
                self.homeViewModel.homeLayouts[index].layoutData = arrayData
                self.tableViewHome.reloadData()
//                if let applienceIndex: Int = arrayData.firstIndex(where: {$0.macAddress == macAddresss}){
//                    arrayData[applienceIndex].deviceStatus = statusOnlineOffline
//                    self.tableViewHome.reloadData()
//                }
            }
        }
    }

    
    // This will refresh Menu View if in case new enterprise switched from somewhere.
    func viewAppearedUsingTab() {
        if self.isViewLoaded {
            
            // profile picture
            self.assignProfilePicture()
            
            self.labelUserName.text = Utility.getHeyUserFirstName()
            self.callApiWhenChangeEnterprise(isPullToRefresh: true, withoutLoaderOfAnyKind: true) // send without loader to not shown skeleton.
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // shows dot image
        buttonNotification.showDotImage()
        buttonNotification.isHidden = true
        
        // profile picture
        self.assignProfilePicture()
        
        self.labelUserName.text = Utility.getHeyUserFirstName()
        
        // fetch gateway presence whenever this screen shown
        self.fetchGatewayPresence()
    }
    
    // MARK: - ViewDidAppear stuffs
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(APPLIENCE_ON_OFF_UPDATE_STATUS), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(UPDATE_APPLIENCE_FAVOURITE), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(APPLIENCE_ONLINE_OFFLine_UPDATE_STATUS), object: nil)

    }
}

// MARK: - User defined methods
extension HomeViewController {
    
    func configureTableView() {
        tableViewHome.dataSource = self
        tableViewHome.delegate = self
        tableViewHome.bounces = true
        tableViewHome.registerCellNib(identifier: HomeUserInfoSectionTVCell.identifier, commonSetting: true)
        tableViewHome.registerCellNib(identifier: HomeFavouritesDevicesTVCell.identifier)
        tableViewHome.registerCellNib(identifier: HomeFavouritesScenesTVCell.identifier)
        tableViewHome.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewHome.sectionHeaderHeight = 0
        tableViewHome.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableViewHome.sayNoSection = .noFavoriteFound("Favorite")
        
        // top space, when pull happens
        self.tableViewHome.addBounceViewAtTop()
        self.tableViewHome.addRefreshControlForPullToRefresh {
            self.callApiWhenChangeEnterprise(isPullToRefresh: true)
        }
        self.tableViewHome.getRefreshControl().tintColor = .lightGray
    }
    
    func setDefaults() {
        
        labelUserName.font = UIFont.Poppins.semiBold(22)
        labelUserName.textColor = UIColor.blueHeading
        
        viewStatusBar.backgroundColor = UIColor.graySceneCard
        viewNavigationBar.backgroundColor = UIColor.graySceneCard
        imageViewProfile.backgroundColor = UIColor.black
        self.imageViewProfile.isUserInteractionEnabled = true
        self.imageViewProfile.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.navigateToProfileView(sender:))))
        
         self.mainView.delegateOfSWWalert = self // handle retry part.
    }
    
    func assignProfilePicture() {
        self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.bounds.size.width/2
        if let user = APP_USER, let thumbNail = URL.init(string: user.thumbnailImage) {
            // self.imageViewProfile.sd_setImage(with: thumbNail, completed: nil) // Previously kept.
            self.imageViewProfile.contentMode = .scaleAspectFill
            self.imageViewProfile.sd_setImage(with: thumbNail, placeholderImage: UIImage.init(named: "placeholderOfProfilePicture")!, options: .continueInBackground, context: nil)
        }
    }
    
    @objc func navigateToProfileView(sender: UIImageView) {
        if let profileVC = UIStoryboard.profile.instantiateInitialViewController() {
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}

// MARK: - Action listeneres
extension HomeViewController {
    @IBAction func notificationActionListener(_ sender: UIButton) {
        if let notifVc = UIStoryboard.home.notificationsListVC {
            notifVc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(notifVc, animated: true)
        }
    }
    
    @IBAction func addActionListener(_ sender: UIButton) {
        if let destView = UIStoryboard.home.homeLayoutSettingVC {
            destView.homeViewModel = self.homeViewModel
            navigationController?.pushViewController(destView, animated: true)
        }
    }
    
    @IBAction func profileActionListener(_ sender: UIControl) {
        guard let destView = UIStoryboard.profile.profileVC else { return }
        navigationController?.pushViewController(destView, animated: true)
    }
}

// MARK: - Something went wrong
extension HomeViewController: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        // dismiss both and try again.
        (TABBAR_INSTANCE as? DooTabbarViewController)?.refreshAllViewsOfTabsWhenEnterpriseChanges() // refresh all views in tabbar with new enterprise
        self.mainView.dismissInternetOff()
        self.mainView.dismissSomethingWentWrong()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homeViewModel.homeLayouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        func deviceSkeletonView() -> HomeFavouritesDevicesTVCell{
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeFavouritesDevicesTVCell.identifier, for: indexPath) as! HomeFavouritesDevicesTVCell
            cell.showSkeletonAnimation()
            return cell
        }
        
        func sceneSkeletonView() -> HomeFavouritesScenesTVCell{
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeFavouritesScenesTVCell.identifier, for: indexPath) as! HomeFavouritesScenesTVCell
            cell.showSkeletonAnimation()
            return cell
        }
        
        
        let layoutModel = self.homeViewModel.homeLayouts[indexPath.row]
        switch layoutModel.layoutFor {
        case .favAppliances:
            // if appliances fetched... continue ahead.
            if !layoutModel.isDataFetched {
                return deviceSkeletonView()
            }else if let dataArray = layoutModel.layoutData as? [ApplianceDataModel] {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeFavouritesDevicesTVCell.identifier, for: indexPath) as! HomeFavouritesDevicesTVCell
                cell.cellConfigFromHome()
                cell.cellConfig(data: dataArray,
                                layout: self.homeViewModel.homeLayouts[indexPath.row])
                cell.selectionStyle = .none
                
                cell.didTapLongGesture = { (row, section) in
                }
                
                cell.didTap = { (row, section) in
                    self.callApplienceONOFFAPI(applianceObj: dataArray[row])
                }
                
                cell.didMoreTapped = {
                    self.homeViewModel.homeLayouts[indexPath.row].showAllData = !self.homeViewModel.homeLayouts[indexPath.row].showAllData // reverset
                    self.tableViewHome.reloadData()
                }
                
                return cell
            }else{
                return tableView.getDefaultCell()
            }
        case .scenes:
            // Scenes data fill...
            if !layoutModel.isDataFetched {
                return sceneSkeletonView()
            }else if let dataArray = self.homeViewModel.homeLayouts[indexPath.row].layoutData as? [SRSceneDataModel] {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeFavouritesScenesTVCell.identifier, for: indexPath) as! HomeFavouritesScenesTVCell
                cell.cellConfig(data: dataArray)
                cell.buttonClouser = { sceneID in
                    
                    let param: [String: Any] = ["id": sceneID.id]
                    // API_LOADER.show(animated: true)
                    API_SERVICES.callAPI(path: .excuteScene(param),method: .put) { (parsingResponse) in
                        // API_LOADER.dismiss(animated: true)
                        if let jsonResponse = parsingResponse{
                            debugPrint(jsonResponse)
                            CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                        }
                    }
                }
                cell.selectionStyle = .none
                if dataArray.count <= 0 {
                    cell.labelTitleFavouriteScenes.isHidden = true
                }
                return cell
            }else{
                return tableView.getDefaultCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HomeUserInfoSectionTVCell.cellHeight // UITableView.
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeUserInfoSectionTVCell.identifier) as! HomeUserInfoSectionTVCell
        if let appUser = APP_USER {
            cell.cellConfig(totalNoOfActiveDevices: appUser.selectedEnterprise?.enterpriseGateway?.noOfActiveDevices ?? 0, gatewayStatus: appUser.selectedEnterprise?.enterpriseGateway?.status ?? false)
        }else{
            cell.cellConfig(totalNoOfActiveDevices: 0, gatewayStatus: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}


// MARK: - Initial Handlings
extension HomeViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        navigationController.interactivePopGestureRecognizer?.isEnabled = !isRootVC
    }
}

// MARK:
extension HomeViewController {
    @objc func callApiWhenChangeEnterprise(isPullToRefresh: Bool = false, withoutLoaderOfAnyKind: Bool = false){
        
        self.mainView.dismissAnyAlerts() // to remove alerts
        
        // fetch gateway presence whenever this screen shown
        self.fetchGatewayPresence()
        
        if !withoutLoaderOfAnyKind {
            self.homeViewModel.loadAppliancesAndScenesLayouts() // load from scratch...
            self.tableViewHome.reloadData()
            self.tableViewHome.figureOutAndShowNoResults() // to remove no fav placeholder when skeleton started showing in screen.
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !withoutLoaderOfAnyKind {
                self.tableViewHome.reloadData() // for skeleton
            }
            
            // API call
            self.getFavourtiteList(isPullToRefresh: isPullToRefresh)
        }
    }
    func fetchGatewayPresence() {
        API_SERVICES.callAPI(path: .getGatewayPresence(0), method: .get) { parsingResponse in
            print("Gateway Presence Response: \(String(describing: parsingResponse))")
            if let gatewayData = parsingResponse?["payload"]?.dictionaryValue["data"]?.dictionaryValue{
                
                let deviceStatus = gatewayData["deviceStatus"]?.intValue ?? 0
                var gatewayStatus = false
                if deviceStatus == 1{
                    // Show online
                    gatewayStatus = true
                }
                APP_USER?.selectedEnterprise?.enterpriseGateway = EnterpriseGateway.init(status: gatewayStatus,
                                                                                         noOfActiveDevices: gatewayData["connectedDevices"]?.intValue ?? 0,
                                                                                         totalDevices: gatewayData["totalDevices"]?.intValue ?? 0,
                                                                                         macAddress: gatewayData["macAddress"]?.stringValue ?? "")
                UserManager.saveUser() // will save APP_USER.
                DispatchQueue.getMain(delay: 0.3) {
                    
                    if let macAddress = APP_USER?.selectedEnterprise?.enterpriseGateway?.macAddress, !macAddress.isEmpty {
                        MQTTSwift.shared.subscribeMQTT(macAddress: macAddress) // MQTT External Code.
                    }else{
                        MQTTSwift.shared.unsubscribeMQTT() // here we will have previous gateway unsubscribe even thouth we can not get current mac address from presence
                        MQTTSwift.shared.gatewayMachAddress = "" // here we will have previous gateway unsubscribe set emptry even thouth we can not get current mac address from presence
                        APP_USER?.selectedEnterprise?.enterpriseGateway?.status = false // if mac address not found, make enterprise status to false.
                    }
                    self.tableViewHome.reloadData()
                }
            }
        } failure: { _ in
        } internetFailure: {
        } failureInform: {
        }
    }
    @objc func getFavourtiteList(isPullToRefresh: Bool = false) {
        
        if !isPullToRefresh{
            // API_LOADER.show(animated: true)
        }
        homeViewModel.callGetAllFavouriteAPI { [weak self] in
            
            // Add scenes data in home layout.
            if let indexOfAppliances = self?.homeViewModel.homeLayouts.firstIndex(where: {$0.layoutFor == .favAppliances}),
               let appliancesList = self?.homeViewModel.homeLayouts[indexOfAppliances].layoutData,
               appliancesList.count == 0{
                // remove previous data or change flag to true of 'isDataFetched' to off skeleton animation.
                self?.homeViewModel.homeLayouts.remove(at: indexOfAppliances)
            }
            
            self?.tableViewHome.stopRefreshing() // if pull to refresh, it will stop it.
            self?.tableViewHome.reloadData()
            
            self?.getScenesList(isPullToRefresh: isPullToRefresh) // called in dependency...
        } failure: {
            debugPrint("failure")
            self.mainView.showSomethingWentWrong()
        } internetFailure: {
            debugPrint("internet failure")
            self.mainView.showInternetOff()
        } failureInform: {
            API_LOADER.dismiss(animated: true)
            self.tableViewHome.stopRefreshing() // if pull to refresh, it will stop it.
        }
    }
    func getScenesList(isPullToRefresh: Bool = false) {
        let param = sceneViewModel.getPageDict(isPullToRefresh)
        sceneViewModel.callGetFavouriteSceneListAPI() { [weak self] in
            
            // Add scenes data in home layout.
            if let indexOfScenes = self?.homeViewModel.homeLayouts.firstIndex(where: {$0.layoutFor == .scenes}) {
                // remove previous data or change flag to true of 'isDataFetched' to off skeleton animation.
                if self?.sceneViewModel.arraySceneList.count != 0 {
                    self?.homeViewModel.homeLayouts[indexOfScenes].layoutData = self?.sceneViewModel.arraySceneList ?? []
                    self?.homeViewModel.homeLayouts[indexOfScenes].isDataFetched = true
                }else{
                    self?.homeViewModel.homeLayouts.remove(at: indexOfScenes)
                }
            }else if self?.sceneViewModel.arraySceneList.count != 0{
                var scenesLayout = HomeViewModel.HomeLayouts.init(layoutTitle: localizeFor("scenes"), showAllData: false, layoutFor: .scenes)
                scenesLayout.layoutData = self?.sceneViewModel.arraySceneList ?? []
                scenesLayout.isDataFetched = true
                self?.homeViewModel.homeLayouts.append(scenesLayout)
            }
            
            self?.tableViewHome.stopRefreshing() // if pull to refresh, it will stop it.
            self?.tableViewHome.reloadData()
            self?.tableViewHome.figureOutAndShowNoResults()
        } failure: {_ in
            debugPrint("failure")
            self.mainView.showSomethingWentWrong()
        } internetFailure: {
            debugPrint("internet failure")
            self.mainView.showInternetOff()
        } failureInform: {
            API_LOADER.dismiss(animated: true)
            self.tableViewHome.stopRefreshing() // if pull to refresh, it will stop it.
        }
    }
}

// MARK: On Off APIs...
extension HomeViewController{
    func callApplienceONOFFAPI(applianceObj: ApplianceDataModel) {
        
        let applienceValue = applianceObj.onOffStatus ? 0 : 1
        let endpointId =  applianceObj.endpointId
        
        
        let param: [String:Any] = [
            "applianceId": Int(applianceObj.id) ?? 0,
            "endpointId": endpointId,
            "applianceData": ["action": EnumApplianceAction.onOff.rawValue, "value": applienceValue] // here passed action static 1 for on off only
        ]
        
        API_SERVICES.callAPI(param, path: .applienceONOFF, method:.post) { (parsingResponse) in
            debugPrint("REst Api Response:", parsingResponse!)
            API_LOADER.dismiss(animated: true)
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
    
    @objc func updateStateOfAppliences(notification:Notification){
        guard let dictObj = notification.object else { return }
        let json = JSON.init(dictObj)
        let applianceId = json["applianceId"].intValue
        let applianceData = json["applianceData"].dictionaryValue
        let value = applianceData["value"]?.intValue ?? 0
        let status = value >= 1 ? true : false // here we are checking if value greater than 1 that means status would be on becouse fan control we are fetching value from the same key so we have kept that condition rather than check 0 or 1
        
        if let index = self.homeViewModel.homeLayouts.firstIndex(where: {$0.layoutFor == .favAppliances}){
            if let arrayData:[ApplianceDataModel] = (self.homeViewModel.homeLayouts[index].layoutData as? [ApplianceDataModel]) {
                if let applienceIndex: Int = arrayData.firstIndex(where: {$0.id == "\(applianceId)"}){
                    arrayData[applienceIndex].onOffStatus = status
                    self.tableViewHome.reloadData()
                }
            }
        }
    }
    
}
