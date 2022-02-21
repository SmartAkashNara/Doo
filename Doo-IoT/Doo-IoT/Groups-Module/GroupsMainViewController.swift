//
//  GroupsMainViewController.swift
//  Doo-IoT
//
//  Created by Akash on 06/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class GroupsMainViewController: UIViewController {
    
    // MARK:- IBOutlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var buttonNotification: NotifButton!
    @IBOutlet weak var buttonAddGroup: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!
    @IBOutlet weak var horizontalTitleCollection: HorizontalTitleCollection!
    @IBOutlet weak var scrollViewMain: UIScrollView! {
        didSet {
            scrollViewMain.delegate = self
            scrollViewMain.isPagingEnabled = true
        }
    }
    
    // MARK:- Variable Declaration
    var groupMainViewModel = GroupMainViewModel()
    var viewsToLoadInsideScroll: [AddGroupsInMainVcView] = []
    var selectedGroupMenuTab: Int = 0 {
        didSet{
            viewsToLoadInsideScroll[selectedGroupMenuTab].callGetGroupDetailAPI()
        }
    }
    
    let direction: PanDirection = .horizontal
    
    // MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultConfig()
        self.getAllGroupList()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            // self.callApiWhenChangeEnterprise()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // profile picture
        self.assignProfilePicture()
        self.labelUserName.text = Utility.getHeyUserFirstName()

        buttonAddGroup.isHidden = APP_USER?.selectedEnterprise?.userRole == .user
    }
    
    // default configuration
    func defaultConfig() {
        self.mainView.delegateOfSWWalert = self
        labelUserName.font = UIFont.Poppins.semiBold(22)
        labelUserName.textColor = UIColor.blueHeading
        labelUserName.text = Utility.getHeyUserFirstName()
        
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.text = Utility.getHeyUserFirstName()
        
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        imageViewProfile.backgroundColor = UIColor.black
        imageViewProfile.contentMode = .scaleAspectFill
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        imageViewProfile.isUserInteractionEnabled = true
        imageViewProfile.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.navigateToProfileView(sender:))))
        
        buttonNotification.showDotImage()
        buttonNotification.isHidden = true
        self.assignProfilePicture()
    }
    
    // setting profile pic
    func assignProfilePicture() {
        self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.bounds.size.width/2
        if let user = APP_USER, let thumbNail = URL.init(string: user.thumbnailImage) {
            self.imageViewProfile.contentMode = .scaleAspectFill
            self.imageViewProfile.sd_setImage(with: thumbNail, placeholderImage: UIImage.init(named: "placeholderOfProfilePicture")!, options: .continueInBackground, context: nil)
        }
    }
    
    // navagition on tap of profile pic
    @objc func navigateToProfileView(sender: UIImageView) {
        if let profileVC = UIStoryboard.profile.instantiateInitialViewController() {
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    // This will refresh Menu View if in case new enterprise switched from somewhere.
    func viewAppearedUsingTab() {
        if self.isViewLoaded {
            self.getAllGroupList(callSilently: false)
        }
    }
}

// MARK: - Configure groups title collection
extension GroupsMainViewController {
    func configureContentSlider() {
        self.viewsToLoadInsideScroll = createSlides()
        self.setupSlideScrollView(slidesInsideScroll: viewsToLoadInsideScroll)
    }
    
    // creation of views inside main scroll view based on number of groups
    func createSlides() -> ([AddGroupsInMainVcView]) {
        var arrayViews: [AddGroupsInMainVcView] = self.viewsToLoadInsideScroll
        if self.groupMainViewModel.groups.count > 0 {
            // Add process
            for (index, slide) in groupMainViewModel.groups.enumerated() {
                if !arrayViews.contains(where: {$0.groupID == groupMainViewModel.groups[index].id}) {
                    arrayViews.insert(configureSlideView(groupDataModel: slide, index: index), at: index)
                }else if let firstIndex = arrayViews.firstIndex(where: {$0.groupID == groupMainViewModel.groups[index].id}){
                    // if view is not at same position.
                    if firstIndex != index {
                        let GroupVCView = arrayViews[firstIndex]
                        arrayViews.remove(at: firstIndex)
                        arrayViews.insert(GroupVCView, at: index)
                    }
                    arrayViews[index].selectedGroupDetails?.name = groupMainViewModel.groups[index].name // Change name only...
                }
            }
            
            if arrayViews.count != groupMainViewModel.groups.count {
                // Remove process: As both are inequal, we need to remove views where user got disabled (Like removed access of him).
                arrayViews = arrayViews.filter({ groupVCView in
                    if !groupMainViewModel.groups.contains(where: {$0.id == groupVCView.groupID})  {
                        return false
                    }
                    return true
                })
            }
        }
        
        return arrayViews
    }
    
    func configureSlideView(groupDataModel: GroupDataModel, index:Int) -> AddGroupsInMainVcView{
        let objSlide: AddGroupsInMainVcView = Bundle.main.loadNibNamed("AddGroupsInMainVcView", owner: self, options: nil)?.first as! AddGroupsInMainVcView
        objSlide.defaultConfig(groupDataModel, selectedGroupId: groupDataModel.id, selectedGroupName: groupDataModel.name, isGroupEnabled: groupDataModel.enable)
        objSlide.tableViewAddGroups.isPagingEnabled = false
        objSlide.groupMainVC = self
        objSlide.accessibilityHint = String(index)
        return objSlide
    }
    
    // set the position of created views inside main scrollview
    func setupSlideScrollView(slidesInsideScroll : [AddGroupsInMainVcView]) {
        scrollViewMain.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.height - 203)
        
        // remove all subviews of scrollview
        for viewInScrollView in scrollViewMain.subviews {
            viewInScrollView.removeFromSuperview() // remove all, so we can add all from scractch.
        }
        
        let statusBar = UIDevice.hasNotch ? 44 : 20
        let indicatorBarAtBottom = UIDevice.hasNotch ? 34 : 0
        scrollViewMain.contentSize = CGSize(width: view.frame.width * CGFloat(slidesInsideScroll.count), height: UIScreen.main.bounds.size.height - CGFloat((220 + statusBar + indicatorBarAtBottom))) // 100 header + 50 groups titles content + 50 tabbar = 200
        for i in 0 ..< slidesInsideScroll.count {
            slidesInsideScroll[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: scrollViewMain.frame.width, height: scrollViewMain.frame.height)
            slidesInsideScroll[i].defaultConfig()
            slidesInsideScroll[i].rectInsideScroll = slidesInsideScroll[i].frame
            slidesInsideScroll[i].tag = i + 100
            slidesInsideScroll[i].accessibilityHint = String(i)
            scrollViewMain.addSubview(slidesInsideScroll[i])
        }
    }
}

// MARK: - ScrollView Delegates
extension GroupsMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset.y = 0
        }
        // scrollProcess()
        /*
         let vel = scrollView.panGestureRecognizer.velocity(in: scrollView)
         switch direction {
         case .horizontal where abs(vel.y) < abs(vel.x) && abs(vel.y) < 1.0:
         debugPrint("horizontal direction: \(abs(vel.y)), \(abs(vel.x))")
         case .vertical where abs(vel.x) > abs(vel.y):
         debugPrint("verticle direction: Break")
         default:
         debugPrint("direction: \(abs(vel.y)), \(abs(vel.x))")
         break
         }
         */
        
        self.horizontalTitleCollection.didScrollEvent(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewMain {
            self.horizontalTitleCollection.didScrollDoneEvent(scrollView, draggingStart: true)
            self.selectedGroupMenuTab = self.horizontalTitleCollection.selectedIndex // assign new selected index to view controller's property.
        }
    }
    
    // on end of scrollview main slide, the index of selected view/group will be find
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewMain {
            self.horizontalTitleCollection.didScrollDoneEvent(scrollView)
            self.selectedGroupMenuTab = self.horizontalTitleCollection.selectedIndex // assign new selected index to view controller's property.
        }
    }
}

// MARK: - Action listeneres
extension GroupsMainViewController {
    @IBAction func notificationActionListener(_ sender: UIButton) {
        print("notificationActionListener")
    }
    
    @IBAction func addActionListener(_ sender: UIButton) {
        print("add group")
        guard let destView = UIStoryboard.group.addGroupVC else { return }
        destView.hidesBottomBarWhenPushed = true
        destView.didAddedOrUpdatedGroup = { [ weak self] (objOfGroupDetail, isUpdated) in
            guard let strongSelf = self else { return }
            if !isUpdated{
                
                let indexToInsertNewGroup = strongSelf.viewsToLoadInsideScroll.count-1

                // ADD
                // Content ScrollView Configuration. Insert at 0
                let slideView = strongSelf.configureSlideView(groupDataModel: objOfGroupDetail, index: indexToInsertNewGroup)
                strongSelf.viewsToLoadInsideScroll.insert(slideView, at: indexToInsertNewGroup) // insert before default group always.
                strongSelf.setupSlideScrollView(slidesInsideScroll: strongSelf.viewsToLoadInsideScroll)
                slideView.tableViewAddGroups.reloadData()
                
                // Horizontal titles collection configuration, Insert at 0
                strongSelf.groupMainViewModel.groups.insert(objOfGroupDetail, at: indexToInsertNewGroup)
                strongSelf.groupMainViewModel.groups.forEach { dataModel in dataModel.tabSelected = false } // here tabSelected set false
                self?.selectedGroupMenuTab = indexToInsertNewGroup // for horizontal collection setup reset and redirection.
                strongSelf.setGroupArrayToHorizontalTitleCollectionAndReload(isSetToFirst: false)
                
                // here call detail in background
                slideView.callGetGroupDetailAPI(true)
            }
        }
        navigationController?.pushViewController(destView, animated: true)
    }
    
    @IBAction func profileActionListener(_ sender: UIControl) {
        guard let destView = UIStoryboard.profile.profileVC else { return }
        navigationController?.pushViewController(destView, animated: true)
    }
}

// MARK: - Get All Group List API
extension GroupsMainViewController: SomethingWentWrongAlertViewDelegate {
    func getAllGroupList(callSilently: Bool = true){
        if callSilently {
            self.horizontalTitleCollection.isShowLoader = true // show skeleton
        }
        self.groupMainViewModel.callGetAllGroupsAPI {
            if self.groupMainViewModel.groups.indices.contains(self.selectedGroupMenuTab){
                
                // configure horizental collection and set group of array data
                self.configureContentSlider()
                self.configureTitleHorizontalCollectionAtTop(isSilentCall: callSilently)
                
                // Get current selected slide View then call api
                let slideView  = self.viewsToLoadInsideScroll[self.selectedGroupMenuTab]
                slideView.callGetGroupDetailAPI(true)
            } else if self.groupMainViewModel.groups.count <= 0{
                self.mainView.showNoGroupsFound()
            }
        } failureMessageBlock: { msg in
            // TO-DO Block the view.
            self.mainView.showSomethingWentWrong()
        } internetFailureBlock: {
            self.mainView.showInternetOff()
        } failureInform: {
            self.horizontalTitleCollection.isShowLoader = false // off skeleton
            API_LOADER.dismiss(animated: true)
        }
    }
    
    func retryTapped() {
        self.mainView.dismissAnyAlerts()
        self.callApiWhenChangeEnterprise() // to refresh from scratch...
    }
}

// MARK: Refresh everything when enterprise changes.
extension GroupsMainViewController {
    func callApiWhenChangeEnterprise(){
        // Remove all content views.
        for subview in self.scrollViewMain.subviews {
            subview.removeFromSuperview() // remove content view....
        }
        // horizontal collection will be automatically converted to show skeleton as first priority is to fetch list of groups.
        self.mainView.dismissAnyAlerts()
        getAllGroupList()
    }
}

// MARK:- Other Methods
extension GroupsMainViewController{
    // setting Dummy data, remove after api call integrated.
    func setDummyData() {
        var appliances = [
            ApplianceDataModel(id: 0, title: "Master Bed Light", deviceType: 0, online: false, enumOpration: .rgb, onOffStatus: false),
            ApplianceDataModel(id: 1, title: "Camera 1", deviceType: 0, online: false, enumOpration: .none, onOffStatus: true),
            ApplianceDataModel(id: 2, title: "Bedroom AC", deviceType: 0, online: true, enumOpration: .fan, onOffStatus: true),
            ApplianceDataModel(id: 3, title: "Fridge", deviceType: 0, online: false, enumOpration: .onOff, onOffStatus: true),
            ApplianceDataModel(id: 4, title: "Fridge 2", deviceType: 0, online: true, enumOpration: .onOff, onOffStatus: true)]
        
        var arrDevices1 = [DeviceDataModel]()
        let device1 = DeviceDataModel(deviceListDict: "")
        device1.deviceName = "Device D0001"
        device1.appliances = appliances
        arrDevices1.append(device1)
        
        appliances = [
            ApplianceDataModel(id: 0, title: "Plug One", deviceType: 0, online: false, enumOpration: .none, onOffStatus: false),
            ApplianceDataModel(id: 1, title: "Light 1", deviceType: 0, online: false, enumOpration: .rgb, onOffStatus: true),
            ApplianceDataModel(id: 2, title: "Fan", deviceType: 0, online: true, enumOpration: .fan, onOffStatus: true),
            ApplianceDataModel(id: 3, title: "Bedroom AC", deviceType: 0, online: false, enumOpration: .onOff, onOffStatus: false),
            ApplianceDataModel(id: 4, title: "Plug Two", deviceType: 0, online: false, enumOpration: .onOff, onOffStatus: false)]
        
        let device2 = DeviceDataModel(deviceListDict: "")
        device2.deviceName = "Device D0002"
        device2.appliances = appliances
        arrDevices1.append(device2)
        
        let device3 = DeviceDataModel(deviceListDict: "")
        device3.deviceName = "Device D0003"
        device3.appliances = appliances
        arrDevices1.append(device3)
        
        let device4 = DeviceDataModel(deviceListDict: "")
        device4.deviceName = "Device D0004"
        device4.appliances = appliances
        arrDevices1.append(device4)
        
        let device5 = DeviceDataModel(deviceListDict: "")
        device5.deviceName = "Device D0005"
        device5.appliances = appliances
        arrDevices1.append(device5)
        
        groupMainViewModel.groups = [
            GroupDataModel.init(id: 0, title: "Living Room", deviceType: 1, enable: true, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")" ),
            GroupDataModel.init(id: 1, title: "Dining Area", deviceType: 1, enable: false, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")"),
            GroupDataModel.init(id: 2, title: "Bedroom", deviceType: 1, enable: true, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")"),
            GroupDataModel.init(id: 3, title: "Kitchen", deviceType: 1, enable: true, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")"),
            GroupDataModel.init(id: 4, title: "Balcony", deviceType: 1, enable: false, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")"),
            GroupDataModel.init(id: 5, title: "Garden", deviceType: 1, enable: true, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")"),
            GroupDataModel.init(id: 6, title: "Terrace Garden", deviceType: 1, enable: false, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")"),
            GroupDataModel.init(id: 7, title: "Extra space north", deviceType: 1, enable: false, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")"),
            GroupDataModel.init(id: 8, title: "Extra space south", deviceType: 1, enable: false, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")"),
            GroupDataModel.init(id: 9, title: "Hallway Line", deviceType: 1, enable: true, devices: arrDevices1, strBannerImg: "\(bannerOfGroupImages.allCases.randomElement()?.randomImageName ?? "background_1")")]
        
        configureTitleHorizontalCollectionAtTop()
    }
    
    func configureTitleHorizontalCollectionAtTop(isSilentCall: Bool = false){
        self.setGroupArrayToHorizontalTitleCollectionAndReload()
        self.horizontalTitleCollection.selectionChanged = { index in
            debugPrint("react according to selection of index: \(index)")
            let indexPath = IndexPath(item: index, section: 0)
            
            // scroll to view of main scroll based on cell selected
            if let slideVw = self.scrollViewMain.viewWithTag(indexPath.row + 100) as? AddGroupsInMainVcView{
                self.scrollViewMain.setContentOffset(CGPoint(x: slideVw.frame.minX, y: slideVw.frame.minY), animated: true)
                self.selectedGroupMenuTab  = indexPath.row // set selected horizental index
                
                // here we set condition if devcie or group information not have then call detail api otherwise will not call api
                guard let dataModel = slideVw.selectedGroupDetails else { return }
                // if  dataModel.devices.count == 0 {
                    slideVw.callGetGroupDetailAPI(true)
                // }
            }
        }
    }
    
    func setGroupArrayToHorizontalTitleCollectionAndReload(isSetToFirst: Bool = true){
        self.horizontalTitleCollection.isShowLoader = false // Off skeleton and reload.... Yes this will reload too...
        
        if isSetToFirst {
            self.horizontalTitleCollection.setSliderPosition(sliderXPositionWillBe: 18.3) // statically default to first.
            self.selectedGroupMenuTab = 0 // reset to 0
        }
        
        groupMainViewModel.groups[selectedGroupMenuTab].tabSelected = true
        horizontalTitleCollection.dataModel = self.groupMainViewModel.groups.map({return HorizontalTitleCollectionDataModel.init(title: $0.name, isSelected: $0.tabSelected)})
        horizontalTitleCollection.selectedIndex = selectedGroupMenuTab
        horizontalTitleCollection.resetData()
        
        
        let indexPath = IndexPath(item: self.selectedGroupMenuTab, section: 0)
        if let slideVw = self.scrollViewMain.viewWithTag(indexPath.row + 100) as? AddGroupsInMainVcView{
            self.scrollViewMain.setContentOffset(CGPoint(x: slideVw.frame.minX, y: slideVw.frame.minY), animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.horizontalTitleCollection.setSelectionTab(withIndexPath: indexPath,
                                                               isInformCaller: false, withAnimation: false) // UI Layout reflections.
            }
        }

        
        // first selected tab...
        // if required, open this, this will scroll that slider forcefully to right position.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // self.horizontalTitleCollection.setSelectionTab(withIndexPath: IndexPath.init(row: 0, section: 0),
            //                                               isInformCaller: false, withAnimation: false) // UI Layout reflections.
        }
    }
    
    func justResetHorizontalCollectionTitles() {
        horizontalTitleCollection.dataModel = self.groupMainViewModel.groups.map({return HorizontalTitleCollectionDataModel.init(title: $0.name, isSelected: $0.tabSelected)})
        horizontalTitleCollection.resetData()
    }
}
