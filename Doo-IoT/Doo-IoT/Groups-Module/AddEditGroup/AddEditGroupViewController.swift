//
//  AddEditGroupViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 16/12/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import TagListView

class AddEditGroupViewController: UIViewController {
    
    enum EnumAddGroupScreenFlow {
        case fromEnterprise(UIViewController) , fromGroup, fromGroupWithoutDevices
    }
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var textFiledAddGroupeName: DooTextfieldView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var viewNavigationBarDetail: DooNavigationBarDetailView_1!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var labelTagTitle: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    var enumAddGroupScreenFlow: EnumAddGroupScreenFlow = .fromGroupWithoutDevices
    var addGroupViewModel: AddGroupViewModel = AddGroupViewModel()
    
    var isEditFlow: Bool = false
    var arrayGroupSuggested = [GroupDataModel]()
    weak var groupModel: GroupDataModel? = nil
    var didAddedOrUpdatedGroup:((GroupDataModel, Bool)->())? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        configureTagList()
        
        loadEditFlowData()
        getSuggestions()
    }
    
    func configureTagList(){
        tagListView.textFont = UIFont.Poppins.medium(12)
        tagListView.alignment = .leading
        tagListView.delegate = self
    }
    
    // data setting in case of edit flow
    func loadEditFlowData() {
        
        guard let viewModoelGroupDetail = groupModel else {
            return
        }
        
        if isEditFlow{
            textFiledAddGroupeName.setText = viewModoelGroupDetail.name
        }
    }
    
    func prepareTagInTagList() {
        tagListView.removeAllTags()
        
        arrayGroupSuggested.forEach { (obj) in
            tagListView.addTag(obj.name)
        }
        
        var tagCount = 0
        tagListView.tagViews.forEach { (obj) in
            obj.isSelected = arrayGroupSuggested[tagCount].tabSelected
            obj.tag = tagCount
            tagCount += 1
        }
    }
    
    func redirectDeviceListToAddGroup() {
        guard let userPrivilegesVC = UIStoryboard.enterpriseUsers.userPrivilegesVC else {
            return
        }
        userPrivilegesVC.redirectedFrom = .createGroupDevicesSelection
        userPrivilegesVC.objAddGroupVC = self
        self.navigationController?.pushViewController(userPrivilegesVC, animated: true)
    }
}

// MARK: - Action listeners
extension AddEditGroupViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func setSelectedEnterrpiseGroup(groupMasterId: Int){
        switch enumAddGroupScreenFlow {
        case .fromEnterprise(let vc):
            if let vcObject =  vc as? SelectEnterpriseGroupsViewController{
                if let index = vcObject.selectEnterpriseGroupsViewModel.arrayGroups.firstIndex(where: {$0.groupMasterId == groupMasterId}){
                    guard !vcObject.selectEnterpriseGroupsViewModel.arrayGroups[index].groupOfAddTime else { return }
                    vcObject.selectEnterpriseGroupsViewModel.checkUncheckMainList(index: index)
                    vcObject.reloadLists(tableIndexPath: IndexPath.init(row: index, section: 0))
                }
            }
        default:
            break
        }
    }
    
    @IBAction func submitActionListener(_ sender: UIButton) {
        if textFiledAddGroupeName.isValidated(){
            switch enumAddGroupScreenFlow {
            case .fromEnterprise(let vc):
                let selectedTag = arrayGroupSuggested.filter({$0.tabSelected }).first?.id
                
                if let vcObject =  vc as? SelectEnterpriseGroupsViewController{
                    let objModel = GroupDataModel()
                    objModel.name = textFiledAddGroupeName.getText ?? ""
                    if let masterId = selectedTag{
                        objModel.groupMasterId = String(masterId)
                        // self.setSelectedEnterrpiseGroup(groupMasterId: masterId)
                    }
                    vcObject.addedNewGroup(data: objModel)
                    self.navigationController?.popViewController(animated: true)
                }
            case .fromGroupWithoutDevices:
                if isEditFlow{
                    debugPrint("call update group api")
                    callUpdateGroupAPI()
                }else{
                    callAddGroupAPI()
                    debugPrint("call add groupe api ")
                }
            case .fromGroup:
                if isEditFlow{
                    debugPrint("call update group api")
                    callUpdateGroupAPI()
                }else{
                    redirectDeviceListToAddGroup()
                    debugPrint("call add groupe api ")
                }
            }
        }
    }
}

// MARK: - User defined methods
extension AddEditGroupViewController {
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        
        var title = ""
        
        switch enumAddGroupScreenFlow {
        case .fromEnterprise(_):
            title = "Create Group"
        case .fromGroup, .fromGroupWithoutDevices:
            title = isEditFlow ? localizeFor("edit_group").capitalized : localizeFor("add_Group")
        }
        
        viewNavigationBarDetail.viewConfig(
            title: title,
            subtitle: isEditFlow ? "Here you can edit group Name" : "Here you can create new group")
        navigationTitle.text = title
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
        
        
        labelTagTitle.font = UIFont.Poppins.regular(10)
        labelTagTitle.text = localizeFor("suggestions_your_group_name")
        labelTagTitle.textColor = UIColor.blueHeadingAlpha60
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonSave.setThemeAppBlueWithArrow(isEditFlow ? cueAlert.Button.update : cueAlert.Button.submit)
        buttonSave.isHidden = false
        
        textFiledAddGroupeName.titleValue = localizeFor("group_Name")
        textFiledAddGroupeName.textfieldType = .generic
        textFiledAddGroupeName.genericTextfield?.addThemeToTextarea(localizeFor("enter_group_name"))
        textFiledAddGroupeName.genericTextfield?.returnKeyType = .done
        textFiledAddGroupeName.genericTextfield?.clearButtonMode = .whileEditing
        textFiledAddGroupeName.genericTextfield?.delegate = self
        textFiledAddGroupeName.activeBehaviour = true
        textFiledAddGroupeName.genericTextfield?.addTarget(self, action: #selector(didChangeTextfield(sender:)), for: .editingChanged)
        textFiledAddGroupeName.validateTextForError = { textFieldValue in
            if InputValidator.checkEmpty(value: textFieldValue?.trimSpace()){
                return localizeFor("group_name_is_required")
            }
            
            if !InputValidator.isRange(textFieldValue?.trimSpace(), lowerLimit: 2, uperLimit: 40){
                return "Group name length should be between 2 to 40 characters"
            }
            return nil
        }
    }
    
    @objc func didChangeTextfield(sender:UITextField) {
        if !sender.text!.isEmpty, let index = arrayGroupSuggested.firstIndex(where: {$0.name.lowercased() == sender.text!.lowercased()}){
            unSelectedTag()
            arrayGroupSuggested[index].tabSelected = true
            tagListView.tagViews[index].isSelected = true
            groupModel?.groupMasterId = String(arrayGroupSuggested[index].id)
        }else{
            unSelectedTag()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddEditGroupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UITextFieldDelegate
extension AddEditGroupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        unSelectedTag()
        return true
    }
}

extension AddEditGroupViewController : TagListViewDelegate{
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        var allreadySelected = false
        if tagView.isSelected{
            allreadySelected = true
        }
        
        unSelectedTag()
        tagView.isSelected = !allreadySelected
        textFiledAddGroupeName.setText = allreadySelected ? "" : title
        groupModel?.groupMasterId = String(arrayGroupSuggested[sender.tag].id)
        arrayGroupSuggested[sender.tag].tabSelected = tagView.isSelected
    }
    
    func unSelectedTag(){
        tagListView.tagViews.forEach { (objTag) in
            objTag.isSelected = false
        }
        arrayGroupSuggested.forEach { (obj) in
            obj.tabSelected = false
        }
    }
}

// MARK: Suggestions for Add Group.
extension AddEditGroupViewController {
    func getSuggestions() {
        switch enumAddGroupScreenFlow {
        case .fromEnterprise(let vc):
            if let vcObject =  vc as? SelectEnterpriseGroupsViewController{
                self.arrayGroupSuggested = vcObject.selectEnterpriseGroupsViewModel.arrayGroups.map({ enterpriseGroup in
                    return GroupDataModel.init(group: enterpriseGroup)
                })
                self.prepareTagInTagList()
            }
            /*
            API_LOADER.show(animated: true)
            API_SERVICES.callAPI(path: .getGroups(false), method: .post) { [weak self] parsingResponse in
                API_LOADER.dismiss(animated: true)
                debugPrint("parsing response: \(parsingResponse)")
                if let json = parsingResponse, let selfStrong = self{
                    
                    guard let payload = json["payload"]?.dictionary else { return  }
                    var groupArrays = [GroupDataModel]()
                    if let arrayPlatformGroup = payload["platformGroup"]?.arrayValue{
                        for group in arrayPlatformGroup {
                            groupArrays.append(GroupDataModel.init(dict: group))
                        }
                    }
                    
                    if let arraySelectedGroup = payload["selectedGroup"]?.arrayValue{
                        for group in arraySelectedGroup {
                            groupArrays.append(GroupDataModel.init(dict: group))
                        }
                    }
                    
                    selfStrong.arrayGroupSuggested = groupArrays
                    selfStrong.prepareTagInTagList()
                }
            } failureInform: {
                API_LOADER.dismiss(animated: true)
            }
 */
        case .fromGroup, .fromGroupWithoutDevices:
            guard let enterpriseTypeIdStrong = APP_USER?.selectedEnterprise?.id else { return }
            API_LOADER.show(animated: true)
            API_SERVICES.callAPI(path: .getEnterpriseWiseGroupsFilter(enterpriseTypeIdStrong), method:.post) { [weak self] (parsingResponse) in
                API_LOADER.dismiss(animated: true)
                if let json = parsingResponse, let selfStrong = self{
                    
                    // append data in array
                    var groupArray = [GroupDataModel]()
                    guard let arrayContent = json["payload"]?.dictionary?["content"]?.arrayValue else { return }
                    for obj in arrayContent{
                        groupArray.append(GroupDataModel.init(dict: obj))
                    }
                    
                    selfStrong.arrayGroupSuggested = groupArray
                    // selfStrong.setSelectedTag()
                    selfStrong.prepareTagInTagList()
                }
            } failure: { (msg) in
                API_LOADER.dismiss(animated: true)
            }
        }
    }
    
    func setSelectedTag(){
        switch enumAddGroupScreenFlow {
        case .fromEnterprise(let vc):
            if let vcObject =  vc as? SelectEnterpriseGroupsViewController{
                let idsGroup = vcObject.selectEnterpriseGroupsViewModel.arraySelectedGroups.map({$0.id})
                self.arrayGroupSuggested.forEach { (objGroup) in
                    if idsGroup.contains(objGroup.id){
                        objGroup.tabSelected = true
                    }
                }
            }
        default:
            break
        }
    }
}

// MARK: Add group API.
extension AddEditGroupViewController {
    func callCreateGroupsAPI(applienceIds:[Int]) {
        var param:[String:Any] = ["name":self.textFiledAddGroupeName.getText ?? ""]
        
        if applienceIds.count != 0{
            param["applianceId"] = applienceIds //<--- application id
        }
        if let id  = groupModel?.groupMasterId{
            param["groupMasterId"] = id
        }
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .createGroup, method:.post) { [weak self] (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let json = parsingResponse?["payload"], let selfStrong = self{
                let groupDataModel = GroupDataModel.init(dict: json)
                selfStrong.didAddedOrUpdatedGroup?(groupDataModel, false)
                selfStrong.groupModel?.groupMasterId = nil
                selfStrong.navigationController?.popViewController(animated: true)
            }
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
}

// MARK: Update group API.
extension AddEditGroupViewController {
    func callAddGroupAPI() {
        self.callCreateGroupsAPI(applienceIds: [])
    }
    func callUpdateGroupAPI() {
        guard let id = groupModel?.id else { return }
        let param: [String: Any] = ["groupId": id,
                                    "name":self.textFiledAddGroupeName.getText ?? "" ]
        
        API_LOADER.show(animated: true)
        API_SERVICES.callAPI(param, path: .updateGroupName(id), method:.put) { [weak self] (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            if let _ = parsingResponse?["payload"]?.dictionary, let selfStrong = self{
                let dataModel = GroupDataModel.init(withGroupList: JSON.init(["name":selfStrong.textFiledAddGroupeName.getText ?? "", "id":id]))
                selfStrong.didAddedOrUpdatedGroup?(dataModel, true)
                selfStrong.navigationController?.popViewController(animated: true)
            }
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
}

// MARK: Dummy Data.
extension AddEditGroupViewController {
    // setting dummy data for suggestions
    func setDummyDataForSuggestions() {
        arrayGroupSuggested = [
            GroupDataModel.init(id: 0, title: "Hall", deviceType: 1, online: false),
            GroupDataModel.init(id: 1, title: "Bed Room", deviceType: 1, online: false),
            GroupDataModel.init(id: 2, title: "Study", deviceType: 1, online: false),
            GroupDataModel.init(id: 3, title: "Hall 2", deviceType: 1, online: false),
            GroupDataModel.init(id: 4, title: "Kitchen", deviceType: 1, online: false),
            GroupDataModel.init(id: 5, title: "Play area", deviceType: 1, online: false),
            GroupDataModel.init(id: 6, title: "Party Hall", deviceType: 1, online: false),
            GroupDataModel.init(id: 7, title: "Dining", deviceType: 1, online: false),
            GroupDataModel.init(id: 8, title: "Garden", deviceType: 1, online: false)]
        self.prepareTagInTagList()
    }
}
