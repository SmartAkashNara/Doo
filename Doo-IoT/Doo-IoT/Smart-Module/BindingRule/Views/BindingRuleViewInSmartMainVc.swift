//
//  BindingRuleViewInSmartMainVc.swift
//  Doo-IoT
//
//  Created by Shraddha on 16/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

var SMARTRULE_OFFLINE_LOAD_ENABLE = false

class BindingRuleViewInSmartMainVc: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var dooNoDataView: DooNoDataView_1!
    @IBOutlet weak var mainView: SomethingWentWrongAlertView! {
        didSet {
            mainView.delegateOfSWWalert = self
        }
    }
    @IBOutlet weak var tableViewBindingRulesList: SayNoForDataTableView! {
        didSet {
            tableViewBindingRulesList.delegate = self
            tableViewBindingRulesList.dataSource = self
        }
    }
    
    // MARK: - Variable declaration
    var viewModel = SmartMainViewModel()
    var bindingRuleViewModel = BindingRuleViewModel()
    var smartMainVc: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.defaultConfig()
    }
    
    func defaultConfig(viewModel: SmartMainViewModel? = nil, viewController: UIViewController? = nil) {
        if let viewModel = viewModel , let viewController = viewController {
            self.viewModel = viewModel
            self.viewModel.selectdEnumSmartMenuType = .schedule
            self.smartMainVc = viewController
        }
        self.setDummyData()
        self.configureTableView()
    }
    
    func setDummyData() {
        self.tableViewBindingRulesList.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.bindingRuleViewModel.isBindingRulesListFetched = true
            self.bindingRuleViewModel.loadStaticData()
            self.tableViewBindingRulesList.reloadData()
        }
    }
    
    func configureTableView() {
        tableViewBindingRulesList.bounces = true
        tableViewBindingRulesList.registerCellNib(identifier: SmartHomeScheduleTVCell.identifier)
        tableViewBindingRulesList.registerCellNib(identifier: SmartHomeSectionTVCell.identifier)
        tableViewBindingRulesList.registerCellNib(identifier: ThreeStripesWithGapInLastTVCell.identifier)
        
        tableViewBindingRulesList.addRefreshControlForPullToRefresh {
            if SMARTRULE_OFFLINE_LOAD_ENABLE{
                self.tableViewBindingRulesList.stopPullToRefresh()
                self.bindingRuleViewModel.loadStaticData()
                self.loadNoDataPlaceholder()
                return
            }
            // self.callGetSceneListAPI(isPullToRefresh: true)
        }
        
        tableViewBindingRulesList.sayNoSection = .noSchedulerListFound("SCHEDULES")
        tableViewBindingRulesList.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 15, right: 0)
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.000000001))
        tableViewBindingRulesList.tableHeaderView = v
        tableViewBindingRulesList.separatorStyle = .none
        tableViewBindingRulesList.reloadData()
    }
    
    func loadNoDataPlaceholder() {
        self.tableViewBindingRulesList.changeIconAndTitleAndSubtitle(title: "BINDING RULE", detailStr: "No binding rules defined yet", icon: "noDataBinding_rule")
        self.tableViewBindingRulesList.reloadData()
        self.tableViewBindingRulesList.figureOutAndShowNoResults()
    }
    
    func removeObjectAndReload(id:Int){
        self.bindingRuleViewModel.removeSelectedObject(id: id)
        self.loadNoDataPlaceholder()
    }
}

// MARK: API
extension BindingRuleViewInSmartMainVc {
    func getBindingRulesListAPI() { }
}

// MARK: Tableview stuff
extension BindingRuleViewInSmartMainVc: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel.selectdEnumSmartMenuType != nil else {
            return 0
        }
        guard self.bindingRuleViewModel.isBindingRulesListFetched else {
            return 10
        }
        return bindingRuleViewModel.arrayBindingRuleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard viewModel.selectdEnumSmartMenuType != nil else {
            return tableView.getDefaultCell()
        }
        guard self.bindingRuleViewModel.isBindingRulesListFetched else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ThreeStripesWithGapInLastTVCell.identifier) as! ThreeStripesWithGapInLastTVCell
            cell.startAnimating(index: indexPath.row)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeScheduleTVCell.identifier) as! SmartHomeScheduleTVCell
        cell.cellConfigWithBindingRuleDataModel(object: bindingRuleViewModel.arrayBindingRuleList[indexPath.row])
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
extension BindingRuleViewInSmartMainVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeSectionTVCell.identifier) as! SmartHomeSectionTVCell
        
        guard viewModel.selectdEnumSmartMenuType != nil else {
            return nil
        }
        
        cell.cellConfig(title: SmartMainViewModel.EnumSmartMenuType.bindingRule.title.uppercased())
        cell.buttonPlus.tag = section
        cell.buttonPlus.addTarget(self, action: #selector(cellAddDeviceClicked(sender:)), for: .touchUpInside)
        cell.buttonDots.tag = section
        cell.buttonDots.addTarget(self, action: #selector(cellButtonMoreClicked(sender:)), for: .touchUpInside)
        cell.buttonDots.isHidden = true
        return cell
    }
    
    @objc func cellButtonMoreClicked(sender:UIButton){
        debugPrint("cellButtonMoreClicked...")
    }
    @objc func cellAddDeviceClicked(sender:UIButton){
        guard let addEditBindingRuleVC = UIStoryboard.smart.addEditBindingRuleVC else { return }
        addEditBindingRuleVC.didAddedOrUpdatedSmartRule = { smartRuleModel in
            if let objectModel = smartRuleModel{
                self.addOrUpdateBindingRule(objectModel: objectModel)
            }
        }
        addEditBindingRuleVC.hidesBottomBarWhenPushed = true
        self.smartMainVc?.navigationController?.pushViewController(addEditBindingRuleVC, animated: true)
    }
    
    func addOrUpdateBindingRule(objectModel: SRBindingRuleDataModel){
        if let index = self.bindingRuleViewModel.arrayBindingRuleList.firstIndex(where: {$0.id == objectModel.id}){
            self.bindingRuleViewModel.arrayBindingRuleList[index] = objectModel
        }else{
            self.bindingRuleViewModel.arrayBindingRuleList.append(objectModel)
        }
        self.tableViewBindingRulesList.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let smartRuleDetailVC = UIStoryboard.smart.smartRuleDetailVC else { return }
        smartRuleDetailVC.enumSmartMenuType = .bindingRule
        smartRuleDetailVC.hidesBottomBarWhenPushed = true
        smartRuleDetailVC.dataModdel = (self.bindingRuleViewModel.arrayBindingRuleList[indexPath.row], nil, nil)
        self.smartMainVc?.navigationController?.pushViewController(smartRuleDetailVC, animated: true)
    }
}

extension BindingRuleViewInSmartMainVc {
    
    func cellSwitchValueChanged(_ sender: DooSwitch) {
        guard viewModel.selectdEnumSmartMenuType != nil else { return }
        
        if SMARTRULE_OFFLINE_LOAD_ENABLE{
            self.bindingRuleViewModel.arrayBindingRuleList[sender.tag].enable = !self.bindingRuleViewModel.arrayBindingRuleList[sender.tag].enable
            self.tableViewBindingRulesList.reloadData()
            return
        }
        /*
         callEnableDisableSchedulerAPI(status: !sender.isOn,id: self.bindingRuleViewModel.arrayBindingRuleList[sender.tag].id) { (status) in
         self.bindingRuleViewModel.arrayBindingRuleList[sender.tag].enable = status
         self.tableViewGroupDetail.reloadData()
         }
         */
    }
}

// MARK: - internet & something went wrong work
extension BindingRuleViewInSmartMainVc: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
        self.mainView.forPurpose = .somethingWentWrong
        self.mainView.dismissSomethingWentWrong()
        // self.callGetBindingRuleListAPI()
    }
    
    // not from delegates
    func showInternetOffAlert() {
        self.mainView.showInternetOff()
    }
    func showSomethingWentWrongAlert() {
        self.mainView.showSomethingWentWrong()
    }
}

extension BindingRuleViewInSmartMainVc: DooNoDataView_1Delegate {
    func showNoEnterpriseView() {
        self.tableViewBindingRulesList.isScrollEnabled = false
        self.dooNoDataView.initSetup(.noEnterprises)
        self.dooNoDataView.allocateView()
        self.dooNoDataView.delegate = self
    }
    
    func dismissNoEnterpriseView() {
        self.dooNoDataView.delegate = nil
        self.tableViewBindingRulesList.isScrollEnabled = true
        self.dooNoDataView.dismissView()
    }
}

// MARK: - UIScrollViewDelegate
extension BindingRuleViewInSmartMainVc: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            
            // pagination
            if bindingRuleViewModel.getTotalElements > bindingRuleViewModel.getAvailableElements &&
                !tableViewBindingRulesList.isAPIstillWorking {
                // self.callGetBindingRuleListAPI(isNextPageRequest: true)
            }
        }
    }
}
