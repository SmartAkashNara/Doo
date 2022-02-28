//
//  AskSiriMainViewController.swift
//  Doo-IoT
//
//  Created by Shraddha on 14/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class AskSiriMainViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var searchBar: RightIconTextField!
    @IBOutlet weak var rightConstraintOfSearchBar: NSLayoutConstraint!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var horizontalTitleCollection: HorizontalTitleCollection!
    
    @IBOutlet weak var scrollViewMain: UIScrollView! {
        didSet {
            scrollViewMain.delegate = self
            scrollViewMain.isPagingEnabled = true
        }
    }
    
    var viewsToLoadInsideScroll:[UIView] = []
    var viewModel = SmartMainViewModel()
    var selectedSiriMenuTab = SmartMainViewModel.EnumSiriMenuType.RawValue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setDefaults()
    }
    
    func setDefaults() {
        // swipe to back work
        
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        
        navigationTitle.text = "Ask Siri"
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.text = Utility.getHeyUserFirstName()
        labelTitle.text = "Ask Siri" //"Here you can give command to Siri for action"
        labelTitle.font = UIFont.Poppins.semiBold(22)
        labelTitle.textColor = UIColor.blueHeading
        
//        viewNavigationBarDetail.viewConfig(
//            title: title,
//            subtitle: "Here you can give command to Siri for actiond")
        navigationTitle.text = title
        navigationTitle.font = UIFont.Poppins.medium(14)
        navigationTitle.textColor = UIColor.blueHeading
        navigationTitle.isHidden = true
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
//        mainView.delegateOfSWWalert = self
        
        buttonBack.setImage(UIImage(named: "imgArrowLeftBlack"), for: .normal)
        buttonSearch.setImage(UIImage(named: "imgSearchBlue"), for: .normal)
        
        searchBar.backgroundColor = UIColor.grayCountryHeader
        searchBar.placeholder = localizeFor("search_placeholder")
        searchBar.font = UIFont.Poppins.medium(14)
        if let rightClearIcon = UIImage.init(named: "clearButton") {
            searchBar.rightIcon =  rightClearIcon
        }
        searchBar.leadingGap = 0
        searchBar.delegateOfRightIconTextField = self
        searchBar.setRightIconUserInteraction(to: true)
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        
        rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
        self.viewModel.isFromSiri = true
        setUpHorizontalHeaderCollection()
        configureSmartMainScrollCollection()
        self.slideToSelectedViewInMainScroll()
    }
    
    func setUpHorizontalHeaderCollection() {
        horizontalTitleCollection.dataModel = SmartMainViewModel.EnumSiriMenuType.allCases.map({return HorizontalTitleCollectionDataModel.init(title: $0.title, isSelected: $0.tabSelected)})
        
        horizontalTitleCollection.selectedIndex = self.selectedSiriMenuTab
        horizontalTitleCollection.resetData()
        self.viewModel.selectedEnumSiriMenuType = SmartMainViewModel.EnumSiriMenuType.init(rawValue: self.selectedSiriMenuTab)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.horizontalTitleCollection.setSelectionTab(withIndexPath: IndexPath.init(row: self.selectedSiriMenuTab, section: 0),
                                                           isInformCaller: false) // UI Layout reflections.
        }
                
        horizontalTitleCollection.selectionChanged = { index in
            debugPrint("react according to selection of index: \(index)")
            let indexPath = IndexPath(item: index, section: 0)
                    
                    // scroll to view of main scroll based on cell selected
                    if let slideVw = self.scrollViewMain.viewWithTag(indexPath.row + 100) {
                        self.scrollViewMain.setContentOffset(CGPoint(x: slideVw.frame.minX, y: slideVw.frame.minY), animated: true)
                    }
           self.selectedSiriMenuTab = (SmartMainViewModel.EnumSiriMenuType.allCases[index]).rawValue
        }
        self.horizontalTitleCollection.isShowLoader = false // Off skeleton and reload.... Yes this will reload too...
    }
    
    func configureSmartMainScrollCollection() {
        self.viewsToLoadInsideScroll = createSlides()
        self.setupSlideScrollView(slidesInsideScroll: viewsToLoadInsideScroll)
    }
    
    func slideToSelectedViewInMainScroll() {
        if let slideVw = self.scrollViewMain.viewWithTag(self.selectedSiriMenuTab + 100) {
            self.scrollViewMain.setContentOffset(CGPoint(x: slideVw.frame.minX, y: slideVw.frame.minY), animated: true)
        }
    }
    
    // creation of views inside main scroll view based Smart enum
    func createSlides() -> ([UIView]) {
        var arrayViews = [UIView]()
        if SmartMainViewModel.EnumSiriMenuType.allCases.count > 0 {
            for ruleCase in SmartMainViewModel.EnumSiriMenuType.allCases {
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
            if let slideView = slidesInsideScroll[i] as? AppliancesViewInAskSiriMainVc {
                slideView.frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: scrollViewMain.frame.width, height: scrollViewMain.frame.height)
                slideView.defaultConfig(viewController: self)
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

// MARK: - UIGestureRecognizerDelegate
extension AskSiriMainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate Methods
extension AskSiriMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset.y = 0
        }
        self.horizontalTitleCollection.didScrollEvent(scrollView)
//        addNavigationAnimation(scrollView)
//        fetchNextPage(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewMain {
            self.horizontalTitleCollection.didScrollDoneEvent(scrollView, draggingStart: true)
            self.selectedSiriMenuTab = self.horizontalTitleCollection.selectedIndex // assign new selected index to view controller's property.
            self.viewModel.selectedEnumSiriMenuType = SmartMainViewModel.EnumSiriMenuType.init(rawValue: self.selectedSiriMenuTab)
            
            if searchBar.canBecomeFirstResponder{
                self.closeSearchBar()
            }
        }
    }
    
    // on end of scrollview main slide, the index of selected view/group will be find
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewMain {
            self.horizontalTitleCollection.didScrollDoneEvent(scrollView)
            self.selectedSiriMenuTab = self.horizontalTitleCollection.selectedIndex // assign new selected index to view controller's property.
            self.viewModel.selectedEnumSiriMenuType = SmartMainViewModel.EnumSiriMenuType.init(rawValue: self.selectedSiriMenuTab)
        }
    }
    
    func addNavigationAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 32.0 {
            navigationTitle.isHidden = false
        }else{
            navigationTitle.isHidden = true
        }
        if scrollView.contentOffset.y >= 76.0 {
            viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        }else{
            viewNavigationBar.selectedCorners(radius: 0, [.bottomLeft, .bottomRight])
        }
    }
    func fetchNextPage(_ scrollView: UIScrollView) {
//        let height = scrollView.frame.size.height
//        let contentYoffset = scrollView.contentOffset.y
//        guard contentYoffset != 0 else { return }
//        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
//        if distanceFromBottom < height {
//            // pagination
//            if devicesListViewModel.getTotalElements > devicesListViewModel.getAvailableElements &&
//                !tableViewDeviceList.isAPIstillWorking {
//                self.callGetDeviceListByTypeAPI(isNextPage: true, searchText: self.searchBar.getText())
//            }
//        }
    }
}

// MARK: - internet & something went wrong work
extension AskSiriMainViewController: SomethingWentWrongAlertViewDelegate {
    func retryTapped() {
//        self.mainView.forPurpose = .somethingWentWrong
//        self.mainView.dismissSomethingWentWrong()
//        self.callGetDeviceListByTypeAPI()
    }
    
    // not from delegates
    func showInternetOffAlert() {
//        self.mainView.showInternetOff()
    }
    func showSomethingWentWrongAlert() {
//        self.mainView.showSomethingWentWrong()
    }
}

// MARK: - RightIconTextFieldDelegate
extension AskSiriMainViewController: RightIconTextFieldDelegate {
    func rightIconTapped(textfield: RightIconTextField) {
        if !textfield.text!.isEmpty {
//            callGetDeviceListByTypeAPI(searchText: "", false)
        }
        self.closeSearchBar()
    }
}

// MARK: - Search bar open and close methods
extension AskSiriMainViewController {
    func openSearchBar() {
        UIView.animate(withDuration: 0.2, animations: {
            self.rightConstraintOfSearchBar.constant = 8
            self.viewNavigationBar.layoutIfNeeded()
        }) { (_) in
            self.searchBar.becomeFirstResponder()
        }
    }
    func closeSearchBar() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        if selectedSiriMenuTab == SmartMainViewModel.EnumSiriMenuType.appliances.rawValue {
            if let slideView = scrollViewMain.viewWithTag(100) as? AppliancesViewInAskSiriMainVc {
                slideView.isSearch = false
                slideView.clearSearch(isClosePressed: false)
            }
        } else if selectedSiriMenuTab == SmartMainViewModel.EnumSiriMenuType.scenes.rawValue {
            if let slideView = scrollViewMain.viewWithTag(101) as? SceneViewInSmartMainVc {
                slideView.isSearch = false
                slideView.clearSearch(isClosePressed: false)
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.rightConstraintOfSearchBar.constant = -UIScreen.main.bounds.size.width
            self.viewNavigationBar.layoutIfNeeded()
        }) { (_) in
        }
    }
}

// MARK: - UITextFieldDelegate
extension AskSiriMainViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.getSearchText(range: range, replacementString: string)
        if searchText.count <= 0 {
            if selectedSiriMenuTab == SmartMainViewModel.EnumSiriMenuType.appliances.rawValue {
                if let slideView = scrollViewMain.viewWithTag(100) as? AppliancesViewInAskSiriMainVc {
                    slideView.clearSearch(isClosePressed: false)
                }
            } else if selectedSiriMenuTab == SmartMainViewModel.EnumSiriMenuType.scenes.rawValue {
                if let slideView = scrollViewMain.viewWithTag(100) as? SceneViewInSmartMainVc {
                    slideView.clearSearch(isClosePressed: false)
                }
            }
        } else {
        if selectedSiriMenuTab == SmartMainViewModel.EnumSiriMenuType.appliances.rawValue {
            if let slideView = scrollViewMain.viewWithTag(100) as? AppliancesViewInAskSiriMainVc {
                slideView.isSearch = true
                slideView.searchConfig(viewController: self, strSearch: searchText)
            }
        } else if selectedSiriMenuTab == SmartMainViewModel.EnumSiriMenuType.scenes.rawValue {
            if let slideView = scrollViewMain.viewWithTag(101) as? SceneViewInSmartMainVc {
                slideView.isSearch = true
                slideView.searchConfig(viewController: self, strSearch: searchText)
            }
        }
        }
//        callGetDeviceListByTypeAPI(searchText: searchText, true)
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Action listeners
extension AskSiriMainViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchActionListener(_ sender: UIButton) {
        openSearchBar()
    }
}
