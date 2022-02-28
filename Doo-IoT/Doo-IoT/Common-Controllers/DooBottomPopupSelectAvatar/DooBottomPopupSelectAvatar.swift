//
//  DooBottomPopupSelectAvatarViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 01/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooBottomPopupSelectAvatarViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stackViewOfTitle: UIStackView!
    @IBOutlet weak var labeNavigationDetailTitle: UILabel!
    @IBOutlet weak var labelNavigaitonDetailSubTitle: UILabel!
    @IBOutlet weak var stackViewButtonsParent: UIStackView!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var buttonRight: UIButton!
    @IBOutlet weak var collectionViewAvatar: UICollectionView!
    @IBOutlet weak var constraintHeightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomMainView: NSLayoutConstraint!

    struct ActionButton {
        var title: String
        var titleColor: UIColor
        var backgroundColor: UIColor
        var action: ((ProfileViewModel.DefaultAvatar?)->())
    }

    private var poupTitle = ""
    private var subTitle = ""
    private var arrayAvatar = [ProfileViewModel.DefaultAvatar]()
    private var leftButton: ActionButton? = nil
    private var rightButton: ActionButton? = nil
    private var lastSelectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureControls()
        setDefaultData()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 0.3) {
            self.constraintBottomMainView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func setPopup(title: String, subTitle: String, selectedImageUrl:String,  avatars: [ProfileViewModel.DefaultAvatar],
                  leftButton: ActionButton?, rightButton: ActionButton?) {
        
        self.poupTitle = title
        self.subTitle = subTitle
        self.arrayAvatar = avatars
        self.leftButton = leftButton
        self.rightButton = rightButton
        if !arrayAvatar.count.isZero() {
            arrayAvatar[0].selected = true
            for i in 0..<arrayAvatar.count {
                if arrayAvatar[i].image == selectedImageUrl {
                    lastSelectedIndex = i
                    arrayAvatar[i].selected = true
                } else {
                    arrayAvatar[i].selected = false
                }
            }
        }
    }
    
    private func setButtons() {
        if let leftActionAvailable = leftButton {
            self.buttonLeft.setTitle(leftActionAvailable.title, for: .normal)
            self.buttonLeft.setTitleColor(leftActionAvailable.titleColor, for: .normal)
            self.buttonLeft.backgroundColor = leftActionAvailable.backgroundColor
            self.buttonLeft.isHidden = false
            self.buttonLeft.addTarget(self, action: #selector(self.leftButtonActionListener(sender:)), for: .touchUpInside)
        }else{
            self.buttonLeft.isHidden = true
        }
        
        if let rightActionAvailable = rightButton {
            self.buttonRight.setTitle(rightActionAvailable.title, for: .normal)
            self.buttonRight.setTitleColor(rightActionAvailable.titleColor, for: .normal)
            self.buttonRight.backgroundColor = rightActionAvailable.backgroundColor
            self.buttonRight.isHidden = false
            self.buttonRight.addTarget(self, action: #selector(self.rightButtonActionListener(sender:)), for: .touchUpInside)
        }else{
            self.buttonRight.isHidden = true
        }
    }
    
    @objc func leftButtonActionListener(sender: UIButton) {
        self.leftButton?.action(nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func rightButtonActionListener(sender: UIButton) {
        if arrayAvatar.count.isZero() {
            self.rightButton?.action(nil)
        } else {
            self.rightButton?.action(arrayAvatar[lastSelectedIndex])
        }
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: - User defined methods
extension DooBottomPopupSelectAvatarViewController {
    func configureCollectionView() {
        let availableSpace = cueSize.screen.width - 40 - (AvatarCVCell.cellSize.width * 4)
        let space = availableSpace / 3
//        constraintHeightCollectionView.constant = ((AvatarCVCell.cellSize.height + space) * 3) - space
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.scrollDirection = .vertical
        
        collectionViewAvatar.dataSource = self
        collectionViewAvatar.delegate = self
        collectionViewAvatar.setCollectionViewLayout(flowLayout, animated: false)
        collectionViewAvatar.registerCellNib(identifier: AvatarCVCell.identifier, commonSetting: true)
    }
    
    func configureControls() {
        self.labeNavigationDetailTitle.font = UIFont.Poppins.semiBold(18)
        self.labeNavigationDetailTitle.textColor = UIColor.blueHeading
        
        self.labelNavigaitonDetailSubTitle.font = UIFont.Poppins.regular(12)
        self.labelNavigaitonDetailSubTitle.textColor = UIColor.blueHeadingAlpha60
        
        self.buttonLeft.titleLabel?.font = UIFont.Poppins.semiBold(13.3)
        self.buttonLeft.cornerRadius = 16.7
        self.buttonLeft.clipsToBounds = true
        
        self.buttonRight.titleLabel?.font = UIFont.Poppins.semiBold(13.3)
        self.buttonRight.cornerRadius = 16.7
        self.buttonRight.clipsToBounds = true
        
        self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainView.layer.cornerRadius = 10.0
        
        // remove view when blank area gonna be tapped.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissViewTapGesture(tapGesture:)))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    func setDefaultData() {
        labeNavigationDetailTitle.text = poupTitle
        labelNavigaitonDetailSubTitle.text = subTitle
    }
    
    func loadData(){
        setButtons()
        collectionViewAvatar.performBatchUpdates({
            collectionViewAvatar.reloadData()
        }) { (flag) in
            self.constraintHeightCollectionView.constant = self.collectionViewAvatar.contentSize.height
        }
    }
    
    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension DooBottomPopupSelectAvatarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayAvatar.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCVCell.identifier, for: indexPath) as! AvatarCVCell
        cell.cellConfig(data: arrayAvatar[indexPath.row])
        return cell
    }
    
}
 
// MARK: - UICollectionViewDelegateFlowLayout
extension DooBottomPopupSelectAvatarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return AvatarCVCell.cellSize
    }
}

// MARK: - UICollectionViewDelegate
extension DooBottomPopupSelectAvatarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !arrayAvatar[indexPath.row].selected else { return }
        arrayAvatar[lastSelectedIndex].selected = false
        arrayAvatar[indexPath.row].selected = true
        collectionView.reloadData()
        lastSelectedIndex = indexPath.row
    }
}
