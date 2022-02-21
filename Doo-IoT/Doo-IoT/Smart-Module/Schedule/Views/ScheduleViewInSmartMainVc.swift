//
//  ScheduleViewInSmartMainVc.swift
//  Doo-IoT
//
//  Created by Shraddha on 16/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class ScheduleViewInSmartMainVc: UIView {
    
    @IBOutlet weak var dooNoDataView: DooNoDataView_1!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView!{
        didSet {
            mainView.delegateOfSWWalert = self
        }
    }
    
    @IBOutlet weak var tableViewSchedulesList: SayNoForDataTableView!{
        didSet {
            tableViewSchedulesList.delegate = self
            tableViewSchedulesList.dataSource = self
        }
    }
    
    // MARK: - Variable declaration
    var viewModel = SmartMainViewModel()
    var scheduleViewModel = ScheduleViewModel()
    weak var smartMainVc: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.defaultConfig()
    }
    
    func defaultConfig(viewModel: SmartMainViewModel? = nil,  viewController: UIViewController? = nil) {
        if let viewModel = viewModel, let viewController = viewController {
            self.viewModel = viewModel
            self.viewModel.selectdEnumSmartMenuType = .schedule
            self.smartMainVc = viewController
        }
        self.configureTableView()
        self.callGetSchedulesListAPI()
    }
    
    func setDummyData() {
        self.tableViewSchedulesList.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.scheduleViewModel.isSchedulersListFetched = true
            self.scheduleViewModel.loadStaticData()
            self.tableViewSchedulesList.reloadData()
        }
    }
    
    func configureTableView() {
        tableViewSchedulesList.bounces = true
        tableViewSchedulesList.registerCellNib(identifier: SmartHomeScheduleTVCell.identifier)
        tableViewSchedulesList.registerCellNib(identifier: SmartHomeSectionTVCell.identifier)
        tableViewSchedulesList.registerCellNib(identifier: ThreeStripesWithGapInLastTVCell.identifier)
        
        tableViewSchedulesList.addRefreshControlForPullToRefresh {
            if SMARTRULE_OFFLINE_LOAD_ENABLE{
                self.tableViewSchedulesList.stopPullToRefresh()
                self.scheduleViewModel.loadStaticData()
                self.loadNoDataPlaceholder()
                return
            }else{
                self.callGetSchedulesListAPI(isPullToRefresh: true) // refresh
            }
        }
        
        tableViewSchedulesList.sayNoSection = .noSchedulerListFound("SCHEDULES")
        tableViewSchedulesList.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 15, right: 0)
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.000000001))
        tableViewSchedulesList.tableHeaderView = v
        tableViewSchedulesList.separatorStyle = .none
        tableViewSchedulesList.reloadData()
    }
    
    func loadNoDataPlaceholder() {
        self.tableViewSchedulesList.changeIconAndTitleAndSubtitle(title: "SCHEDULE", detailStr: "No devices have been scheduled yet", icon: "noDataSchedule")
        self.tableViewSchedulesList.reloadData()
        self.tableViewSchedulesList.figureOutAndShowNoResults()
    }
    
    func removeObjectAndReload(id:Int){
        self.scheduleViewModel.removeSelectedObject(id: id)
        loadNoDataPlaceholder()
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewInSmartMainVc: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel.selectdEnumSmartMenuType != nil else { return 0 }
        guard self.scheduleViewModel.isSchedulersListFetched else { return 10 }
        // debugPrint("returned schedulers list count: \(scheduleViewModel.arrayScheduerList.count)")
        
        if (self.scheduleViewModel.getTotalElements > self.scheduleViewModel.arrayScheduerList.count)
            && self.scheduleViewModel.arrayScheduerList.count != 0 {
            return scheduleViewModel.arrayScheduerList.count + 1
        }else{
            return scheduleViewModel.arrayScheduerList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.scheduleViewModel.isSchedulersListFetched else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ThreeStripesWithGapInLastTVCell.identifier) as! ThreeStripesWithGapInLastTVCell
            cell.startAnimating(index: indexPath.row)
            return cell
        }
        
        guard self.scheduleViewModel.arrayScheduerList.indices.contains(indexPath.row) else {
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "identifier")
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "identifier")
            }
            if let activityView = cell.contentView.viewWithTag(102) as? UIActivityIndicatorView {
                activityView.startAnimating()
            }else{
                let activityIndicator = UIActivityIndicatorView.init(style: .medium)
                activityIndicator.tag = 102
                activityIndicator.center = CGPoint.init(x: tableView.center.x, y: 14)
                activityIndicator.startAnimating()
                cell.contentView.addSubview(activityIndicator)
            }
            cell.backgroundColor = .clear
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeScheduleTVCell.identifier) as! SmartHomeScheduleTVCell
        debugPrint("exception breakpost crash: \(indexPath.row)")
        cell.cellConfigWithSchedulerDataModel(object: scheduleViewModel.arrayScheduerList[indexPath.row], position: indexPath.row, arrayCount: self.scheduleViewModel.arrayScheduerList.count)
        cell.switchOnOFF.tag = indexPath.row
        cell.switchOnOFF.switchStatusChanged = { value in
            self.cellSwitchValueChanged(cell.switchOnOFF)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewInSmartMainVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeSectionTVCell.identifier) as! SmartHomeSectionTVCell
        cell.cellConfig(title: SmartMainViewModel.EnumSmartMenuType.schedule.title.uppercased())
        cell.buttonPlus.tag = section
        cell.buttonPlus.addTarget(self, action: #selector(cellAddScheduleClicked(sender:)), for: .touchUpInside)
        cell.buttonPlus.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.scheduleViewModel.isAvailableOwnCreatedScheduler ? 20 : 0, bottom: 0, right: 0);
        cell.buttonDots.tag = section
        
        cell.buttonDots.addTarget(self, action: #selector(cellButtonMoreClicked(sender:)), for: .touchUpInside)
        cell.buttonDots.isHidden = !self.scheduleViewModel.isAvailableOwnCreatedScheduler
        return cell
    }
    
    @objc func cellButtonMoreClicked(sender:UIButton){
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
        let action1 = DooBottomPopupActions_1ViewController.PopupOption(
            title: "Delete all schedulers",
            color: UIColor.textFieldErrorColor, action: {
                self.showDeleteAlert(titleMsg: "Are you sure want to delete all schedulers?")
            })
        actionsVC.isNeedToShowExtraBottomSpcace = false
        actionsVC.popupType = .generic(localizeFor("quick_actions"), "", [action1])
            self.smartMainVc?.present(actionsVC, animated: true, completion: nil)
        }
    }
    
    func showDeleteAlert(titleMsg:String) {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                }
                let deleteAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.delete, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    
                    self.callDeleteAllScheduleAPI()
                    // here call api for all schedullers
                }
                let title = titleMsg
                alertVC.setAlert(alertTitle: title, leftButton: cancelAction, rightButton: deleteAction)
                self.smartMainVc?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func cellAddScheduleClicked(sender:UIButton){
        guard let addEditSchedulerVC = UIStoryboard.smart.addEditSchedulerVC else { return }
        addEditSchedulerVC.didAddedOrUpdatedScheduler = { smartRuleModel in
            
            /*
            if let objectModel = smartRuleModel{
                self.addOrUpdateScheduler(objectModel: objectModel)
            }
            */
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.callGetSchedulesListAPI(isNextPageRequest: false, isPullToRefresh: true)
            }
            
        }
        addEditSchedulerVC.hidesBottomBarWhenPushed = true
        self.smartMainVc?.navigationController?.pushViewController(addEditSchedulerVC, animated: true)
    }
    
    func addOrUpdateScheduler(objectModel: SRSchedulerDataModel){
        /*
        if let index = self.scheduleViewModel.arrayScheduerList.firstIndex(where: {$0.id == objectModel.id}){
            self.scheduleViewModel.arrayScheduerList[index] = objectModel
        }else{
            self.scheduleViewModel.arrayScheduerList.insert(objectModel, at: 0)
        }
        self.tableViewSchedulesList.reloadData()
        self.tableViewSchedulesList.figureOutAndShowNoResults()
        */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.callGetSchedulesListAPI(isNextPageRequest: false, isPullToRefresh: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let smartRuleDetailVC = UIStoryboard.smart.smartRuleDetailVC else { return }
        smartRuleDetailVC.enumSmartMenuType = .schedule
        smartRuleDetailVC.hidesBottomBarWhenPushed = true
        smartRuleDetailVC.dataModdel = (nil, self.scheduleViewModel.arrayScheduerList[indexPath.row], nil)
        self.smartMainVc?.navigationController?.pushViewController(smartRuleDetailVC, animated: true)
    }
}

// MARK: - Switch Value Changed Listener
extension ScheduleViewInSmartMainVc {
    func cellSwitchValueChanged(_ sender: DooSwitch) {
        if SMARTRULE_OFFLINE_LOAD_ENABLE {
            self.scheduleViewModel.arrayScheduerList[sender.tag].enable = !self.scheduleViewModel.arrayScheduerList[sender.tag].enable
            self.tableViewSchedulesList.reloadData()
            return
        }
        callEnableDisableSchedulerAPI(status: !self.scheduleViewModel.arrayScheduerList[sender.tag].enable, id: self.scheduleViewModel.arrayScheduerList[sender.tag].id) { (status) in
            self.scheduleViewModel.arrayScheduerList[sender.tag].enable = status
            self.tableViewSchedulesList.reloadData()
        }
    }
}

// MARK: - internet & something went wrong work
extension ScheduleViewInSmartMainVc: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        self.mainView.forPurpose = .somethingWentWrong
        self.mainView.dismissSomethingWentWrong()
        self.callGetSchedulesListAPI()
    }
    
    // not from delegates
    func showInternetOffAlert() {
        self.mainView.showInternetOff()
    }
    func showSomethingWentWrongAlert() {
        self.mainView.showSomethingWentWrong()
    }
}

// MARK: - DooNoDataView_1Delegate
extension ScheduleViewInSmartMainVc: DooNoDataView_1Delegate {
    func showNoEnterpriseView() {
        self.tableViewSchedulesList.isScrollEnabled = false
        self.dooNoDataView.initSetup(.noEnterprises)
        self.dooNoDataView.allocateView()
        self.dooNoDataView.delegate = self
    }
    func dismissNoEnterpriseView() {
        self.dooNoDataView.delegate = nil
        self.tableViewSchedulesList.isScrollEnabled = true
        self.dooNoDataView.dismissView()
    }
}

// MARK: - UIScrollViewDelegate
extension ScheduleViewInSmartMainVc: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            // pagination
            if scheduleViewModel.getTotalElements > scheduleViewModel.getAvailableElements &&
                !tableViewSchedulesList.isAPIstillWorking {
                self.callGetSchedulesListAPI(isNextPageRequest: true, isPullToRefresh: false)
            }
        }
    }
}

// MARK: - API Calls
extension ScheduleViewInSmartMainVc {
    func callGetSchedulesListAPI(isNextPageRequest: Bool = false, isPullToRefresh:Bool = false) {
        
        guard !self.tableViewSchedulesList.isAPIstillWorking else { return } // Shouldn't me making another call if already running.
        
        if !isNextPageRequest && !isPullToRefresh{
            // API_LOADER.show(animated: true)
            self.scheduleViewModel.isSchedulersListFetched = false // show skeleton
            self.tableViewSchedulesList.reloadData() // show skeleton
            self.tableViewSchedulesList.figureOutAndShowNoResults() // don't show no schedule or scene when skeleton is being shown.
        }
        
        let param = scheduleViewModel.getPageDict(isPullToRefresh)
        self.tableViewSchedulesList.isAPIstillWorking = true
        scheduleViewModel.callGetScheduleListAPI(param: param) { [weak self] in
            API_LOADER.dismiss(animated: true)
            
            // API_LOADER.dismiss(animated: true)
            if isPullToRefresh{
                self?.tableViewSchedulesList.stopPullToRefresh()
            }
            self?.stopLoaders()
            self?.loadNoDataPlaceholder()
        } failure: {  [weak self] msg in
            self?.mainView.showSomethingWentWrong()
        } internetFailure: { [weak self] in
            API_LOADER.dismiss(animated: true)
            self?.mainView.showInternetOff()
        } failureInform: { [weak self] in
             API_LOADER.dismiss(animated: true)
            self?.stopLoaders()
        }
    }
    
    func stopLoaders() {
        self.scheduleViewModel.isSchedulersListFetched = true
        self.tableViewSchedulesList.isAPIstillWorking = false
        self.tableViewSchedulesList.stopPullToRefresh()
        self.tableViewSchedulesList.reloadData()
    }
    
    //============================ Enable Disable Scheduler  ============================
    func callEnableDisableSchedulerAPI(status: Bool,id:Int, complitionBlock: @escaping (Bool)->()) {
        let param: [String: Any] = ["status":status ? 1 : 2, "id":id]
        API_SERVICES.callAPI(path: .scheduleEnableDisable(param),method: .put) { (parsingResponse) in
            if let jsonResponse = parsingResponse {
                debugPrint(jsonResponse)
                complitionBlock(status)
            }
        } failureInform: {
            complitionBlock(!status)
        }
    }
    
    // delete all schedule
    func callDeleteAllScheduleAPI() {
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .deleteAllSchedules, method: .put) { [self] (parsingResponse) in
//            API_LOADER.dismiss(animated: true)
            if let jsonResponse = parsingResponse{
                debugPrint(jsonResponse)
                CustomAlertView.init(title: jsonResponse["message"]?.stringValue ?? "", forPurpose: .success).showForWhile(animated: true)
                self.callGetSchedulesListAPI(isPullToRefresh: true)
            }
        }
    }
}
