//
//  AddEditSchedulerViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 21/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class AddEditSchedulerViewController: CardBaseViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var textFieldViewSchedulerName: DooTextfieldView!
    @IBOutlet weak var textFieldViewSchedulerType: DooTextfieldView!
    @IBOutlet weak var textFieldViewSchedulerDate: DooTextfieldView!
    @IBOutlet weak var textFieldViewSchedulerTime: DooTextfieldView!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var buttonAddApplience: UIButton!
    @IBOutlet weak var labelApplieneTitle: UILabel!
    @IBOutlet weak var tableViewScheduleDetail: UITableView!
    
    @IBOutlet weak var imageViewBottomGradient: UIImageView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableSectionFooterView: UIView!
    
    private var addEditSchedulerViewModel = AddEditSchedulerViewModel()
    var schedulerDataModel: SRSchedulerDataModel!
    private var isEdit:Bool{
        return schedulerDataModel != nil
    }
    
    private var arrayOfTargetdApplience = [TargetApplianceDataModel]()
    private var apiSubmitTime = ""
    private var daysStr = ""
    var didAddedOrUpdatedScheduler:((SRSchedulerDataModel?)->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()
        configureTableView()
        loadData()
        enableDisableSaveButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
}

// MARK: - User defined methods
extension AddEditSchedulerViewController {
    func setDefaults() {
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        let title = isEdit ? localizeFor("edit_scheduler") : localizeFor("add_scheduler")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        
        labelApplieneTitle.text = localizeFor("target_appliance")
        labelApplieneTitle.font = UIFont.Poppins.medium(13)
        labelApplieneTitle.textColor = UIColor.blueHeading
        
        buttonAddApplience.setTitle(localizeFor("target_appliance"), for: .normal)
        buttonAddApplience.titleLabel?.font = UIFont.Poppins.medium(11)
        buttonAddApplience.setTitleColor(UIColor.blueSwitch, for: .normal)
        
        textFieldViewSchedulerName.titleValue = localizeFor("Schedule_name")
        textFieldViewSchedulerName.textfieldType = .generic
        textFieldViewSchedulerName.genericTextfield?.addThemeToTextarea(localizeFor("enter_schedule_name"))
        textFieldViewSchedulerName.genericTextfield?.returnKeyType = .done
        textFieldViewSchedulerName.activeBehaviour = true
        textFieldViewSchedulerName.genericTextfield?.delegate = self
        textFieldViewSchedulerName.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Schedule name is required"
            }
            
            if !InputValidator.isRange(textField, lowerLimit: 2, uperLimit: 40){
                return "Schedule name length should be between 2 to 40 characters"
            }
            return nil
        }
        
        textFieldViewSchedulerType.titleValue = localizeFor("schedule_type")
        textFieldViewSchedulerType.textfieldType = .rightIcon
        textFieldViewSchedulerType.rightIconTextfield?.addThemeToTextarea(localizeFor("select_schedule_type"))
        textFieldViewSchedulerType.rightIconTextfield?.returnKeyType = .done
        textFieldViewSchedulerType.activeBehaviour = true
        textFieldViewSchedulerType.rightIconTextfield?.delegate = self
        textFieldViewSchedulerType.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "imgDropDownArrow")
        textFieldViewSchedulerType.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Schedule type is required"
            }
            return nil
        }
        self.textFieldViewSchedulerType.setText = localizeFor("once").capitalized
        
        textFieldViewSchedulerDate.titleValue = localizeFor("schedule_date")
        textFieldViewSchedulerDate.textfieldType = .rightIcon
        textFieldViewSchedulerDate.rightIconTextfield?.addThemeToTextarea(localizeFor("select_schedule_date"))
        textFieldViewSchedulerDate.rightIconTextfield?.returnKeyType = .done
        textFieldViewSchedulerDate.activeBehaviour = true
        textFieldViewSchedulerDate.rightIconTextfield?.delegate = self
        textFieldViewSchedulerDate.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "calendar1")
        textFieldViewSchedulerDate.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField) && !self.textFieldViewSchedulerDate.isHidden{
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Schedule date is required"
            }
            return nil
        }
        
        textFieldViewSchedulerTime.titleValue = localizeFor("schedule_time")
        textFieldViewSchedulerTime.textfieldType = .rightIcon
        textFieldViewSchedulerTime.rightIconTextfield?.addThemeToTextarea(localizeFor("select_schedule_time"))
        textFieldViewSchedulerTime.rightIconTextfield?.rightIcon = #imageLiteral(resourceName: "imgDropDownArrow")
        textFieldViewSchedulerTime.activeBehaviour = true
        textFieldViewSchedulerTime.rightIconTextfield?.delegate = self
        textFieldViewSchedulerTime.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return SMARTRULE_OFFLINE_LOAD_ENABLE ? nil : "Schedule time is required"
            }
            return nil
        }
        
        //set button type Custom from storyboard
        buttonSubmit.setThemeAppBlueWithArrow(localizeFor(isEdit ? "update_button" : "save_button"))
        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")
    }
    func configureTableView() {
        tableViewScheduleDetail.autolayoutTableViewHeader = tableHeaderView
        tableViewScheduleDetail.autolayoutTableViewFooterHeader = tableSectionFooterView
        tableViewScheduleDetail.dataSource = self
        tableViewScheduleDetail.delegate = self
        tableViewScheduleDetail.registerCellNib(identifier: SmartTargetApplianceTVCell.identifier, commonSetting: true)
        tableViewScheduleDetail.rowHeight = UITableView.automaticDimension
        tableViewScheduleDetail.estimatedRowHeight = 50
    }
    func sizeHeaderToFit() {
        let headerView = tableViewScheduleDetail.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableViewScheduleDetail.tableHeaderView = headerView
    }
    
    func enableDisableSaveButton() {
        buttonSubmit.alpha = (self.checkForAllTextFields() && self.arrayOfTargetdApplience.count > 0) ? 1 : 0.5
        buttonSubmit.isUserInteractionEnabled = (self.checkForAllTextFields() && self.arrayOfTargetdApplience.count > 0) ? true : false
    }
    
    func checkForAllTextFields() -> Bool {
        if textFieldViewSchedulerName.getText?.isEmptyOrDash ?? false || textFieldViewSchedulerType.getText?.isEmptyOrDash ?? false || (textFieldViewSchedulerDate.isHidden == false && textFieldViewSchedulerDate.getText?.isEmptyOrDash ?? false) || textFieldViewSchedulerTime.getText?.isEmptyOrDash ?? false {
            return false
        }
        return true
    }
    
    // load data while edit flow
    func loadData() {
        if let objModel = schedulerDataModel{
            textFieldViewSchedulerName.setText = objModel.schedulerName
            textFieldViewSchedulerType.setText = objModel.enumEnumScheduleType.title
            
            navigationTitle.text = "Edit Schedule"
            arrayOfTargetdApplience = objModel.arrayTargetApplience
            self.tableViewScheduleDetail.reloadData()
            if objModel.enumEnumScheduleType == .daily || objModel.enumEnumScheduleType == .custom {
                textFieldViewSchedulerDate.isHidden = true
            } else {
                textFieldViewSchedulerDate.isHidden = false
                textFieldViewSchedulerDate.setText = objModel.scheduleDate.getDate(format: .eee_dd_mmm_yyyy_hh_mm_ss_z)?.getDateInString(withFormat: .ddSpaceMMspaceYYYY) ?? ""
            }
            self.daysStr = objModel.scheduleDays ?? ""
            self.apiSubmitTime = objModel.scheduleDate
            self.textFieldViewSchedulerTime.setText = objModel.scheduleTime
        }
    }
    
    func isValidateFields() -> Bool {
        if textFieldViewSchedulerName.isValidated() && textFieldViewSchedulerType.isValidated() && textFieldViewSchedulerDate.isValidated() && textFieldViewSchedulerTime.isValidated(){
            if arrayOfTargetdApplience.count == 0{
                CustomAlertView.init(title: "Select Target Appliance").showForWhile(animated: true)
                return true
            }
            return true
        }
        return false
    }
}

// MARK: - Actions listeners
extension AddEditSchedulerViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func submitActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if SMARTRULE_OFFLINE_LOAD_ENABLE {
            if isEdit {
                self.callOfflineData(msg: "Updated Scheduler", ispopVC: true)
            } else {
                self.callOfflineData(msg: "Added Scheduler", ispopVC: true)
            }
        }
        else {
            if isValidateFields() {
                if isEdit {
                    callUpdateScheduleAPI()
                } else {
                    callAddScheduleAPI()
                }
            }
        }
    }
    
    // redirection Target Applience
    @IBAction func addApplienceClicked(sender:UIButton){
        guard let smartAddTargetVC = UIStoryboard.smart.smartAddTargetVC else { return }
        smartAddTargetVC.selectionComplitionsBlock = { [weak self] (arraySelectedtarget) in
            self?.arrayOfTargetdApplience.append(arraySelectedtarget)
            self?.tableViewScheduleDetail.reloadData()
            self?.enableDisableSaveButton()
        }
        self.navigationController?.pushViewController(smartAddTargetVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension AddEditSchedulerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfTargetdApplience.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SmartTargetApplianceTVCell.identifier, for: indexPath) as! SmartTargetApplianceTVCell
        cell.cellConfig(dataModel: arrayOfTargetdApplience[indexPath.row])
        cell.separator(hide: true)
        cell.buttonEdit.isHidden = false
        cell.setBackgroundCardColor()
        cell.buttonEdit.tag = indexPath.row
        cell.buttonEdit.addTarget(self, action: #selector(buttonEditClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func buttonEditClicked(sender:UIButton){
        guard let smartAddTargetVC = UIStoryboard.smart.smartAddTargetVC else { return }
        smartAddTargetVC.isEdit = self.isEdit
        smartAddTargetVC.objTargetApplience = arrayOfTargetdApplience[sender.tag]
        smartAddTargetVC.selectionComplitionsBlock = { [weak self] (selectedTarget) in
            self?.arrayOfTargetdApplience[sender.tag] = selectedTarget
            self?.tableViewScheduleDetail.reloadData()
            self?.enableDisableSaveButton()
        }
        smartAddTargetVC.deleteTargetApplienceComplitionsBlock = { [weak self] (selectedTarget) in
            if let index = self?.arrayOfTargetdApplience.firstIndex(where: {$0.id == selectedTarget.id}){
                self?.arrayOfTargetdApplience.remove(at: index)
                self?.tableViewScheduleDetail.reloadData()
            }
            self?.enableDisableSaveButton()
        }
        self.navigationController?.pushViewController(smartAddTargetVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate
extension AddEditSchedulerViewController: UITableViewDelegate {}

// MARK: - UITextFieldDelegate
extension AddEditSchedulerViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        switch textField {
        case textFieldViewSchedulerTime.rightIconTextfield:
            self.view.endEditing(true)
            guard let bottomTimePickerCard = UIStoryboard.common.timeSelectionBottomVC else {
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
                return false
            }
            
            var dateFuture:Bool = true
            if let selectedScheduleDate = self.textFieldViewSchedulerDate.getText?.getDate(format: .ddSpaceMMspaceYY)?.getDateInString(withFormat: .system).getDate(format: .system), self.textFieldViewSchedulerDate.isHidden == false{
                dateFuture = selectedScheduleDate >= Date()
            }
            
            bottomTimePickerCard.objEnumTimePickerType = .schedule(isTime: true, isScheduleFutureDate: dateFuture)
            bottomTimePickerCard.modalPresentationStyle = .overFullScreen
            bottomTimePickerCard.timeSelected = { [weak self] (firstTime, secondTime) in
                var finalStartEnd = ""
                let startTime = firstTime.getDateInString(withFormat: .timeWithAMPM)
                
                finalStartEnd = startTime
                self?.apiSubmitTime = firstTime.getDateInString(withFormat: .eee_dd_mmm_yyyy_HH_mm_00_z)
                if let endTIme = secondTime{
                    let strEndTime = endTIme.getDateInString(withFormat: .timeWithAMPM)
                    finalStartEnd = startTime+" - "+strEndTime
                }
                self?.textFieldViewSchedulerTime.setText = finalStartEnd
                self?.textFieldViewSchedulerTime.dismissError()
                self?.enableDisableSaveButton()
            }
            self.present(bottomTimePickerCard, animated: true, completion: nil)
            return false
            
        case textFieldViewSchedulerDate.rightIconTextfield:
            self.view.endEditing(true)
            guard let bottomTimePickerCard = UIStoryboard.common.dateSelectionBottomVC else {
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
                return false
            }
            
            bottomTimePickerCard.modalPresentationStyle = .overFullScreen
            bottomTimePickerCard.timeSelected = { [weak self] (date, _) in
                let date = date.getDateInString(withFormat: .ddSpaceMMspaceYYYY)
                self?.textFieldViewSchedulerDate.setText = date
                self?.textFieldViewSchedulerDate.dismissError()
                
                // clear when date select or re select
                self?.apiSubmitTime = ""
                self?.textFieldViewSchedulerTime.setText = ""
                self?.enableDisableSaveButton()
            }
            self.present(bottomTimePickerCard, animated: true, completion: nil)
            return false
            
        case textFieldViewSchedulerType.rightIconTextfield:
            self.view.endEditing(true)
            guard let scheduleTypeSelectionBottomVC = UIStoryboard.common.scheduleTypeSelectionBottomVC else {
                self.showAlert(withMessage: cueAlert.Message.somethingWentWrong)
                return false
            }
            
            scheduleTypeSelectionBottomVC.modalPresentationStyle = .overFullScreen
            scheduleTypeSelectionBottomVC.strScheduleDays = self.daysStr
            scheduleTypeSelectionBottomVC.callBackComplition = { [weak self] (isOnceSelected, isDailySelected, arrayOfDays) in
                if isOnceSelected{
                    self?.daysStr = ""
                    self?.textFieldViewSchedulerType.setText = localizeFor("once").capitalized
                    self?.textFieldViewSchedulerType.dismissError()
                    self?.textFieldViewSchedulerDate.isHidden =  false
                    self?.textFieldViewSchedulerTime.setText = ""
                    self?.textFieldViewSchedulerDate.setText = ""
                }else if isDailySelected{
                    self?.daysStr = ""
                    self?.textFieldViewSchedulerType.setText =  localizeFor("daily").capitalized
                    self?.textFieldViewSchedulerType.dismissError()
                    self?.textFieldViewSchedulerDate.isHidden = true
                } else if let days = arrayOfDays, days.filter({$0.isSelected}).count != 0{
                    let selectedDays = days.filter({$0.isSelected})
                    self?.daysStr = selectedDays.map({String($0.dayValue)}).joined(separator: ",")
                    self?.textFieldViewSchedulerType.setText = localizeFor("custom").capitalized
                    self?.textFieldViewSchedulerType.dismissError()
                    self?.textFieldViewSchedulerDate.isHidden = true
                }
                self?.sizeHeaderToFit()
                self?.tableViewScheduleDetail.reloadData()
                self?.enableDisableSaveButton()
            }
            self.present(scheduleTypeSelectionBottomVC, animated: true, completion: nil)
            return false
        default:break
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        enableDisableSaveButton()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddEditSchedulerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Services
extension AddEditSchedulerViewController {
    func callAddScheduleAPI() {
        guard let type = textFieldViewSchedulerType.getText?.lowercased() else { return }
        guard let name = textFieldViewSchedulerName.getText else { return }
        
        var param: [String: Any] = [
            "name": name,
            "scheduleType":type,
        ]
        
        param["scheduleDate"] = preparedScheduleDateAndTimeForApi(isScheduleTypeDailyOrCustom: type == "daily" || type == "custom" ? true : false) ?? "-"
        /*
         if type == "daily" || type == "custom"{
         param["scheduleDate"] = preparedScheduleDateAndTimeForApi(isScheduleTypeDailyOrCustom: type == "daily" || type == "custom" ? true : false) ?? "-"
         } else {
         param["scheduleDate"] = preparedScheduleDateAndTimeForApi(isScheduleTypeDailyOrCustom: type == "daily" || type == "custom" ? true : false) ?? "-"
         }*/
        
        if !daysStr.isEmpty{
            param["scheduleDays"] = self.daysStr
        }
        if arrayOfTargetdApplience.count != 0 {
            let arrayOfDict = self.arrayOfTargetdApplience.map({$0.getJsonObject})
            param["appliances"] = arrayOfDict
        }
        
        DooAPILoader.shared.startLoading()
        addEditSchedulerViewModel.callAddSchedulerAPI(param: param) { [weak self] (msg, dataModel) in
            DooAPILoader.shared.stopLoading()
            CustomAlertView.init(title: msg , forPurpose: .success).showForWhile(animated: true)
            self?.didAddedOrUpdatedScheduler?(dataModel)
            self?.navigationController?.popViewController(animated: true)
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
            //            debugPrint("")
        } failureInform: {
            DooAPILoader.shared.stopLoading()
        }
    }
    
    func callUpdateScheduleAPI() {
        guard let type = textFieldViewSchedulerType.getText?.lowercased() else { return }
        guard let name = textFieldViewSchedulerName.getText else { return }
        
        var param: [String: Any] = [
            "name": name,
            "scheduleType":type,
            "id":  schedulerDataModel.id,
        ]
        
        param["scheduleDate"] = preparedScheduleDateAndTimeForApi(isScheduleTypeDailyOrCustom: type == "daily" || type == "custom" ? true : false) ?? "-"
        /*
         if type == "daily" || type == "custom"{
         param["scheduleDate"] = preparedScheduleDateAndTimeForApi(isScheduleTypeDailyOrCustom: type == "daily" || type == "custom" ? true : false) ?? "-"
         } else {
         param["scheduleDate"] = preparedScheduleDateAndTimeForApi(isScheduleTypeDailyOrCustom: type == "daily" || type == "custom" ? true : false) ?? "-"
         }*/
        
        if !daysStr.isEmpty{
            param["scheduleDays"] = self.daysStr
        }
        if arrayOfTargetdApplience.count != 0 {
            let arrayOfDict = self.arrayOfTargetdApplience.map({$0.getJsonObject})
            param["appliances"] = arrayOfDict
        }
        
        DooAPILoader.shared.startLoading()
        addEditSchedulerViewModel.callUpdateSchedulerAPI(param: param) { [weak self] (msg, dataModel) in
            DooAPILoader.shared.stopLoading()
            CustomAlertView.init(title: msg , forPurpose: .success).showForWhile(animated: true)
            self?.didAddedOrUpdatedScheduler?(dataModel)
            self?.navigationController?.popViewController(animated: true)
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "" , forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
            //            debugPrint("")
        } failureInform: {
            DooAPILoader.shared.stopLoading()
        }
    }
    
    func preparedScheduleDateAndTimeForApi(isScheduleTypeDailyOrCustom: Bool) -> String? {
        
        guard !isScheduleTypeDailyOrCustom else {
            let convertedDate = apiSubmitTime.getDate(format: .eee_dd_mmm_yyyy_hh_mm_ss_z)
            let finalConvertedDate = convertedDate?.getDateInString(withFormat: .eee_dd_mmm_yyyy_hh_mm_ss_z, abbreviation: "GMT")
            debugPrint("Custom or daily Type Final Scheduler Date:========", finalConvertedDate ?? "")
            return finalConvertedDate
        }
        
        guard let onlyFormatedScheduleDate = textFieldViewSchedulerDate.getText?.getDate(format: .ddSpaceMMspaceYYYY)?.getDateInString(withFormat: .ddSpaceMMspaceYYYY) else {
            debugPrint("Invalid Scheduler Date:======")
            return nil }
        let scheduleDate = textFieldViewSchedulerDate.getText?.getDate(format: .ddSpaceMMspaceYYYY) ?? Date()
        let dayOfWeek = scheduleDate.getDateInString(withFormat: .eee_space)
        guard let  convertedTime = apiSubmitTime.getDate(format: .eee_dd_mmm_yyyy_hh_mm_ss_z)?.getDateInString(withFormat: .HHmmss) else {
            debugPrint("Invalid Scheduler Date:======")
            return nil }
        let scheduleDateAndTime = dayOfWeek+onlyFormatedScheduleDate+" "+convertedTime
        let convertedDate = scheduleDateAndTime.getDate(format: .eee_dd_mmm_yyyy_hh_mm_ss)
        let finalConvertedDate = convertedDate?.getDateInString(withFormat: .eee_dd_mmm_yyyy_hh_mm_ss_z, abbreviation: "GMT")
        debugPrint("Once Type Final Scheduler Date:======", finalConvertedDate ?? "")
        return finalConvertedDate
    }
}
