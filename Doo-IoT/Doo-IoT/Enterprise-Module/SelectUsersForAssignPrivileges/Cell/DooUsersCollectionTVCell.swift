//
//  DooUsersCollectionTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 14/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooUsersCollectionTVCell: UITableViewCell {

    static let identifier = "DooUsersCollectionTVCell"
    static let cellHeight: CGFloat = cueDevice.isDeviceSEOrLower ? 113 : 97

    @IBOutlet weak var collectionViewSelectedUsers: UICollectionView!
    @IBOutlet weak var labelNoteTitle: UILabel!
    @IBOutlet weak var labelNoteDetail: UILabel!
    @IBOutlet weak var viewSeparator: UIView!

    var arraySelectedUsers = [DooUser]()
    var didSelectUser:((DooUser)->())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        labelNoteTitle.font = UIFont.Poppins.medium(12)
        labelNoteTitle.textColor = UIColor.blueHeadingAlpha60
        labelNoteTitle.text = localizeFor("note_title")
        
        labelNoteDetail.font = UIFont.Poppins.regular(12)
        labelNoteDetail.textColor = UIColor.blueHeadingAlpha60
        labelNoteDetail.numberOfLines = 0
        labelNoteDetail.text = localizeFor("note_detail_group")
        
        viewSeparator.backgroundColor = UIColor.blueHeadingAlpha06

        configureCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20 - 3.5, bottom: 0, right: 20 - 3.5)
        flowLayout.scrollDirection = .horizontal
        
        collectionViewSelectedUsers.dataSource = self
        collectionViewSelectedUsers.delegate = self
        collectionViewSelectedUsers.setCollectionViewLayout(flowLayout, animated: false)
        collectionViewSelectedUsers.registerCellNib(identifier: DooUserCVCell.identifier, commonSetting: true)
    }
}

// MARK: - UICollectionViewDataSource
extension DooUsersCollectionTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arraySelectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DooUserCVCell.identifier, for: indexPath) as! DooUserCVCell
        cell.cellConfig(image: arraySelectedUsers[indexPath.row].image)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DooUsersCollectionTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return DooUserCVCell.cellSize
    }
}

// MARK: - UICollectionViewDelegate
extension DooUsersCollectionTVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let removedUser = arraySelectedUsers.remove(at: indexPath.row)
        reloadNScrollToLast()
        didSelectUser?(removedUser)
    }
}

// MARK: - UICollectionViewDelegate
extension DooUsersCollectionTVCell {
    func cellConfig(data: [DooUser]) {
        arraySelectedUsers = data
        reloadNScrollToLast()
    }
    
    func reloadNScrollToLast() {
        collectionViewSelectedUsers.reloadData()
        scollToLastIndexPath()
    }
    
    func scollToLastIndexPath() {
        if let indexPath = self.selectedUserLastIndexPath() {
            collectionViewSelectedUsers.scrollToItem(at: indexPath, at: .right, animated: false)
        }
    }

    private func selectedUserLastIndexPath() -> IndexPath? {
        if arraySelectedUsers.count.isZero() {
            return nil
        } else {
            return IndexPath(row: arraySelectedUsers.count - 1, section: 0)
        }
    }
}
