//
//  HomeFavouritesDevicesTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 24/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class HomeFavouritesDevicesTVCell: UITableViewCell {
    
    static let identifier = "HomeFavouritesDevicesTVCell"
    
    @IBOutlet weak var labelTitleFavouriteDevices: UILabel!
    @IBOutlet weak var collectionViewFavouriteDevices: UICollectionView!
    
    @IBOutlet weak var sepratorView: UIView!
    @IBOutlet weak var constraintTrailingContentView: NSLayoutConstraint!
    
    @IBOutlet weak var constraintTopContentView: NSLayoutConstraint!
    
    // var arrayFavouriteDevices = [HomeViewModel.FavouriteDeviceData]()
    var arrayFavouriteDevices = [ApplianceDataModel]()
    var isAppliancesFetched: Bool = false
    
    var reloadCollectionHandler:(()->())?
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
        collectionViewFavouriteDevices.isScrollEnabled = false
        
        self.cellConfigFromHome()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func showSkeletonAnimation() {
        
        self.isAppliancesFetched = false // for skeleton
        self.labelTitleFavouriteDevices.isHidden = true
        self.collectionViewFavouriteDevices.reloadData() 
    }
    
    func cellConfig(data: [ApplianceDataModel],
                    layout: HomeViewModel.HomeLayouts) {
        
        // Layout Changes....
        self.isAppliancesFetched = true // for removing skeleton
        if data.count != 0 {
            self.labelTitleFavouriteDevices.isHidden = false
        }else{
            self.labelTitleFavouriteDevices.isHidden = true
        }
        
        // Data fill.....
        self.arrayFavouriteDevices.removeAll() // Remove all data first...
        if data.count > 7 && !layout.showAllData{
            self.arrayFavouriteDevices = Array(data[0...6])
            self.arrayFavouriteDevices.append(ApplianceDataModel(isMore: true))
        }else if data.count <= 7{
            self.arrayFavouriteDevices = data
            // DOn't add any thing else...
        }else{
            self.arrayFavouriteDevices = data
            self.arrayFavouriteDevices.append(ApplianceDataModel(isLess: true))
        }
        collectionViewFavouriteDevices.reloadData()
    }
    
    func cellConfigFromHome(){
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionViewFavouriteDevices.setCollectionViewLayout(layout, animated: false)
        constraintLeadingContentView.constant = 16
        constraintTrailingContentView.constant = 16
        
        // separtor view theme
        sepratorView.isHidden = true
        sepratorView.backgroundColor = UIColor.blueHeadingAlpha10
    }
    
    // To dynamically receive height of vertical collection view and integrate in uitableview cell.
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        
        self.collectionViewFavouriteDevices.layoutIfNeeded()
        if (UIScreen.main.bounds.size.width - 32) == self.collectionViewFavouriteDevices.collectionViewLayout.collectionViewContentSize.width {
            return CGSize.init(width: self.collectionViewFavouriteDevices.frame.size.width, height: (self.collectionViewFavouriteDevices.collectionViewLayout.collectionViewContentSize.height + 48 + 15))
        }else {
            // Just pass on random, when expected width not figured out by collection view.
            return CGSize.init(width: self.collectionViewFavouriteDevices.frame.size.width, height: 48 + 15)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeFavouritesDevicesTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !self.isAppliancesFetched {
            return 6 // skeleton
        }else{
            return arrayFavouriteDevices.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteDeviceCVCell.identifier, for: indexPath) as! FavouriteDeviceCVCell
        
        if !self.isAppliancesFetched {
            cell.showSkeletonAnimation()
            cell.viewStatusOnline.isHidden = true
        }else{
            cell.cellConfig(data: arrayFavouriteDevices[indexPath.row],
                            isSelected: selectedApplinceRow == indexPath.row)
            
            if isSelectionEnable && selectedApplinceRow == indexPath.row{
                cell.viewCard.backgroundColor = UIColor.blueSwitch
                cell.viewCard.layer.borderWidth = 1
                cell.labelDeviceName.textColor = UIColor.grayOffDevice
            }
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
            longPress.accessibilityValue = String(indexPath.row)
            cell.contentView.addGestureRecognizer(longPress)
        }
       
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
extension HomeFavouritesDevicesTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidthFavDevices, height: FavouriteDeviceCVCell.cellHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension HomeFavouritesDevicesTVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedData = arrayFavouriteDevices[indexPath.row]
        if selectedData.isMore || selectedData.isLess {
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
