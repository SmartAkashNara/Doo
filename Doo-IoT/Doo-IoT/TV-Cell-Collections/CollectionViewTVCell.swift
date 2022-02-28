//
//  CollectionViewTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class CollectionViewTVCell: UITableViewCell {

    static let identifier = "CollectionViewTVCell"
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintTrailing: NSLayoutConstraint!
    @IBOutlet weak var collectionViewMain: UICollectionView!
    
    enum EnumCellType { case groupTab, groupList, none }

    private var cellType = EnumCellType.none
    private var arrayGroups = [GroupDataModel]()
    var selectedTab:Int = 0
    var didTap: ((_ masterId: String, _ groupId:Int, _ rowIndex:Int) -> Void)? = nil
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        selectionStyle = .none
        configureCollectionView()
    }
    
    func setArrayData(arrayData: [GroupDataModel]) {
        arrayGroups.removeAll()
        arrayGroups = arrayData
        collectionViewMain.reloadData()
    }
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        collectionViewMain.dataSource = self
        collectionViewMain.delegate = self
        collectionViewMain.setCollectionViewLayout(layout, animated: false)
        collectionViewMain.registerCellNib(identifier: FavouriteDeviceCVCell.identifier, commonSetting: true)
        collectionViewMain.registerCellNib(identifier: GroupMenuCollectionViewCell.identifier, commonSetting: true)
        
        
        switch cellType {
        case .groupList:
            constraintTop.constant = 8
            constraintBottom.constant = 8
        default:
            break
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionViewTVCell {
    func cellConfig(cellType: EnumCellType) {
        self.cellType = cellType
    }
}


// MARK: - UICollectionViewDataSource
extension CollectionViewTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch cellType {
        case .groupTab,.groupList:
            return arrayGroups.count
        case .none:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cellType {
        case .groupTab:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteDeviceCVCell.identifier, for: indexPath) as! FavouriteDeviceCVCell
//                    cell.cellConfig(data: arrayGroups[indexPath.row])
            return cell
        case .groupList:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupMenuCollectionViewCell.identifier, for: indexPath) as! GroupMenuCollectionViewCell
            cell.cellConfig(data: arrayGroups[indexPath.row])
            cell.setSelected(isSelected: selectedTab == indexPath.row)
            return cell

        case .none:
            return collectionView.getDefaultCell(indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch cellType {
        case .groupTab:
            return CGSize(width: 0, height: 0)
        case .groupList:
            let item = arrayGroups[indexPath.row].name
            let itemWidth = item.widthOfString(usingFont: UIFont.Poppins.medium(12))
            return CGSize(width: itemWidth - 18, height: 40)
        case .none:
            return CGSize.zero
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewTVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch cellType {
        case .groupTab:
            print(arrayGroups[indexPath.row])
        case .groupList:
            if selectedTab != indexPath.row{
                selectedTab = indexPath.row
                print(arrayGroups[indexPath.row])
//                collectionView.reloadData()
                didTap?(arrayGroups[indexPath.row].groupMasterId ?? "", arrayGroups[indexPath.row].id, indexPath.row)
            }
        case .none:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
//        if indexPath.row == arrayGroups.count{
//            lastContentOffset = collectionViewMain.contentOffset
//        }
        return true
    }
}

extension CollectionViewTVCell: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // update the new position acquired
//        self.lastContentOffset = collectionViewMain.contentOffset
    }
}
