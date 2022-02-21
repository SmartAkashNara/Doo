//
//  AddEditSceneViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 21/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class AddEditSceneViewController: CardBaseViewController {
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var textFieldViewSceneName: DooTextfieldView!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var buttonAddApplience: UIButton!
    @IBOutlet weak var labelApplieneTitle: UILabel!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewAddEditApplience: UITableView!
    @IBOutlet weak var imageViewBottomGradient: UIImageView!
    
    @IBOutlet weak var collectionViewSceneList: UICollectionView!
    @IBOutlet weak var labelCollectionTitle: UILabel!
    @IBOutlet weak var stackViewCollectionViewContainer: UIStackView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableSectionFooterView: UIView!
    @IBOutlet weak var buttonFavourite: UIButton!

    private let viewModel = AddEditSceneViewModel()
    private var arrayOfTargetdApplience = [TargetApplianceDataModel]()
    private var selectedSceneIconRow:Int? = nil
    var sceneDataModel: SRSceneDataModel? = nil
    var didAddedOrUpdatedScene:((SRSceneDataModel?)->())? = nil
    var arraySceneDefultList: [SRScenePredefinedDataModel] = []
    
    var isEditFlow: Bool = false
    private var isFavouriteScene = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        configureTableView()
        loadData()
        enableDisableSaveButton()
        if isEditFlow, (sceneDataModel?.scenePredefinedDataModel?.isOtherSceneObject ?? false){
            getSceneList()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
}

// MARK: - Other methods
extension AddEditSceneViewController {
    /*
     for enabling save button, two conditions must be fulfilled:
     1. number of appliances should be greater than zero.
     2. if predefined scene type is 0, its icon should be selected.
     */
    func enableDisableSaveButton() {
        buttonSubmit.alpha = (((self.sceneDataModel?.scenePredefinedDataModel?.sceneMasterId == 1 && selectedSceneIconRow != -1) || (self.sceneDataModel?.scenePredefinedDataModel?.sceneMasterId != 1)) && self.arrayOfTargetdApplience.count > 0) ? 1 : 0.5
        buttonSubmit.isUserInteractionEnabled = (((self.sceneDataModel?.scenePredefinedDataModel?.sceneMasterId == 1 && selectedSceneIconRow != -1) || (self.sceneDataModel?.scenePredefinedDataModel?.sceneMasterId != 1)) && self.arrayOfTargetdApplience.count > 0) ? true : false
    }
    
    // Card Work
    func setLayout(withCard cardVC: CardGenericViewController, cardPosition: CardPosition) {
        // Setup dynamic card.
        // card setup
        self.cardPosition = cardPosition
        self.setupCard(cardVC)
        
        self.setCardHandleAreaHeight = 0
        // self.offCurveInCard()
        self.applyDarkOnlyOnCard = true
        self.updateProgress = { name in
            // print("Happy birthday, \(name)!")
        }
    }
    
    func setDefaults() {
        labelCollectionTitle.font = UIFont.Poppins.medium(11)
        labelCollectionTitle.textColor = UIColor.blueHeadingAlpha60
        labelCollectionTitle.text = localizeFor("select_Icon")
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        let title = isEditFlow ? localizeFor("edit_scene") : localizeFor("add_scene")
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
        
        textFieldViewSceneName.titleValue = localizeFor("scene_name")
        textFieldViewSceneName.textfieldType = .generic
        textFieldViewSceneName.genericTextfield?.addThemeToTextarea(localizeFor("enter_scene_name"))
        textFieldViewSceneName.genericTextfield?.returnKeyType = .done
        textFieldViewSceneName.activeBehaviour = true
        textFieldViewSceneName.genericTextfield?.delegate = self
        textFieldViewSceneName.validateTextForError = { textField in
            if InputValidator.checkEmpty(value: textField){
                return "Scene name is required"
            }
            
            if !InputValidator.isRange(textField, lowerLimit: 2, uperLimit: 40){
                return "Scene name length should be between 2 to 40 characters"
            }
            return nil
        }
        
        //set button type Custom from storyboard
        buttonSubmit.setThemeAppBlueWithArrow(localizeFor(isEditFlow ? "update_button" : "save_button"))
        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")
        
        self.enableDisableSaveButton()
        
        buttonFavourite.addTarget(self, action: #selector(buttonFavouriteClick), for: .touchUpInside)
        buttonFavourite.setImage(UIImage.init(named: "imgHeartFavouriteUnfill"), for: .normal)
    }
    
    func setFavouriteIconOnButton(){        
        buttonFavourite.setImage(UIImage.init(named: isFavouriteScene ? "imgHeartFavouriteFill" : "imgHeartFavouriteUnfill"), for: .normal)
    }
    
    @objc func buttonFavouriteClick(){
        isFavouriteScene = !isFavouriteScene
        setFavouriteIconOnButton()
    }
    
    func loadData() {
        guard let sceneObject = sceneDataModel else { return}
        arrayOfTargetdApplience = sceneObject.arrayTargetApplience

        /*
        // Remove "Other" default scene from the list, its masterId = 1
        if arraySceneDefultList.count > 0 {
            arraySceneDefultList.removeAll(where: { ($0.sceneMasterId == 1) })
        }*/
        
        if let scenePredefinedDataModel = sceneObject.scenePredefinedDataModel, (scenePredefinedDataModel.isOtherSceneObject){
            // other scenes case
            selectedSceneIconRow = 0
            configureCollectionView()
            textFieldViewSceneName.setText = sceneObject.scenePredefinedDataModel?.sceneName ?? "-"
        }else{
            textFieldViewSceneName.isUserInteractionEnabled = false
            textFieldViewSceneName.alpha = 0.5
            textFieldViewSceneName.setText = sceneObject.scenePredefinedDataModel?.sceneName ?? "-"
        }
        tableViewAddEditApplience.reloadData()
        
        isFavouriteScene = sceneObject.isFavouriteScene
        setFavouriteIconOnButton()
    }
    
    func configureTableView() {
        tableViewAddEditApplience.autolayoutTableViewHeader = tableHeaderView
        tableViewAddEditApplience.autolayoutTableViewFooterHeader = tableSectionFooterView
        tableViewAddEditApplience.dataSource = self
        tableViewAddEditApplience.delegate = self
        tableViewAddEditApplience.registerCellNib(identifier: SmartTargetApplianceTVCell.identifier, commonSetting: true)
    }
    
    func sizeHeaderToFit() {
        let headerView = tableViewAddEditApplience.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableViewAddEditApplience.tableHeaderView = headerView
    }
    
    func configureCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 5
        flowLayout.scrollDirection = .horizontal
        collectionViewSceneList.dataSource = self
        collectionViewSceneList.delegate = self
        collectionViewSceneList.setCollectionViewLayout(flowLayout, animated: false)
        collectionViewSceneList.registerCellNib(identifier: SmartSceneIconCVCell.identifier, commonSetting: true)
        collectionViewSceneList.reloadData()
        stackViewCollectionViewContainer.isHidden = false
    }
    
    func isValidateFields() -> Bool {
        if textFieldViewSceneName.isValidated(){
            if arrayOfTargetdApplience.count == 0 {
                CustomAlertView.init(title: "Select Target Appliance").showForWhile(animated: true)
                return true
            }
            return true
        }
        return false
    }
}

// MARK: - UITableViewDataSource
extension AddEditSceneViewController: UITableViewDataSource {
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
        smartAddTargetVC.isEdit = self.isEditFlow
        smartAddTargetVC.objTargetApplience = arrayOfTargetdApplience[sender.tag]
        smartAddTargetVC.selectionComplitionsBlock = { [weak self] (selectedTarget) in
            self?.arrayOfTargetdApplience[sender.tag] = selectedTarget
            self?.tableViewAddEditApplience.reloadData()
            self?.enableDisableSaveButton()
        }
        smartAddTargetVC.deleteTargetApplienceComplitionsBlock = { [weak self] (selectedTarget) in
            if let index = self?.arrayOfTargetdApplience.firstIndex(where: {$0.id == selectedTarget.id}){
                self?.arrayOfTargetdApplience.remove(at: index)
                self?.tableViewAddEditApplience.reloadData()
                self?.enableDisableSaveButton()
            }
        }
        self.navigationController?.pushViewController(smartAddTargetVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate
extension AddEditSceneViewController: UITableViewDelegate {}

// MARK: - Actions listeners
extension AddEditSceneViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if isValidateFields() {
            if isEditFlow {
                callUpdateSceneAPI()
            } else {
                callAddSceneAPI()
            }
        }
    }
    
    // redirection target applience
    @IBAction func addApplienceClicked(sender:UIButton){
        guard let smartAddTargetVC = UIStoryboard.smart.smartAddTargetVC else { return }
        smartAddTargetVC.selectionComplitionsBlock = { (objSelectedtarget) in
            self.arrayOfTargetdApplience.append(objSelectedtarget)
            self.tableViewAddEditApplience.reloadData()
            self.enableDisableSaveButton()
        }
        self.navigationController?.pushViewController(smartAddTargetVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddEditSceneViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddEditSceneViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension AddEditSceneViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arraySceneDefultList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SmartSceneIconCVCell.identifier, for: indexPath) as! SmartSceneIconCVCell
        cell.cellConfig(imageIconName: arraySceneDefultList[indexPath.row].sceneIcon, isSelected: selectedSceneIconRow == indexPath.row)
        self.enableDisableSaveButton()
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AddEditSceneViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 50, height: 50)
    }
}

// MARK: - UICollectionViewDelegate
extension AddEditSceneViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSceneIconRow = selectedSceneIconRow == indexPath.row ? -1 : indexPath.row
        collectionView.reloadData()
        self.enableDisableSaveButton()
    }
}

// MARK: - Services
extension AddEditSceneViewController {
    func callAddSceneAPI() {
        guard let objSceneDataModel = sceneDataModel else { return }
        let isOtherScene = (objSceneDataModel.scenePredefinedDataModel?.isOtherSceneObject ?? false)

        var param: [String: Any] = [
            "masterId": objSceneDataModel.scenePredefinedDataModel?.sceneMasterId ?? 0,
            "name" : isOtherScene ?  textFieldViewSceneName.getText ?? "" : objSceneDataModel.scenePredefinedDataModel?.sceneName ?? "",
            "favouite": isFavouriteScene ? 1 : 0

        ]
        
        if let selectedOtherSceneRow = selectedSceneIconRow{
            param["iconId"] = arraySceneDefultList[selectedOtherSceneRow].iconId
        }else{
            param["iconId"] = objSceneDataModel.scenePredefinedDataModel?.iconId ?? 0
        }

        if arrayOfTargetdApplience.count != 0 {
            let arrayOfDict = self.arrayOfTargetdApplience.map({$0.getJsonObject})
            param["appliances"] = arrayOfDict
        }
        
        API_LOADER.show(animated: true)
        viewModel.callAddSceneAPI(param: param) { [weak self] (msg, dataModel) in
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: msg, forPurpose: .success).showForWhile(animated: true)
            self?.didAddedOrUpdatedScene?(dataModel)
            self?.navigationController?.popToViewControllerCustom(destView: SmartMainViewController(), animated: true)
        } failure: { msg in
            API_LOADER.dismiss(animated: true)
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
            // debugPrint("")
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
    
    func callUpdateSceneAPI() {
        guard let objSceneDataModel = sceneDataModel else { return }
        let isOtherScene = (objSceneDataModel.scenePredefinedDataModel?.isOtherSceneObject ?? false)
        var param: [String: Any] = [
            "masterId": objSceneDataModel.scenePredefinedDataModel?.sceneMasterId ?? 0,
            "id": objSceneDataModel.id,
            "name" : isOtherScene ?  textFieldViewSceneName.getText ?? "" : objSceneDataModel.scenePredefinedDataModel?.sceneName ?? "",
            "favouite": isFavouriteScene ? 1 : 0
        ]
        
        if let selectedOtherSceneRow = selectedSceneIconRow{
            param["iconId"] = arraySceneDefultList[selectedOtherSceneRow].iconId
        }else{
            param["iconId"] = objSceneDataModel.scenePredefinedDataModel?.iconId ?? 0
        }
        
        if arrayOfTargetdApplience.count != 0 {
            let arrayOfDict = self.arrayOfTargetdApplience.map({$0.getJsonObject})
            param["appliances"] = arrayOfDict
        }
        
        DooAPILoader.shared.startLoading()
        viewModel.callUpdateSceneAPI(param: param) { [weak self] (msg, dataModel) in
            DooAPILoader.shared.stopLoading()
            CustomAlertView.init(title: msg, forPurpose: .success).showForWhile(animated: true)
            self?.didAddedOrUpdatedScene?(dataModel)
            self?.navigationController?.popViewController(animated: true)
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
            //            debugPrint("")
        } failureInform: {
            DooAPILoader.shared.stopLoading()
        }
    }
}

// MARK: - APis
extension AddEditSceneViewController {
    func getSceneList() {
        API_SERVICES.callAPI(path: .getDefaultSceneList, method:.get) { (parsingResponse) in
            if let jsonResponse = parsingResponse {
                guard let payload = jsonResponse["payload"]?.dictionaryValue["data"]?.arrayValue
                else {
                    return
                }
                
                self.arraySceneDefultList.removeAll()
                for objScene in payload {
                    self.arraySceneDefultList.append(SRScenePredefinedDataModel.init(param: objScene))
                }
                
                if let index = self.arraySceneDefultList.firstIndex(where: {$0.iconId == self.sceneDataModel?.iconId}){
                    self.selectedSceneIconRow = index
                }
                self.collectionViewSceneList.reloadData()
            }
        } failure: { (failureMessage) in
        } internetFailure: {
        } failureInform: {
        }
    }
}
