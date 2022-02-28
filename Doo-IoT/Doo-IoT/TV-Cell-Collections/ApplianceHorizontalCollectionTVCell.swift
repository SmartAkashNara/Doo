//
//  ApplianceHorizontalCollectionTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 24/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class ApplianceHorizontalCollectionTVCell: UITableViewCell {
    
    static let identifier = "ApplianceHorizontalCollectionTVCell"
    
    @IBOutlet weak var labelTitleFavouriteDevices: UILabel!
    @IBOutlet weak var collectionViewFavouriteDevices: UICollectionView!
    @IBOutlet weak var constrainHeightCollectionView: NSLayoutConstraint!
    
    @IBOutlet weak var sepratorView: UIView!
    @IBOutlet weak var constraintTrailingContentView: NSLayoutConstraint!

    @IBOutlet weak var constraintTopContentView: NSLayoutConstraint!
    
    var reloadCollectionHandler:(()->())?
    // var arrayFavouriteDevices = [HomeViewModel.FavouriteDeviceData]()
    var arrayFavouriteDevices = [ApplianceDataModel]()
    var didTap:((Int, Int)->())?
    var didTapLongGesture:((Int, Int)->())?
    var didMoreTapped:(()->())?

    var cellWidthFavDevices: CGFloat = 0
    var selectedApplinceRow:Int = -1
    var isSelectionEnable = false
    @IBOutlet weak var constraintLeadingContentView: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellWidthFavDevices = (cueSize.screen.width - 32) / 4

        labelTitleFavouriteDevices.text = localizeFor("your_favourites")
        labelTitleFavouriteDevices.font = UIFont.Poppins.semiBold(13)
        labelTitleFavouriteDevices.textColor = UIColor.blueHeading


        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 0
        collectionViewFavouriteDevices.dataSource = self
        collectionViewFavouriteDevices.delegate = self
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionViewFavouriteDevices.setCollectionViewLayout(layout, animated: false)
        collectionViewFavouriteDevices.registerCellNib(identifier: FavouriteDeviceCVCell.identifier, commonSetting: true)
        collectionViewFavouriteDevices.isPagingEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellConfig(data: [ApplianceDataModel]) {
        self.arrayFavouriteDevices.removeAll()
        self.arrayFavouriteDevices = data
        collectionViewFavouriteDevices.reloadData()
    }
    
    func cellConfigFromGroup(){
        labelTitleFavouriteDevices.isHidden = true // don't show title
        
        constrainHeightCollectionView.constant = FavouriteDeviceCVCell.cellHeight
        sepratorView.isHidden = false
        sepratorView.backgroundColor = UIColor.blueHeadingAlpha10
        cellWidthFavDevices = 76
        constraintTopContentView.constant = 0
        constraintLeadingContentView.constant = 0
        constraintTrailingContentView.constant = 0
        collectionViewFavouriteDevices.backgroundColor = .clear
    }
    
    func cellConfigFromHome(){
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViewFavouriteDevices.setCollectionViewLayout(layout, animated: false)
        constrainHeightCollectionView.constant = FavouriteDeviceCVCell.cellHeight//190
        sepratorView.isHidden = true
        sepratorView.backgroundColor = UIColor.blueHeadingAlpha10
        constraintLeadingContentView.constant = 16
        constraintTrailingContentView.constant = 16
        // if height is not equal to according to content size. set it.
        self.constrainHeightCollectionView.constant = 200
        
    }

    func cellConfigFromGroupDetail() {
        
        labelTitleFavouriteDevices.isHidden = true  // don't show title
        constrainHeightCollectionView.constant = FavouriteDeviceCVCell.cellHeight
        sepratorView.isHidden = true
    }

}

// MARK: - UICollectionViewDataSource
extension ApplianceHorizontalCollectionTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayFavouriteDevices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteDeviceCVCell.identifier, for: indexPath) as! FavouriteDeviceCVCell
        cell.cellConfig(data: arrayFavouriteDevices[indexPath.row], isSelected: selectedApplinceRow == indexPath.row)
        
        if isSelectionEnable && selectedApplinceRow == indexPath.row{
            cell.viewCard.backgroundColor = UIColor.blueSwitch
            cell.viewCard.layer.borderWidth = 1
            cell.labelDeviceName.textColor = UIColor.grayOffDevice
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        longPress.accessibilityValue = String(indexPath.row)
        cell.contentView.addGestureRecognizer(longPress)
        return cell
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: collectionViewFavouriteDevices)
            if let indexPath = collectionViewFavouriteDevices.indexPathForItem(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                print("Long press Pressed:)\(indexPath)")
                didTapLongGesture?(indexPath.row, collectionViewFavouriteDevices.tag)
            }
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension ApplianceHorizontalCollectionTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidthFavDevices, height: FavouriteDeviceCVCell.cellHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension ApplianceHorizontalCollectionTVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedData = arrayFavouriteDevices[indexPath.row]
        if selectedData.isMore {
            print("more tapped")
            didMoreTapped?()
        } else {
            selectedApplinceRow = indexPath.row
            didTap?(indexPath.row, collectionViewFavouriteDevices.tag)
            print(selectedData.applianceName)
            collectionView.reloadData()
        }
    }
}
