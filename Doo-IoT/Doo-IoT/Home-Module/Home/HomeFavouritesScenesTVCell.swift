//
//  HomeFavouritesScenesTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 24/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class HomeFavouritesScenesTVCell: UITableViewCell {

    static let identifier = "HomeFavouritesScenesTVCell"

    @IBOutlet weak var labelTitleFavouriteScenes: UILabel!
    
    @IBOutlet weak var topConstraintOfcollectionViewFavouriteScenes: NSLayoutConstraint!
    @IBOutlet weak var collectionViewFavouriteScenes: UICollectionView!

    var arrayFavouriteScenes = [SRSceneDataModel]()
    var isScenesFetched: Bool = false
    var buttonClouser : ((SRSceneDataModel)->(Void))?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        labelTitleFavouriteScenes.text = localizeFor("favourites_senses")
        labelTitleFavouriteScenes.font = UIFont.Poppins.semiBold(13)
        labelTitleFavouriteScenes.textColor = UIColor.blueHeading
        labelTitleFavouriteScenes.isHidden = true

        let layoutForScene = UICollectionViewFlowLayout()
        layoutForScene.minimumLineSpacing = 7
        layoutForScene.minimumInteritemSpacing = 0
        layoutForScene.scrollDirection = .horizontal
        layoutForScene.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionViewFavouriteScenes.dataSource = self
        collectionViewFavouriteScenes.delegate = self
        collectionViewFavouriteScenes.setCollectionViewLayout(layoutForScene, animated: false)
        collectionViewFavouriteScenes.registerCellNib(identifier: FavouriteSceneCVCell.identifier, commonSetting: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showSkeletonAnimation() {
        self.isScenesFetched = false
        self.topConstraintOfcollectionViewFavouriteScenes.constant = 0.0
        self.collectionViewFavouriteScenes.reloadData()
    }
    
    func cellConfig(data: [SRSceneDataModel]) {
        // Layout...
        self.isScenesFetched = true
        self.labelTitleFavouriteScenes.isHidden = false // show now.
        
        // data fill...
        self.topConstraintOfcollectionViewFavouriteScenes.constant = 44.5
        self.arrayFavouriteScenes = data
        self.collectionViewFavouriteScenes.reloadData()
    }

}

// MARK: - UICollectionViewDataSource
extension HomeFavouritesScenesTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !self.isScenesFetched {
            return 2
        }else{
            return arrayFavouriteScenes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteSceneCVCell.identifier, for: indexPath) as! FavouriteSceneCVCell
        if !self.isScenesFetched {
            cell.showSkeletonAnimation()
        }else{
            cell.cellConfig(data: arrayFavouriteScenes[indexPath.row])
            cell.buttonExecute.tag = indexPath.row
            cell.buttonExecute.addTarget(self, action: #selector(executeActionListener(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    @objc func executeActionListener(_ sender: UIButton) {
        buttonClouser?(arrayFavouriteScenes[sender.tag])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeFavouritesScenesTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return FavouriteSceneCVCell.cellSize
    }
}

// MARK: - UICollectionViewDelegate
extension HomeFavouritesScenesTVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(arrayFavouriteScenes[indexPath.row].sceneName)
    }
}
