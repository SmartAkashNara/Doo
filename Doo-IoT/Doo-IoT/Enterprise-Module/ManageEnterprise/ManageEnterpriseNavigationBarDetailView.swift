//
//  ManageEnterpriseNavigationBarDetailView.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class ManageEnterpriseNavigationBarDetailView: UIView {
    
    //top(9) + labels(47) + Bottom(20) = 76
    //UserList(57 (37+20) ) = 134
    static let viewHeightWithOnlyPicute: CGFloat = 134
    static let viewHeightWithoutOnlyPicute: CGFloat = 76
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var onlyPictures: OnlyHorizontalPictures!
    
    var mainView:UIView!
    var users = [String]()
    var maxNumberOfVisibleUser = 0
    var viewCurrentHeight: CGFloat = viewHeightWithOnlyPicute
    var heightConstraint:NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.initSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
        self.initSetUp()
    }
    
    // Performs the initial setup.
    private func setupView() {
        mainView = viewFromNibForClass()
        mainView.frame = bounds
        
        // Auto-layout stuff.
        mainView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        
        // Show the view.
        addSubview(mainView)
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    private func initSetUp() {
        labelTitle.font = UIFont.Poppins.semiBold(18)
        labelTitle.textColor = UIColor.blueHeading
        
        labelSubTitle.font = UIFont.Poppins.regular(12)
        labelSubTitle.textColor = UIColor.blueHeadingAlpha60
        
        let imageWidth:CGFloat = 37
        let gap: CGFloat = 9
        onlyPictures.backgroundColor = UIColor.clear
        onlyPictures.alignment = .left
        onlyPictures.imageInPlaceOfCount = UIImage(named: "imgMoreUsers")
        onlyPictures.countPosition = .right
        onlyPictures.spacing = 0
        onlyPictures.gap = Float(imageWidth + gap)
        onlyPictures.dataSource = self
        onlyPictures.reloadData()
        onlyPictures.clipsToBounds = true
        
        maxNumberOfVisibleUser = Int((cueSize.screen.width - 40) / (imageWidth + gap))
        
        mainView.backgroundColor = UIColor.grayCountryHeader
        mainView.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        heightConstraint = addHeight(constant: Double(viewCurrentHeight))
    }
    
    func viewConfig(title: String, subtitle: String, users: [String], animated: Bool = false) {
        labelTitle.text = title
        labelSubTitle.text = subtitle
        
        // this is to show 3 dots always. if users are more than 6, then it will show 3 dosts automatically after 6.
        self.users = users
        if self.users.count != 0 {
            // show 3 dots only when you have few users...
            self.users.append("") // for 3 dots
        }
        
        if !animated {
            onlyPictures.reloadData()
        }
        setHeight(onlyPicuture: !self.users.count.isZero(), animated: animated)
    }
    
}

// set width equal to device width
extension ManageEnterpriseNavigationBarDetailView {
    func setWidthEqualToDeviceWidth() {
        for constraint in self.constraints {
            if constraint.firstAttribute == .width {
                constraint.constant = UIScreen.main.bounds.size.width
            }
        }
    }
    func setHeight(onlyPicuture: Bool, animated: Bool = false) {
        if let heightConstrintStrong = heightConstraint {
            viewCurrentHeight = onlyPicuture ? ManageEnterpriseNavigationBarDetailView.viewHeightWithOnlyPicute : ManageEnterpriseNavigationBarDetailView.viewHeightWithoutOnlyPicute
            self.onlyPictures.isHidden = onlyPicuture ? false : true
            func setHeightCore() {
                heightConstrintStrong.constant = self.viewCurrentHeight
                self.frame.size.height = self.viewCurrentHeight
            }
            if animated {
                UIView.animate(withDuration: 0.1, animations: {
                    setHeightCore()
                }, completion: { (flag) in
                    self.onlyPictures.reloadData()
                })
            } else {
                setHeightCore()
            }
        }
    }
}

extension ManageEnterpriseNavigationBarDetailView: OnlyPicturesDataSource {
    func numberOfPictures() -> Int {
        return self.users.count
    }
    func visiblePictures() -> Int {
        // Why 7... When there are 6 users, then additional +1 is blank for 3 dots always. So we have kept condition on 7.
        // 7 means users are more than 6. So pass 6 in return. otherwise self.users.count-1
        if self.users.count > 7 {
            // this means user has more than 6.
            if cueDevice.isDeviceSEOrLower {
                return 4
            }else{
                return 6
            }
        }else{
            return self.users.count-1
        }
    }
    func pictureViews(_ imageView: UIImageView, index: Int) {
        let calculateMinusValue = (users.count-6)
        let actualIndex = index - ((calculateMinusValue >= 0) ? calculateMinusValue : 0)
        // imageView.image = UIImage(named: users[actualIndex])
        debugPrint("Actual index working: \(actualIndex)")
        let filteredIndex = self.users.count >= 7 ? actualIndex : actualIndex-1
        if self.users.indices.contains(filteredIndex) {
            imageView.contentMode = .scaleAspectFill
            let imageUrl = URL(string: users[filteredIndex])
            imageView.sd_setImage(with: imageUrl,
                                  placeholderImage: cueImage.userPlaceholder,
                                  options: .continueInBackground,
                                  completed: nil)
        }else{
            imageView.image = cueImage.userPlaceholder // set placeholder...
        }
    }
}
