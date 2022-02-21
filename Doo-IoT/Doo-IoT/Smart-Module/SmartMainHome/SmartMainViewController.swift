//
//  SmartMainViewController.swift
//  Doo-IoT
//
//  Created by Shraddha on 16/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class SmartMainViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var buttonNotification: NotifButton!
    @IBOutlet weak var buttonAddGroup: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var horizontalTitleCollection: HorizontalTitleCollection!
    
    @IBOutlet weak var scrollViewMain: UIScrollView! {
        didSet {
            scrollViewMain.delegate = self
            scrollViewMain.isPagingEnabled = true
        }
    }
    
    // MARK:- Variable Declaration
    var viewsToLoadInsideScroll:[UIView] = []
    var viewModel = SmartMainViewModel()
    var selectedSmartMenuTab = SmartMainViewModel.EnumSmartMenuType.RawValue()
    
    // MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // profile picture
        self.assignProfilePicture()
        self.labelUserName.text = Utility.getHeyUserFirstName()
    }
    
    // MARK: - ViewDidAppear stuffs
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.delegate = self
    }
    
    // MARK:- Other Methods
    // default configuration
    func defaultConfig() {
        labelUserName.font = UIFont.Poppins.semiBold(22)
        labelUserName.textColor = UIColor.blueHeading
        labelUserName.text = Utility.getHeyUserFirstName()
        
        setUpHorizontalHeaderCollection()
        configureSmartMainScrollCollection()
        self.slideToSelectedViewInMainScroll()
        
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.text = Utility.getHeyUserFirstName()
        
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        imageViewProfile.backgroundColor = UIColor.black
        imageViewProfile.contentMode = .scaleAspectFill
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        imageViewProfile.isUserInteractionEnabled = true
        imageViewProfile.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.navigateToProfileView(sender:))))
        
        buttonNotification.showDotImage()
        // Hiddent navigation options.
        buttonNotification.isHidden = true
        buttonAddGroup.isHidden = true
    }
    
    
    // setting profile pic
    func assignProfilePicture() {
        self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.bounds.size.width/2
        if let user = APP_USER, let thumbNail = URL.init(string: user.thumbnailImage) {
            self.imageViewProfile.contentMode = .scaleAspectFill
            self.imageViewProfile.sd_setImage(with: thumbNail, placeholderImage: UIImage.init(named: "placeholderOfProfilePicture")!, options: .continueInBackground, context: nil)
        }
    }
    
    // navagition on tap of profile pic
    @objc func navigateToProfileView(sender: UIImageView) {
        if let profileVC = UIStoryboard.profile.instantiateInitialViewController() {
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func setUpHorizontalHeaderCollection() {
        horizontalTitleCollection.dataModel = SmartMainViewModel.EnumSmartMenuType.allCases.map({return HorizontalTitleCollectionDataModel.init(title: $0.title, isSelected: $0.tabSelected)})
        
        horizontalTitleCollection.selectedIndex = self.selectedSmartMenuTab
        horizontalTitleCollection.resetData()
        self.viewModel.selectdEnumSmartMenuType = SmartMainViewModel.EnumSmartMenuType.init(rawValue: self.selectedSmartMenuTab)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.horizontalTitleCollection.setSelectionTab(withIndexPath: IndexPath.init(row: self.selectedSmartMenuTab, section: 0),
                                                           isInformCaller: false) // UI Layout reflections.
        }
                
        horizontalTitleCollection.selectionChanged = { index in
            debugPrint("react according to selection of index: \(index)")
            let indexPath = IndexPath(item: index, section: 0)
                    
                    // scroll to view of main scroll based on cell selected
                    if let slideVw = self.scrollViewMain.viewWithTag(indexPath.row + 100) {
                        self.scrollViewMain.setContentOffset(CGPoint(x: slideVw.frame.minX, y: slideVw.frame.minY), animated: true)
                    }
        }
        self.horizontalTitleCollection.isShowLoader = false // Off skeleton and reload.... Yes this will reload too...
    }
    
    func slideToSelectedViewInMainScroll() {
        if let slideVw = self.scrollViewMain.viewWithTag(self.selectedSmartMenuTab + 100) {
            self.scrollViewMain.setContentOffset(CGPoint(x: slideVw.frame.minX, y: slideVw.frame.minY), animated: true)
        }
    }
}


// MARK: - Initial Handlings
extension SmartMainViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        navigationController.interactivePopGestureRecognizer?.isEnabled = !isRootVC
    }
}

// MARK: - Configure groups title collection
extension SmartMainViewController {
    
    func configureSmartMainScrollCollection() {
        self.viewsToLoadInsideScroll = createSlides()
        self.setupSlideScrollView(slidesInsideScroll: viewsToLoadInsideScroll)
    }
    
    // creation of views inside main scroll view based Smart enum
    func createSlides() -> ([UIView]) {
        var arrayViews = [UIView]()
        if SmartMainViewModel.EnumSmartMenuType.allCases.count > 0 {
            for ruleCase in SmartMainViewModel.EnumSmartMenuType.allCases {
                arrayViews.append(ruleCase.loadXib!)
            }
        }
        return arrayViews
    }
    
    // set the position of created views inside main scrollview
    func setupSlideScrollView(slidesInsideScroll : [UIView]) {
        // Remove all content views from scroll view...
        for subView in scrollViewMain.subviews {
            subView.removeFromSuperview()
        }
        // Other stuff to configure scrollview for content.
        scrollViewMain.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.height - 203)
        let statusBar = UIDevice.hasNotch ? 44 : 20
        let indicatorBarAtBottom = UIDevice.hasNotch ? 34 : 0
        scrollViewMain.contentSize = CGSize(width: view.frame.width * CGFloat(slidesInsideScroll.count), height: UIScreen.main.bounds.size.height - CGFloat((220 + statusBar + indicatorBarAtBottom))) // 100 header + 50 groups titles content + 50 tabbar = 200
        for i in 0 ..< slidesInsideScroll.count {
            if let slideView = slidesInsideScroll[i] as? BindingRuleViewInSmartMainVc {
                slideView.frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: scrollViewMain.frame.width, height: scrollViewMain.frame.height)
                slideView.defaultConfig(viewModel: self.viewModel, viewController: self)
                slideView.tag = i + 100
                scrollViewMain.addSubview(slideView)
            }
            if let slideView = slidesInsideScroll[i] as? ScheduleViewInSmartMainVc {
                slideView.frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: scrollViewMain.frame.width, height: scrollViewMain.frame.height)
                slideView.defaultConfig(viewModel: self.viewModel, viewController: self)
                slideView.tag = i + 100
                scrollViewMain.addSubview(slideView)
            }
            if let slideView = slidesInsideScroll[i] as? SceneViewInSmartMainVc {
                slideView.frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: scrollViewMain.frame.width, height: scrollViewMain.frame.height)
                slideView.defaultConfig(viewModel: self.viewModel, viewController: self)
                slideView.tag = i + 100
                scrollViewMain.addSubview(slideView)
            }
        }
    }
}

// MARK: - Refresh APIs of Smart Rules
extension SmartMainViewController {
    func callApiWhenChangeEnterprise() {
        for contentView in self.scrollViewMain.subviews {
            if let _ = contentView as? BindingRuleViewInSmartMainVc {
                debugPrint("BindingRuleViewInSmartMainVc")
            }else if let contentView = contentView as? ScheduleViewInSmartMainVc {
                debugPrint("ScheduleViewInSmartMainVc")
                contentView.callGetSchedulesListAPI(isNextPageRequest: false, isPullToRefresh: true)
            }else if let contentView = contentView as? SceneViewInSmartMainVc {
                debugPrint("SceneViewInSmartMainVc")
                contentView.callGetSceneListAPI(isNextPageRequest: false, isPullToRefresh: true)
            }
        }
    }
}

// MARK: - ScrollView Delegates
extension SmartMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset.y = 0
        }
        // scrollProcess()
        /*
        let vel = scrollView.panGestureRecognizer.velocity(in: scrollView)
        switch direction {
        case .horizontal where abs(vel.y) < abs(vel.x) && abs(vel.y) < 1.0:
            debugPrint("horizontal direction: \(abs(vel.y)), \(abs(vel.x))")
        case .vertical where abs(vel.x) > abs(vel.y):
            debugPrint("verticle direction: Break")
        default:
            debugPrint("direction: \(abs(vel.y)), \(abs(vel.x))")
            break
        }
        */
        
        self.horizontalTitleCollection.didScrollEvent(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewMain {
            self.horizontalTitleCollection.didScrollDoneEvent(scrollView, draggingStart: true)
            self.selectedSmartMenuTab = self.horizontalTitleCollection.selectedIndex // assign new selected index to view controller's property.
            self.viewModel.selectdEnumSmartMenuType = SmartMainViewModel.EnumSmartMenuType.init(rawValue: self.selectedSmartMenuTab)
        }
    }
    
    // on end of scrollview main slide, the index of selected view/group will be find
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewMain {
            self.horizontalTitleCollection.didScrollDoneEvent(scrollView)
            self.selectedSmartMenuTab = self.horizontalTitleCollection.selectedIndex // assign new selected index to view controller's property.
            self.viewModel.selectdEnumSmartMenuType = SmartMainViewModel.EnumSmartMenuType.init(rawValue: self.selectedSmartMenuTab)
        }
    }
}
