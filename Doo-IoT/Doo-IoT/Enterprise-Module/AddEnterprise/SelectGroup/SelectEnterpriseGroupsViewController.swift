//
//  SelectEnterpriseGroupsViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SelectEnterpriseGroupsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var collectionViewSelectedGroups: UICollectionView!
    @IBOutlet weak var labelNoteTitle: UILabel!
    @IBOutlet weak var labelNoteDetail: UILabel!
    @IBOutlet weak var viewTopSeparator: UIView!
    @IBOutlet weak var tableViewEnterpriseGroups: SayNoForDataTableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var viewNote: UIView!
    
    // MARK: - Variables
    var selectEnterpriseGroupsViewModel = SelectEnterpriseGroupsViewModel()
    var preSelectedGroupsForEditEnterpriseMode = [EnterpriseGroup]()
    var enterpriseTypeId: String?
    
    var enterpriseId: String? // When user is in edit mode.
    var isEditFlow = false
    
    weak var objAddEnterpriseVC: AddEnterpriseViewController? = nil
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureTableView()
        setDefaults()
        // clearDataAndRefreshUI()
        callGetEnterpriseGroupsAPI()
    }
}

// MARK: - User defined methods
extension SelectEnterpriseGroupsViewController {
    func configureCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 9
        flowLayout.minimumInteritemSpacing = 9
        flowLayout.sectionInset = UIEdgeInsets(top: 13, left: 20, bottom: 13, right: 20)
        flowLayout.scrollDirection = .horizontal
        
        collectionViewSelectedGroups.dataSource = self
        collectionViewSelectedGroups.delegate = self
        collectionViewSelectedGroups.setCollectionViewLayout(flowLayout, animated: false)
        collectionViewSelectedGroups.registerCellNib(identifier: DooCollectionTag_1CVCell.identifier, commonSetting: true)
    }
    
    func configureTableView() {
        tableViewEnterpriseGroups.dataSource = self
        tableViewEnterpriseGroups.delegate = self
        tableViewEnterpriseGroups.registerCellNib(identifier: DooTree_1TVCell.identifier, commonSetting: true)
        tableViewEnterpriseGroups.sayNoSection = .noGroupsListFound("Groups")
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        updateScreenTitle()
        
        labelNoteTitle.font = UIFont.Poppins.medium(12)
        labelNoteTitle.textColor = UIColor.blueHeadingAlpha60
        labelNoteTitle.text = localizeFor("note_title")
        
        labelNoteDetail.font = UIFont.Poppins.regular(12)
        labelNoteDetail.textColor = UIColor.blueHeadingAlpha60
        labelNoteDetail.numberOfLines = 0
        labelNoteDetail.text = localizeFor("note_detail_group")
        
        viewTopSeparator.backgroundColor = UIColor.blueHeadingAlpha06
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonAdd.setImage(UIImage(named: "imgAddButton"), for: .normal)
        buttonSave.setThemeAppBlueWithArrow(cueAlert.Button.save)
        buttonSave.isHidden = false
        
        checkTagsVisibility(animated: false)
    }
}

// MARK: API Service
extension SelectEnterpriseGroupsViewController {
    func callGetEnterpriseGroupsAPI() {
        guard let enterpriseTypeIdStrong = enterpriseTypeId else { return }
        let param:[String:Any] = ["page": 0,
                                  "size": UInt8.max,
                                  "sort": ["column": "enterpriseTypeId",
                                           "sortType": "asc"
                                  ],
                                  "criteria": [
                                    ["column": "enterpriseTypeId",
                                     "operator": "=",
                                     "values": [enterpriseTypeIdStrong]
                                    ]
                                  ]
        ]
        
        API_LOADER.show(animated: true)
        selectEnterpriseGroupsViewModel.callGetEnterpriseGroupsAPI(arrayPreSelectedGroups: self.preSelectedGroupsForEditEnterpriseMode,
                                                                   param: param,
                                                                   isUpdate: isEditFlow,
                                                                   enterpriseID: self.enterpriseId ?? "") {
            API_LOADER.dismiss(animated: true)
            if let objEnterpriseAddVC = self.objAddEnterpriseVC {
                self.selectEnterpriseGroupsViewModel.addPreservedNewlyAddedGroupsTillAddEnterpriseDeinits(arrayManuallyAdded: objEnterpriseAddVC.preserveNewlyAddedGroupsTillUserInAddEnterprise)
            }
            self.reloadLists(tableIndexPath: nil)
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
            // debugPrint("")
        } failureInform: {
            DooAPILoader.shared.stopLoading()
        }
    }
}

// MARK: Helpful functions
extension SelectEnterpriseGroupsViewController {
    func updateScreenTitle() {
        var title = self.isEditFlow ? localizeFor("selected_groups") : "Select Groups"
        if !selectEnterpriseGroupsViewModel.arraySelectedGroups.count.isZero() {
            title += "(\(selectEnterpriseGroupsViewModel.arraySelectedGroups.count))"
        }
        navigationTitle.text = title
    }
    
    func clearDataAndRefreshUI() {
        selectEnterpriseGroupsViewModel.arrayGroups.removeAll()
        selectEnterpriseGroupsViewModel.arraySelectedGroups.removeAll()
        reloadLists(tableIndexPath: nil)
    }
    
    func reloadLists(tableIndexPath: IndexPath?) {
        updateScreenTitle()
        if let tableIndexPath = tableIndexPath {
            tableViewEnterpriseGroups.reloadRows(at: [tableIndexPath], with: .fade)
        } else {
            tableViewEnterpriseGroups.reloadData()
        }
        
        tableViewEnterpriseGroups.figureOutAndShowNoResults()
        
        collectionViewSelectedGroups.reloadData()
        if let selectedGroupLastIndexPath = selectEnterpriseGroupsViewModel.selectedGroupLastIndexPath() {
            collectionViewSelectedGroups.selectItem(at: selectedGroupLastIndexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.right)
        }
        checkTagsVisibility(animated: true)
        buttonSave.isHidden = selectEnterpriseGroupsViewModel.arrayGroups.count.isZero()
    }
    
    func checkTagsVisibility(animated: Bool) {
        func hideShow(isHidden: Bool) {
            viewNote.isHidden = isHidden
            viewNote.alpha = isHidden.isHiddenToAlpha
            collectionViewSelectedGroups.isHidden = isHidden
            collectionViewSelectedGroups.alpha = isHidden.isHiddenToAlpha
        }
        let isHidden = selectEnterpriseGroupsViewModel.arraySelectedGroups.count.isZero()
        guard viewNote.isHidden != isHidden else { return }
        if animated {
            UIView.animate(withDuration: 0.3) {
                hideShow(isHidden: isHidden)
            }
        } else {
            hideShow(isHidden: isHidden)
        }
    }
}

// MARK: - Action listeners
extension SelectEnterpriseGroupsViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func addActionListener(_ sender: UIButton) {
        guard let groupVC = UIStoryboard.group.addGroupVC else { return }
        groupVC.enumAddGroupScreenFlow = .fromEnterprise(self)
        groupVC.didAddedOrUpdatedGroup = { [weak self] (dataModel, isUpdated) in
            if !isUpdated{
                self?.addedNewGroup(data: dataModel)
            }
        }
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
    func addedNewGroup(data: GroupDataModel?) {
        guard let dataModel = data else { return }
        
        let arrayNames = selectEnterpriseGroupsViewModel.arrayGroups.map({$0.name.lowercased()})
        if dataModel.enumGroupType == .simpleGroup{
            // When user will come here in this case????
            if !arrayNames.contains(dataModel.name.lowercased()){
                objAddEnterpriseVC?.preserveNewlyAddedGroupsTillUserInAddEnterprise.append(EnterpriseGroup.init(fromAddGroup: dataModel))
                selectEnterpriseGroupsViewModel.arrayGroups.append(EnterpriseGroup.init(fromAddGroup: dataModel))
            }
            tableViewEnterpriseGroups.reloadData()
        }else{
            let namesArray = selectEnterpriseGroupsViewModel.arraySelectedGroups.map({$0.name})
            if let indexRow = selectEnterpriseGroupsViewModel.arrayGroups.firstIndex(where: {$0.name.lowercased() == dataModel.name.lowercased()}){
                // If same group name found. just select it again if not selected
                let selectedGroup = selectEnterpriseGroupsViewModel.arrayGroups[indexRow]
                if !namesArray.contains(selectedGroup.name){
                    selectEnterpriseGroupsViewModel.arraySelectedGroups.append(selectedGroup)
                }
                
                selectEnterpriseGroupsViewModel.arrayGroups[indexRow].checked = true
                reloadLists(tableIndexPath: IndexPath.init(row: indexRow, section: 0))
            }else{
                // Not sure about this case, that when this case will be trigger. Still code has been kept as it is for later use or testing.
                let enterpise = EnterpriseGroup.init(fromAddGroup: dataModel)
                enterpise.checked = true
                if !arrayNames.contains(dataModel.name.lowercased()){
                    selectEnterpriseGroupsViewModel.arrayGroups.append(enterpise)
                }
            }
        }
        tableViewEnterpriseGroups.reloadData()
        tableViewEnterpriseGroups.figureOutAndShowNoResults()
    }
    
    @IBAction func saveActionListener(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindSegueFromSelectEnterpriseGroupsToAddEnterprise", sender: nil)
    }
}

// MARK: - UITableViewDataSource
extension SelectEnterpriseGroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectEnterpriseGroupsViewModel.arrayGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooTree_1TVCell.identifier, for: indexPath) as! DooTree_1TVCell
        cell.cellConfig(data: selectEnterpriseGroupsViewModel.arrayGroups[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SelectEnterpriseGroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !selectEnterpriseGroupsViewModel.arrayGroups[indexPath.row].groupOfAddTime else { return }
        selectEnterpriseGroupsViewModel.checkUncheckMainList(index: indexPath.row)
        reloadLists(tableIndexPath: indexPath)
    }
}

// MARK: - UICollectionViewDataSource
extension SelectEnterpriseGroupsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectEnterpriseGroupsViewModel.arraySelectedGroups.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DooCollectionTag_1CVCell.identifier, for: indexPath) as! DooCollectionTag_1CVCell
        cell.cellConfig(title: selectEnterpriseGroupsViewModel.arraySelectedGroups[indexPath.row].name,
                        disable: selectEnterpriseGroupsViewModel.arraySelectedGroups[indexPath.row].groupOfAddTime)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SelectEnterpriseGroupsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return DooCollectionTag_1CVCell.getCellSize(tag: selectEnterpriseGroupsViewModel.arraySelectedGroups[indexPath.row].name)
    }
}

// MARK: - UICollectionViewDelegate
extension SelectEnterpriseGroupsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !selectEnterpriseGroupsViewModel.arraySelectedGroups[indexPath.row].groupOfAddTime else { return }
        let arrayNames = objAddEnterpriseVC?.preserveNewlyAddedGroupsTillUserInAddEnterprise.map({$0.name}) ?? []
        var index = 0
        if arrayNames.contains(selectEnterpriseGroupsViewModel.arraySelectedGroups[indexPath.row].name){
            index = selectEnterpriseGroupsViewModel.removeSelectedGroup(index: indexPath.row,isManuallyAddedGroup: true)
        }else{
            index = selectEnterpriseGroupsViewModel.removeSelectedGroup(index: indexPath.row)
        }
        reloadLists(tableIndexPath: IndexPath(row: index, section: 0))
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SelectEnterpriseGroupsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
