//
//  SelectSceneListViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 27/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit
class SelectSceneListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var tableViewSceneList: SayNoForDataTableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonSave: UIButton!
    
    var selectedRow = -1
    weak var objSceneViewInMainVC: SceneViewInSmartMainVc? = nil
    private var arrayOfDefaultSceneList = [SRScenePredefinedDataModel]()
    var isEditFlow: Bool = false
    var selectedSceneDataModel: SRSceneDataModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setDefaults()
        getSceneList()
    }
    
    func setDefaults() {
        buttonSave.setThemeAppBlueWithArrow(localizeFor("next_button"))
        buttonSave.tintColor = UIColor.white
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.text = localizeFor("select_scene")
        
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        self.enableDisableNextButton()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if selectedRow != -1 {
//            self.setSelectedScene()
//            self.tableViewSceneList.reloadData()
//            self.enableDisableNextButton()
//        }
//    }
    
    // Next button will be enabled only if we have records in default scenes.
    func enableDisableNextButton() {
        buttonSave.alpha = (self.arrayOfDefaultSceneList.count > 0 && self.selectedSceneDataModel != nil) ? 1 : 0.5
        buttonSave.isUserInteractionEnabled = (self.arrayOfDefaultSceneList.count > 0 && self.selectedSceneDataModel != nil) ? true : false
    }
    
    func setSelectedScene() {
        for i in 0..<self.arrayOfDefaultSceneList.count {
            if selectedRow == i {
                self.arrayOfDefaultSceneList[i].isSelected = true
            } else {
                self.arrayOfDefaultSceneList[i].isSelected = false
            }
        }
    }
    
    func configureTableView() {
        tableViewSceneList.dataSource = self
        tableViewSceneList.delegate = self
        tableViewSceneList.registerCellNib(identifier: SmartHomeSceneTVCell.identifier, commonSetting: true)
        tableViewSceneList.registerCellNib(identifier: DefaultScenesHeaderTVCell.identifier, commonSetting: true)
        tableViewSceneList.addRefreshControlForPullToRefresh {
            self.getSceneList(isFromPullToRefresh: true)
        }
        tableViewSceneList.sayNoSection = .none
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.000000001))
        tableViewSceneList.tableHeaderView = v
        
        tableViewSceneList.separatorStyle = .none
    }
}

// MARK: - Action Listeners
extension SelectSceneListViewController {
    @IBAction func buttonBackClicked(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonSaveClicked(_ sender:UIButton){
        DispatchQueue.getMain(delay: 0.2) {
            self.selectedRow = -1 // here removed selected once next tapp button for next screen
            self.tableViewSceneList.reloadData()
        }
        
        guard self.selectedSceneDataModel != nil else {
            return
        }
        guard let addEditSceneVC = UIStoryboard.smart.addEditSceneVC else { return }
        addEditSceneVC.didAddedOrUpdatedScene = { dataModel in
            guard let objDataModel = dataModel else { return }
            self.objSceneViewInMainVC?.addOrUpdateScene(objectModel: objDataModel)
        }
        addEditSceneVC.sceneDataModel = self.selectedSceneDataModel
        addEditSceneVC.isEditFlow = self.isEditFlow
        addEditSceneVC.arraySceneDefultList = self.arrayOfDefaultSceneList
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addEditSceneVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SelectSceneListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrayOfDefaultSceneList.count > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDefaultSceneList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartHomeSceneTVCell.identifier) as! SmartHomeSceneTVCell
        var sceneObject = arrayOfDefaultSceneList[indexPath.row]
        sceneObject.isSelected = (selectedRow == indexPath.row)
        cell.cellConfigForSceneSelectionList(dataModel: sceneObject)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SelectSceneListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DefaultScenesHeaderTVCell.identifier) as! DefaultScenesHeaderTVCell
        return self.arrayOfDefaultSceneList.count > 0 ? cell : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = selectedRow == indexPath.row ? -1 : indexPath.row
        self.selectedSceneDataModel = selectedRow == -1 ? nil : SRSceneDataModel.init(withScenePredefined: arrayOfDefaultSceneList[selectedRow])
        self.enableDisableNextButton()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.arrayOfDefaultSceneList.count > 0 ? 29 : 0
    }
}

// MARK: - Initial Handlings
extension SelectSceneListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        navigationController.interactivePopGestureRecognizer?.isEnabled = !isRootVC
    }
}

// MARK: - APis
extension SelectSceneListViewController {
    
    func getSceneList(isFromPullToRefresh: Bool = false) {
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(path: .getDefaultSceneList, method:.get) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if isFromPullToRefresh {
                self.tableViewSceneList.stopPullToRefresh()
            }
            if let jsonResponse = parsingResponse {
                guard let payload = jsonResponse["payload"]?.dictionaryValue["data"]?.arrayValue
                else {
                    return
                }
                if isFromPullToRefresh {
                    self.arrayOfDefaultSceneList.removeAll()
                }
                for objScene in payload {
                    self.arrayOfDefaultSceneList.append(SRScenePredefinedDataModel.init(param: objScene))
                }
                self.tableViewSceneList.reloadData()
                self.enableDisableNextButton()
            }
        } failure: { (failureMessage) in
            
        } internetFailure: {
            
        } failureInform: {
            if isFromPullToRefresh {
                self.tableViewSceneList.stopPullToRefresh()
            }
            API_LOADER.dismiss(animated: true)
        }
    }
}
