//
//  SmartHomeViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import Toast_Swift

class SmartHomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var tableViewGroupDetail: SayNoForDataTableView!
    @IBOutlet weak var dooNoDataView: DooNoDataView_1!
    @IBOutlet weak var buttonNotification: UIButton!
    @IBOutlet weak var buttonAddGroup: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var collectionViewGroupMenu: UICollectionView!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!
    
    // MARK: - Variables
    var viewModel = SmartHomeViewModel()
    var sceneViewModel = SceneViewModel()
    var bindingRuleViewModel = BindingRuleViewModel()
    var scheduleViewModel = ScheduleViewModel()
    var selectedGroupMenuTab = 0
    private var totalHeaderHieght: CGFloat = 42
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        setDefaults()
        configureTableView()
        
        if SMARTRULE_OFFLINE_LOAD_ENABLE {
            bindingRuleViewModel.loadStaticData()
            sceneViewModel.loadStaticData()
            scheduleViewModel.loadStaticData()
            loadNoDataPlaceholder()
        } else {
            callGetBindingRuleListAPI(isCallSequnceApi: true)
        }
        
        // Not required, will handle it using tabbar.
        // NotificationCenter.default.addObserver(self, selector: #selector(self.callApiWhenChangeEnterprise), name: Notification.Name("changedEnterpise"), object: nil)
    }
    
    @objc func callApiWhenChangeEnterprise(){
        self.selectedGroupMenuTab = 0
        viewModel.selectdEnumSmartMenuType = nil
        sceneViewModel.arraySceneList.removeAll()
        scheduleViewModel.arrayScheduerList.removeAll()
        bindingRuleViewModel.arrayBindingRuleList.removeAll()
        viewModel.arrrayOfGroup.removeAll()
        viewModel.preparedSmartMenuArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableViewGroupDetail.reloadData()
        
        // profile picture
        self.assignProfilePicture()
    }
    
    // MARK: - ViewDidAppear stuffs
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = self
    }
}

// MARK: - User defined methods
extension SmartHomeViewController {
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        collectionViewGroupMenu.dataSource = self
        collectionViewGroupMenu.delegate = self
        collectionViewGroupMenu.setCollectionViewLayout(layout, animated: false)
        collectionViewGroupMenu.registerCellNib(identifier: GroupMenuCollectionViewCell.identifier, commonSetting: true)
    }
    
    func configureTableView() {
        
        tableViewGroupDetail.dataSource = self
        tableViewGroupDetail.delegate = self
        tableViewGroupDetail.bounces = true
        tableViewGroupDetail.registerCellNib(identifier: HomeUserInfoSectionTVCell.identifier, commonSetting: true)
        tableViewGroupDetail.registerCellNib(identifier: CollectionViewTVCell.identifier)
        tableViewGroupDetail.registerCellNib(identifier: GroupCardTVCell.identifier)
        tableViewGroupDetail.registerCellNib(identifier: SmartHomeSceneTVCell.identifier)
        tableViewGroupDetail.registerCellNib(identifier: SmartHomeScheduleTVCell.identifier)
        tableViewGroupDetail.registerCellNib(identifier: SmartHomeSectionTVCell.identifier)
        
        tableViewGroupDetail.addRefreshControlForPullToRefresh {
            if SMARTRULE_OFFLINE_LOAD_ENABLE{
                self.tableViewGroupDetail.stopPullToRefresh()
                self.bindingRuleViewModel.loadStaticData()
                self.sceneViewModel.loadStaticData()
                self.scheduleViewModel.loadStaticData()
                self.loadNoDataPlaceholder()
                return
            }
            switch self.viewModel.selectdEnumSmartMenuType{
            case .bindingRule:
                self.callGetBindingRuleListAPI(isPullToRefresh: true)
                break
            case .scenes:
                self.callGetSceneListAPI(isPullToRefresh: true)
                break
            case .schedule:
                self.callGetScheduleListAPI(isPullToRefresh: true)
                break
            case .none:
                break
            }
        }
        tableViewGroupDetail.sayNoSection = .noRuleListFound("BINDING RULE")
        tableViewGroupDetail.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 15, right: 0)
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.000000001))
        tableViewGroupDetail.tableHeaderView = v
        //        configureUserNameHeader()
    }
    
    func configureUserNameHeader(){
        tableViewGroupDetail.tableHeaderView = nil
        let cell = tableViewGroupDetail.dequeueReusableCell(withIdentifier: HomeUserInfoSectionTVCell.identifier) as! HomeUserInfoSectionTVCell
        cell.cellConfigForGroup()
        cell.contentView.backgroundColor = UIColor.grayCountryHeader
        tableViewGroupDetail.autolayoutTableViewHeader = cell.contentView
        //        tableViewGroupDetail.tableHeaderView = cell.contentView
        //        tableViewGroupDetail.tableHeaderView?.frame.size.height = 0.01//HomeUserInfoSectionTVCell.cellHeightGroup
        tableViewGroupDetail.addBounceViewAtTop()
    }
    
    func setDefaults() {
        mainView.delegateOfSWWalert = self
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = false
        navigationTitle.text = Utility.getHeyUserFirstName()
        
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        imageViewProfile.backgroundColor = UIColor.black
        imageViewProfile.contentMode = .scaleAspectFill
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        imageViewProfile.isUserInteractionEnabled = true
        imageViewProfile.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.navigateToProfileView(sender:))))
    }
    
    func assignProfilePicture() {
        self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.bounds.size.width/2
        if let user = APP_USER, let thumbNail = URL.init(string: user.thumbnailImage) {
            self.imageViewProfile.sd_setImage(with: thumbNail, completed: nil)
        }
    }
    
    @objc func navigateToProfileView(sender: UIImageView) {
        if let profileVC = UIStoryboard.profile.instantiateInitialViewController() {
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SmartHomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.arrrayOfGroup.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupMenuCollectionViewCell.identifier, for: indexPath) as! GroupMenuCollectionViewCell
        cell.labelGroupName.text = viewModel.arrrayOfGroup[indexPath.row].title
        cell.setSelected(isSelected: selectedGroupMenuTab == indexPath.row)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SmartHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = viewModel.arrrayOfGroup[indexPath.row].title
        let itemWidth = item.widthOfString(usingFont: UIFont.Poppins.medium(12))
        return CGSize(width: itemWidth - 18, height: 40)
    }
}

// MARK: - UICollectionViewDelegate
extension SmartHomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedGroupMenuTab != indexPath.row{
            selectedGroupMenuTab = indexPath.row
            self.viewModel.selectdEnumSmartMenuType = self.viewModel.arrrayOfGroup[indexPath.row]
            self.loadNoDataPlaceholder()
            DispatchQueue.getMain {
                collectionView.reloadData()
                self.collectionViewGroupMenu.scrollToItem(at: IndexPath.init(row: self.selectedGroupMenuTab, section: 0), at: .left, animated: false)
            }
        }
    }
}


// MARK: - Services
extension SmartHomeViewController {
    
    func callGetBindingRuleListAPI(isNextPageRequest:Bool=false, isPullToRefresh:Bool=false, isCallSequnceApi:Bool=false) {
        
        if !isPullToRefresh {
            API_LOADER.show(animated: true)
        }
        let param = bindingRuleViewModel.getPageDict(isPullToRefresh)
        tableViewGroupDetail.isAPIstillWorking = true
        bindingRuleViewModel.callGetAllBindingRuleAPI(param: param) { [weak self] in
            if isPullToRefresh{
                self?.tableViewGroupDetail.stopPullToRefresh()
            }
            
            self?.tableViewGroupDetail.isAPIstillWorking = false
            if isCallSequnceApi{
                self?.callGetScheduleListAPI(isNextPageRequest: isNextPageRequest, isPullToRefresh: isPullToRefresh,isCallSequnceApi: isCallSequnceApi)
            }else{
                self?.loadNoDataPlaceholder()
                API_LOADER.dismiss(animated: true)
            }
        } failure: {  [weak self] msg in
            self?.mainView.showSomethingWentWrong()
        } internetFailure: { [weak self] in
            self?.mainView.showInternetOff()
        } failureInform: { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.tableViewGroupDetail.isFirstCallOfAPIWorking = false
            self?.tableViewGroupDetail.isAPIstillWorking = false
            self?.tableViewGroupDetail.stopPullToRefresh()
            self?.tableViewGroupDetail.reloadData()
        }
    }
    
    func callGetScheduleListAPI(isNextPageRequest:Bool=false, isPullToRefresh:Bool=false, isCallSequnceApi:Bool=false) {
        
        let param = scheduleViewModel.getPageDict(isNextPageRequest)
        tableViewGroupDetail.isAPIstillWorking = true
        scheduleViewModel.callGetScheduleListAPI(param: param) { [weak self] in
            if isPullToRefresh{
                self?.tableViewGroupDetail.stopPullToRefresh()
            }
            
            self?.tableViewGroupDetail.isAPIstillWorking = false
            if isCallSequnceApi{
                self?.callGetSceneListAPI(isPullToRefresh: isPullToRefresh,isCallSequnceApi: isCallSequnceApi)
            }else{
                self?.loadNoDataPlaceholder()
            }
        } failure: {  [weak self] msg in
            self?.mainView.showSomethingWentWrong()
        } internetFailure: { [weak self] in
            self?.mainView.showInternetOff()
        } failureInform: { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.tableViewGroupDetail.isFirstCallOfAPIWorking = false
            self?.tableViewGroupDetail.isAPIstillWorking = false
            self?.tableViewGroupDetail.stopPullToRefresh()
            self?.tableViewGroupDetail.reloadData()
        }
    }
    
    func callGetSceneListAPI(isNextPageRequest:Bool = false,isPullToRefresh:Bool=false, isCallSequnceApi:Bool=false) {
        let param = sceneViewModel.getPageDict(isNextPageRequest)
        
        self.tableViewGroupDetail.isAPIstillWorking = true
        sceneViewModel.callGetSceneListAPI(param: param) { [weak self] in
            API_LOADER.dismiss(animated: true)
            if isPullToRefresh{
                self?.tableViewGroupDetail.stopPullToRefresh()
            }
            self?.tableViewGroupDetail.isAPIstillWorking = false
            self?.loadNoDataPlaceholder()
        } failure: {  [weak self] msg in
            self?.mainView.showSomethingWentWrong()
        } internetFailure: { [weak self] in
            self?.mainView.showInternetOff()
        } failureInform: { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.tableViewGroupDetail.isFirstCallOfAPIWorking = false
            self?.tableViewGroupDetail.isAPIstillWorking = false
            self?.tableViewGroupDetail.stopPullToRefresh()
            self?.tableViewGroupDetail.reloadData()
        }
    }
    
    //============================ Enable Disble Scheduler  ============================
    func callEnableDisableSchedulerAPI(status: Bool,id:Int, complitionBlock: @escaping (Bool)->()) {
        API_LOADER.show(animated: true)
        let param: [String: Any] = ["status":status ? 1 : 2, "id":id]
        API_SERVICES.callAPI(path: .scheduleEnableDisable(param),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                complitionBlock(status)
            }
        }
    }
    
    //============================ Enable Disble Binding rule  ============================
    func callEnableDisableBindingRuleAPI(status: Bool, id:Int,complitionBlock: @escaping (Bool)->()) {
        API_LOADER.show(animated: true)
        let param: [String: Any] = ["status":status ? 1 : 2, "id":id]
        API_SERVICES.callAPI(path: .bindingRuleEnableDisable(param),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                complitionBlock(status)
            }
        }
    }
    
    func excuteSceneApi(id:Int) {
        let param: [String: Any] = ["id":id]
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .excuteScene(param),method: .put) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
            }
        }
    }
    
    func loadNoDataPlaceholder(){
        switch viewModel.selectdEnumSmartMenuType {
        case .bindingRule:
            self.tableViewGroupDetail.changeIconAndTitleAndSubtitle(title: "BINDING RULE", detailStr: "No binding rules defined yet", icon: "noDataBinding_rule")
        case .schedule:
            self.tableViewGroupDetail.changeIconAndTitleAndSubtitle(title: "SCHEDULE", detailStr: "No devices have been scheduled yet", icon: "noDataSchedule")
        case .scenes:
            self.tableViewGroupDetail.changeIconAndTitleAndSubtitle(title: "SCENES", detailStr: "No scenes hasve been created yet", icon: "noDataScene")
        case .none:break
        }
        self.tableViewGroupDetail.reloadData()
        self.tableViewGroupDetail.figureOutAndShowNoResults()
    }
    
    func removeObjectAndReload(id:Int){
        switch viewModel.selectdEnumSmartMenuType {
        case .bindingRule:
            self.bindingRuleViewModel.removeSelectedObject(id: id)
        case .schedule:
            self.scheduleViewModel.removeSelectedObject(id: id)
        case .scenes:
            self.sceneViewModel.removeSelectedObject(id: id)
        case .none:break
        }
        loadNoDataPlaceholder()
    }
}

// MARK: - Action listeneres
extension SmartHomeViewController {
    @IBAction func notificationActionListener(_ sender: UIButton) {
        print("notificationActionListener")
    }
    
    @IBAction func addActionListener(_ sender: UIButton) {
        print("add group")
    }
    
    @IBAction func profileActionListener(_ sender: UIControl) {
        guard let destView = UIStoryboard.profile.profileVC else { return }
        navigationController?.pushViewController(destView, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SmartHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionEnum = viewModel.selectdEnumSmartMenuType else {
            return 0
        }
        
        switch sectionEnum {
        case .bindingRule:
            return bindingRuleViewModel.arrayBindingRuleList.count
        case .schedule:
            return scheduleViewModel.arrayScheduerList.count
        case .scenes:
            return sceneViewModel.arraySceneList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let enumSelected = viewModel.selectdEnumSmartMenuType else {
            return tableView.getDefaultCell()
        }
        
        switch enumSelected {
        case .bindingRule:
            let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeScheduleTVCell.identifier) as! SmartHomeScheduleTVCell
            cell.cellConfigWithBindingRuleDataModel(object: bindingRuleViewModel.arrayBindingRuleList[indexPath.row])
            cell.switchOnOFF.tag = indexPath.row
            cell.switchOnOFF.switchStatusChanged = { value in
                self.cellSwitchValueChange(cell.switchOnOFF)
            }
            return cell
            
        case .schedule:
            let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeScheduleTVCell.identifier) as! SmartHomeScheduleTVCell
            
            cell.cellConfigWithSchedulerDataModel(object: scheduleViewModel.arrayScheduerList[indexPath.row])
            cell.switchOnOFF.tag = indexPath.row
            cell.switchOnOFF.switchStatusChanged = { value in
                self.cellSwitchValueChange(cell.switchOnOFF)
            }
            return cell
        case .scenes:
            let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeSceneTVCell.identifier) as! SmartHomeSceneTVCell
            cell.cellConfigForSceneList(dataModel: sceneViewModel.arraySceneList[indexPath.row])
            cell.buttonExecute.tag = indexPath.row
            cell.buttonExecute.addTarget(self, action: #selector(cellButtonExcuteClicked(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    @objc func cellButtonExcuteClicked(sender:UIButton) {
        excuteSceneApi(id: sceneViewModel.arraySceneList[sender.tag].id)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return totalHeaderHieght
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}

// MARK: - UITableViewDelegate
extension SmartHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeSectionTVCell.identifier) as! SmartHomeSectionTVCell
        
        guard let enumSelectedTab = viewModel.selectdEnumSmartMenuType else {
            return nil
        }
        
        cell.cellConfig(title: enumSelectedTab.title.uppercased())
        cell.buttonPlus.tag = section
        cell.buttonPlus.addTarget(self, action: #selector(cellAddDeviceClicked(sender:)), for: .touchUpInside)
        cell.buttonDots.tag = section
        cell.buttonDots.addTarget(self, action: #selector(cellButtonMoreClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func cellButtonMoreClicked(sender:UIButton){
        debugPrint("cellButtonMoreClicked...")
        
    }
    @objc func cellAddDeviceClicked(sender:UIButton){
        
        //        if OFFLINELOADENABLE{
        //            CustomAlertView.init(title: "Comming soon").showForWhile(animated: true)
        //            return
        //        }
        
        guard let enumSelected = viewModel.selectdEnumSmartMenuType else {
            return
        }
        
        switch enumSelected {
        case .bindingRule:
            
            guard let addEditBindingRuleVC = UIStoryboard.smart.addEditBindingRuleVC else {
                return
            }
            
            addEditBindingRuleVC.didAddedOrUpdatedSmartRule = { smartRuleModel in
                if let objectModel = smartRuleModel{
                    self.addOrUpdateBindingRule(objectModel: objectModel)
                }
            }
            addEditBindingRuleVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addEditBindingRuleVC, animated: true)
            debugPrint("Add bindingRule clicked...")
            
        case .scenes:
            debugPrint("Add scenes clicked...")
            guard let selectSceneListVC = UIStoryboard.smart.selectSceneListVC else {
                return
            }
//            selectSceneListVC.objSmartHomeVC = self
            selectSceneListVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(selectSceneListVC, animated: true)
        default:
            guard let addEditSchedulerVC = UIStoryboard.smart.addEditSchedulerVC else {
                return
            }
            addEditSchedulerVC.didAddedOrUpdatedScheduler = { smartRuleModel in
                if let objectModel = smartRuleModel{
                    self.addOrUpdateScheduler(objectModel: objectModel)
                }
            }
            
            addEditSchedulerVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addEditSchedulerVC, animated: true)
            debugPrint("Add Schedule clicked...")
        }
    }
    
    func addOrUpdateBindingRule(objectModel:SRBindingRuleDataModel){
        if let index = self.bindingRuleViewModel.arrayBindingRuleList.firstIndex(where: {$0.id == objectModel.id}){
            self.bindingRuleViewModel.arrayBindingRuleList[index] = objectModel
        }else{
            self.bindingRuleViewModel.arrayBindingRuleList.append(objectModel)
        }
        self.tableViewGroupDetail.reloadData()
    }
    
    func addOrUpdateScheduler(objectModel: SRSchedulerDataModel){
        if let index = self.scheduleViewModel.arrayScheduerList.firstIndex(where: {$0.id == objectModel.id}){
            self.scheduleViewModel.arrayScheduerList[index] = objectModel
        }else{
            self.scheduleViewModel.arrayScheduerList.append(objectModel)
        }
        self.tableViewGroupDetail.reloadData()
    }
    
    func addOrUpdateScene(objectModel:SRSceneDataModel){
        if let index = self.sceneViewModel.arraySceneList.firstIndex(where: {$0.id == objectModel.id}){
            self.sceneViewModel.arraySceneList[index] = objectModel
        }else{
            self.sceneViewModel.arraySceneList.append(objectModel)
        }
        self.tableViewGroupDetail.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        if OFFLINELOADENABLE{
        //            CustomAlertView.init(title: "Comming soon").showForWhile(animated: true)
        //            return
        //        }
        
        guard let smartRuleDetailVC = UIStoryboard.smart.smartRuleDetailVC, let enumSelected = viewModel.selectdEnumSmartMenuType else {
            return
        }
        smartRuleDetailVC.hidesBottomBarWhenPushed = true
        
        switch enumSelected {
        case .bindingRule:
            smartRuleDetailVC.enumSmartMenuType = .bindingRule
            smartRuleDetailVC.dataModdel = (self.bindingRuleViewModel.arrayBindingRuleList[indexPath.row], nil, nil)
        case .schedule:
            smartRuleDetailVC.enumSmartMenuType = .schedule
            smartRuleDetailVC.dataModdel = (nil,self.scheduleViewModel.arrayScheduerList[indexPath.row], nil)
        case .scenes:
            smartRuleDetailVC.enumSmartMenuType = .scenes
            smartRuleDetailVC.dataModdel = (nil, nil,self.sceneViewModel.arraySceneList[indexPath.row])
        }
        self.navigationController?.pushViewController(smartRuleDetailVC, animated: true)
    }
}

// MARK: - Initial Handlings
extension SmartHomeViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        navigationController.interactivePopGestureRecognizer?.isEnabled = !isRootVC
    }
}

extension SmartHomeViewController: DooNoDataView_1Delegate {
    func showNoEnterpriseView() {
        self.tableViewGroupDetail.isScrollEnabled = false
        self.dooNoDataView.initSetup(.noEnterprises)
        self.dooNoDataView.allocateView()
        self.dooNoDataView.delegate = self
    }
    func dismissNoEnterpriseView() {
        self.dooNoDataView.delegate = nil
        self.tableViewGroupDetail.isScrollEnabled = true
        self.dooNoDataView.dismissView()
    }
}

extension SmartHomeViewController{
    
    func cellSwitchValueChange(_ sender: DooSwitch) {
        print("changed status")
        guard let enumSelectedTab = viewModel.selectdEnumSmartMenuType else {
            return
        }
        
        switch enumSelectedTab {
        case .bindingRule:
            if SMARTRULE_OFFLINE_LOAD_ENABLE{
                self.bindingRuleViewModel.arrayBindingRuleList[sender.tag].enable = !self.bindingRuleViewModel.arrayBindingRuleList[sender.tag].enable
                self.tableViewGroupDetail.reloadData()
                return
            }
            callEnableDisableBindingRuleAPI(status: !sender.isON,id: self.bindingRuleViewModel.arrayBindingRuleList[sender.tag].id) { (status) in
                self.bindingRuleViewModel.arrayBindingRuleList[sender.tag].enable = status
                self.tableViewGroupDetail.reloadData()
            }
        case .schedule:
            if SMARTRULE_OFFLINE_LOAD_ENABLE{
                self.scheduleViewModel.arrayScheduerList[sender.tag].enable = !self.scheduleViewModel.arrayScheduerList[sender.tag].enable
                self.tableViewGroupDetail.reloadData()
                return
            }
            callEnableDisableSchedulerAPI(status: !sender.isON,id: self.scheduleViewModel.arrayScheduerList[sender.tag].id) { (status) in
                self.scheduleViewModel.arrayScheduerList[sender.tag].enable = status
                self.tableViewGroupDetail.reloadData()
            }
        default:
            break
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SmartHomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        //        guard contentYoffset != 0 else { return }
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            
            switch viewModel.selectdEnumSmartMenuType {
            case .bindingRule:
                // pagination
                if bindingRuleViewModel.getTotalElements > bindingRuleViewModel.getAvailableElements &&
                    !tableViewGroupDetail.isAPIstillWorking{
                    self.callGetBindingRuleListAPI(isNextPageRequest: true)
                }
            case .schedule:
                // pagination
                if scheduleViewModel.getTotalElements > scheduleViewModel.getAvailableElements &&
                    !tableViewGroupDetail.isAPIstillWorking {
                    self.callGetScheduleListAPI(isNextPageRequest: true)
                }
            case .scenes:
                if sceneViewModel.getTotalElements > sceneViewModel.getAvailableElements &&
                    !tableViewGroupDetail.isAPIstillWorking {
                    self.callGetSceneListAPI(isNextPageRequest: true)
                }
            default:
                break
            }
        }
    }
}

// MARK: - internet & something went wrong work
extension SmartHomeViewController: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        self.mainView.forPurpose = .somethingWentWrong
        self.mainView.dismissSomethingWentWrong()
        
        switch viewModel.selectdEnumSmartMenuType {
        case .bindingRule:
            self.callGetBindingRuleListAPI()
        case .schedule:
            self.callGetScheduleListAPI()
        case .scenes:
            self.callGetSceneListAPI()
        default:
            break
        }
    }
    
    // not from delegates
    func showInternetOffAlert() {
        self.mainView.showInternetOff()
    }
    func showSomethingWentWrongAlert() {
        self.mainView.showSomethingWentWrong()
    }
}

