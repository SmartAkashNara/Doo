//
//  ProfileViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 30/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import Photos

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var tableViewUserDetail: UITableView!
    @IBOutlet weak var userHeader: UserDetailHeaderView!
    
    var profileViewModel = ProfileViewModel()
    var imagePicker = UIImagePickerController()
    var profileImage: UIImage?
    var selectedAvatar: ProfileViewModel.DefaultAvatar?

    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaults()
        configureTableView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.callGetProfileDataAPI()
            self.callGetDefaultAvatarsAPI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserName()
        reloadUserData()
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        buttonEdit.setImage(UIImage(named: "imgEditButton"), for: .normal)
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePicActionListener(_:)))
        userHeader.imageViewOfUser.addGestureRecognizer(tapGesture)
        userHeader.imageViewOfUser.isUserInteractionEnabled = true

        userHeader.tapToSetNameClouser = {
            self.redirectToEditProfile()
        }
        userHeader.backgroundColor = UIColor.grayCountryHeader
    }
    
    func reloadUserData() {
        guard let dooUser = APP_USER else { return }
        userHeader.setDetail(dooUser)
        if dooUser.profilePic {
            selectProfilePicture(UIImage())
        }
        setUserName(dooUser: dooUser)
        profileViewModel.loadData(user: dooUser)
        tableViewUserDetail.reloadData()
    }
    
    func setUserName(dooUser: AppUser? = nil) {
        var userStrong: AppUser!
        if dooUser == nil {
            guard let loginUser = APP_USER else { return }
            userStrong = loginUser
        } else {
            userStrong = dooUser
        }
        navigationTitle.text = userStrong.fullName
        userHeader.setUserName(userStrong.fullName)
    }
    
    func setUserHeaderDetails() {
        guard let user = APP_USER else { return }
        userHeader.setDetail(user)
        userHeader.imageViewOfUser.contentMode = .scaleAspectFill
        userHeader.imageViewOfUser.sd_setImage(with: URL(string: user.thumbnailImage), placeholderImage: cueImage.userPlaceholder, options: .continueInBackground, context: nil)
    }

    func selectProfilePicture(_ obj: Any) {
        removeSelectedProfilePicture()
        if let selectedImage = obj as? UIImage {
            profileImage = selectedImage
        } else if let selectedAvatar = obj as? ProfileViewModel.DefaultAvatar{
            self.selectedAvatar = selectedAvatar
        }
    }
    
    func removeSelectedProfilePicture() {
        profileImage = nil
        selectedAvatar = nil
    }
    
    func configureTableView() {
        self.tableViewUserDetail.dataSource = self
        self.tableViewUserDetail.delegate = self
        self.tableViewUserDetail.rowHeight = UITableView.automaticDimension
        self.tableViewUserDetail.estimatedRowHeight = 44
        self.tableViewUserDetail.tableHeaderView = self.userHeader
        self.tableViewUserDetail.addBounceViewAtTop()
        self.tableViewUserDetail.registerCellNib(identifier: DooHeaderDetail_1TVCell.identifier, commonSetting: true)
        self.tableViewUserDetail.registerCellNib(identifier: DooDetail_1TVCell.identifier)
    }
    
    @objc func profilePicActionListener(_ gesture: UITapGestureRecognizer) {
        if let actionsVC = UIStoryboard.common.bottomGenericActionsVC {
            let action1 = DooBottomPopupActions_1ViewController.PopupOption.init(title: localizeFor("choose_from_gallery"), color: UIColor.blueSwitch, action: {
                self.chooseFromGallery()
            })
            let action2 = DooBottomPopupActions_1ViewController.PopupOption.init(title: localizeFor("take_a_photo"), color: UIColor.blueSwitch, action: {
                self.takePhoto()
            })
            let action3 = DooBottomPopupActions_1ViewController.PopupOption.init(title: localizeFor("change_default_avatar"), color: UIColor.blueSwitch, action: {
                self.selectDefaultAvatarPupup()
            })
            var actions = [action1, action2, action3]
            if profileImage != nil {
                let action4 = DooBottomPopupActions_1ViewController.PopupOption.init(title: localizeFor("remove_profile"), color: UIColor.textFieldErrorColor, action: {
                    self.showDeleteAlert()
                })
                actions.append(action4)
            }
            actionsVC.popupType = .generic(localizeFor("upload_a_photo"), "", actions)
            self.present(actionsVC, animated: true, completion: nil)
        }
    }

    func selectDefaultAvatarPupup() {
        DispatchQueue.getMain(delay: 0.1) {
            guard !self.profileViewModel.arrayDefaultAvatar.count.isZero() else {
                self.showAlert(withMessage: "Avatar not available. please try after some time.")
                return
            }
            guard let popupAvatar = UIStoryboard.common.bottomPopupSelectAvatarVC else { return }
            let cancelAction = DooBottomPopupSelectAvatarViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {_ in
            }
            let updateAction = DooBottomPopupSelectAvatarViewController.ActionButton.init(title: cueAlert.Button.update, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) { selectedAvatar in
                print("update clicked")
                if let selectedAvatarStrong = selectedAvatar {
                    print("selectedImageStrong \(selectedAvatarStrong)")
                    self.selectProfilePicture(selectedAvatarStrong)
                    self.callUpdateProfilePictureAPI()
                }
            }
            var profileImgUrl = ""
            if let user = APP_USER {
                profileImgUrl = user.thumbnailImage
            }
            popupAvatar.setPopup(title: localizeFor("select_avatar_title"),
                                 subTitle: "",
                                selectedImageUrl: profileImgUrl,avatars: self.profileViewModel.arrayDefaultAvatar,
                                 leftButton: cancelAction,
                                 rightButton: updateAction)
            self.present(popupAvatar, animated: true, completion: nil)
        }
    }

    func showDeleteAlert() {
        DispatchQueue.getMain(delay: 0.1) {
            if let alertVC = UIStoryboard.common.bottomGenericAlertsVC {
                let cancelAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.cancel, titleColor: UIColor.skinText, backgroundColor: UIColor.blueSwitch) {
                }
                let deleteAction = DooBottomPopupAlerts_1ViewController.ActionButton.init(title: cueAlert.Button.remove, titleColor: UIColor.blueSwitch, backgroundColor: UIColor.blueHeadingAlpha06) {
                    self.callDeleteProfilePictureAPI()
                }
                alertVC.setAlert(alertTitle: localizeFor("are_you_sure_want_to_remove_profile"), leftButton: cancelAction, rightButton: deleteAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }

    func chooseFromGallery() {
        DispatchQueue.getMain(delay: 0.1) {
            self.askPhotoLibPermission()
            Utility.checkPhotoLibraryPermission(viewControler: self) {
                DispatchQueue.main.async {
                    self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.imagePicker.delegate = self
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
    }

    func takePhoto() {
        DispatchQueue.getMain(delay: 0.1) {
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                Utility.checkVideoCameraPermission { (isGranted) in
                    if isGranted{
                        DispatchQueue.main.async {
                            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                            self.imagePicker.delegate = self
                            self.present(self.imagePicker, animated: true, completion: nil)
                        }
                    }else{
                        Utility.showAlertForCameraWithSettingOption(viewControler: self,
                                                                    customMessage: "Kindly allow 'Doo' app to access camera from Settings!")
                    }
                }
            }else{
                self.showAlert(withMessage: cueAlert.Message.cameraAccessDenided)
            }
        }
    }
    
    func askPhotoLibPermission(){
        PHPhotoLibrary.requestAuthorization { (status) in
            print(status)
        }
    }

    @IBAction func backActionListener(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editActionListener(sender: UIButton) {
        redirectToEditProfile()
    }
    
    func redirectToEditProfile() {
        if let destView = UIStoryboard.profile.editProfileVC {
            self.navigationController?.pushViewController(destView, animated: true)
        }
    }
}

// MARK: - Services
extension ProfileViewController {
    func callGetProfileDataAPI() {
//        API_LOADER.show(animated: true)
        profileViewModel.callGetProfileDataAPI(param: [:]) {
//            API_LOADER.dismiss(animated: true)
            self.reloadUserData()
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
        } failureInform: {
//            API_LOADER.dismiss(animated: true)
        }
    }

    func callGetDefaultAvatarsAPI() {
//        API_LOADER.show(animated: true)
        profileViewModel.callGetDefaultAvatarsAPI(param: [:]) {
//            API_LOADER.dismiss(animated: true)
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
        } failureInform: {
//            API_LOADER.dismiss(animated: true)
        }
    }

    func callUpdateProfilePictureAPI() {
        if profileImage == nil && selectedAvatar == nil {
            return
        }
        var param: [String: Any] = ["updateProfilePic": true]
        if let selectedAvatar = selectedAvatar {
            param["avatarId"] = selectedAvatar.id
        }
        
        var arrayImages = [UIImage]()
        if let profileImage = profileImage {
            arrayImages.append(profileImage)
        }
        API_LOADER.show(animated: true)
        profileViewModel.callUpdateProfilePictureAPI(param:  param,
                                                     receivedImages: arrayImages,
                                            receivedImageNames: ["file"],
                                            receivedFileNames: ["profileImage.jpg"]) {
            API_LOADER.dismiss(animated: true)
            self.setUserHeaderDetails()
        } failure: {
        } internetFailure: {
        } commonFailure: {
            API_LOADER.dismiss(animated: true)
        }
    }

    func callDeleteProfilePictureAPI() {
        API_LOADER.show(animated: true)
        profileViewModel.callDeleteProfilePictureAPI(param: [:]) {
            API_LOADER.dismiss(animated: true)
            self.removeSelectedProfilePicture()
            self.setUserHeaderDetails()
        } failure: { msg in
            CustomAlertView.init(title: msg ?? "", forPurpose: .success).showForWhile(animated: true)
        } internetFailure: {
        } failureInform: {
            API_LOADER.dismiss(animated: true)
        }
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return profileViewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileViewModel.arrayOfUserDetailFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooDetail_1TVCell.identifier, for: indexPath) as! DooDetail_1TVCell
        cell.cellConfigForProfile(data: profileViewModel.arrayOfUserDetailFields[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return DooHeaderDetail_1TVCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooHeaderDetail_1TVCell.identifier) as! DooHeaderDetail_1TVCell
        cell.cellConfig(title: profileViewModel.sections[section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addNavigationAnimation(scrollView)
    }
    
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 140.0 {
            navigationTitle.isHidden = false
        }else{
            navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= 186.0 {
            viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        }else{
            viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
}

// MARK: - UIImagePickerController Delegates & UINavigationController Delegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        func dimsissSelf() {
            dismiss(animated: true, completion: nil)
        }
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        guard let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            dimsissSelf()
            return
        }
        if InputValidator.isValidImageSize(pickedImage, mb: 20) {
            selectProfilePicture(pickedImage.fixedOrientation())
            callUpdateProfilePictureAPI()
            dimsissSelf()
        } else {
            dimsissSelf()
            if picker.sourceType == UIImagePickerController.SourceType.camera {
                print("cueToast.Validation.cameraImageLimitExceeded")
                //                    ErrorPopUp.addErrorPopUp(inView: self.view, withContent: cueToast.Validation.cameraImageLimitExceeded)
            }else{
                print("cueToast.Validation.galleryImageLimitExceeded")
                //                    ErrorPopUp.addErrorPopUp(inView: self.view, withContent: cueToast.Validation.galleryImageLimitExceeded)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
