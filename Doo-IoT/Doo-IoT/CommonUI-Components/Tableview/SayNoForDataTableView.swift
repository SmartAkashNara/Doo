//
//  SayNoForDataTableView.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 11/01/19.
//  Copyright © 2019 SmartSense. All rights reserved.
//

import UIKit

class SayNoForDataTableView: PaginationTableView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addActivityIndicator()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.addActivityIndicator()
    }
    
    public enum SayNoSection {
        case noRuleListFound(String)
        case noSchedulerListFound(String)
        case noSceneListFound(String)
        case noSearchResultFound(String)
        case noInternetConnectionFound
        case noSavedJobFound(String)
        case noAppliedJobFound(String)
        case noPrivilegeFound(String)
        case noFavoriteFound(String)
        case noRecievedInvitations(String)
        case genericNoResultsFound(String)
        case noDeviceListFound(String)
        case noUsersToInviteFound(String)
        case noUsersFound(String)
        case noEnterpriseUsersFound(String)
        case noGroupsListFound(String)
        case none
        
        var getTitle: String {
            switch self {
            case .noRuleListFound(let title):
                return title
            case .noSchedulerListFound(let title):
                return title
            case .noSceneListFound(let title):
                return title
            case .noSearchResultFound(let title):
                return title
            case .noInternetConnectionFound:
                return localizeFor("no_internet_connection")
            case .noSavedJobFound(let title):
                return title
            case .noAppliedJobFound(let title):
                return title
            case .noPrivilegeFound(let title):
                return title
            case .noFavoriteFound(let title):
                return title
            case .noRecievedInvitations(let title):
                return title
            case .genericNoResultsFound(let title):
                return title
            case .noDeviceListFound(let title):
                return title
            case .noUsersToInviteFound(let title):
                return title
            case .noUsersFound(let title):
                return title
            case .noEnterpriseUsersFound(let title):
                return title
            case .noGroupsListFound(let title):
                return title
            default:
                return ""
            }
        }
        
        var getDetail: String {
            switch self {
            case .noRuleListFound:
                return "No binding rules defined yet"
            case .noSchedulerListFound:
                return "No devices have been scheduled yet"
            case .noSceneListFound:
                return "No scenes have been created yet"
            case .noSearchResultFound:
                return "No search data found"
                // localizeFor("unable_to_find_page") // previously kept
            case .noInternetConnectionFound:
                return localizeFor("unable_to_connect_check_internet_connection")
            case .noSavedJobFound:
                return localizeFor("not_saved_jobs_msg")
            case .noAppliedJobFound:
                return localizeFor("not_applied_jobs_msg")
            case .noPrivilegeFound:
                return "No privilege has been given yet"
            case .noFavoriteFound:
                return "Add Your favorite device and scenes here"
            case .noRecievedInvitations:
                return "No invitation received"
            case .genericNoResultsFound:
                return localizeFor("generic_no_results_msg")
            case .noDeviceListFound:
                return "No devices have been added yet"
            case .noUsersToInviteFound:
                return "No Invited Users"
            case .noUsersFound:
                return "No users found"
            case .noEnterpriseUsersFound:
                return "No users in this enterprise"
            case .noGroupsListFound:
                return "No groups have been created yet"
            default:
                return ""
            }
        }
        
        var getPlaceHolderImage: UIImage {
            switch self {
            case .noSchedulerListFound:
                return UIImage.init(named: "noDataSchedule")!
            case .noRuleListFound:
                return UIImage.init(named: "noDataBinding_rule")!
            case .noSceneListFound:
                return UIImage.init(named: "noDataScene")!
            case .noSearchResultFound:
                return UIImage.init(named: "NoSearchFoundPlaceholderIcon")!
            case .noInternetConnectionFound:
                return UIImage.init(named: "noInternetIcon")!
            case .noSavedJobFound:
                return UIImage.init(named: "noSavedJobIcon")!
            case .noAppliedJobFound:
                return UIImage.init(named: "noAppliedJobIcon")!
            case .noPrivilegeFound:
                return UIImage.init(named: "noPrevilegeFound")!
            case .noFavoriteFound:
                return UIImage.init(named: "nofavouritesplaceholder")!
            case .noRecievedInvitations:
                return UIImage.init(named: "noreceivedInvitationplaceholdericon")!
            case .genericNoResultsFound:
                return UIImage.init(named: "noSearchresult")!
            case .noDeviceListFound:
                return UIImage.init(named: "noDeviceFoundIcon")!
            case .noUsersToInviteFound:
                return UIImage.init(named: "noEnterpriseUserFound")!
            case .noUsersFound:
                return UIImage.init(named: "noEnterpriseUserFound")!
            case .noEnterpriseUsersFound:
                return UIImage.init(named: "noEnterpriseUserFound")!
            case .noGroupsListFound:
                return UIImage.init(named: "noGroupFound")!
            default:
                return UIImage()
            }
        }
        
        var getTitleTextColor: UIColor {
            switch self {
            case .noSchedulerListFound, .noRuleListFound, .noSceneListFound,.noDeviceListFound:
                return UIColor.blueHeading
            default:
                return UIColor.black
            }
        }
        
        var getButtonTitle: String {
            switch self {
            
            case .noSavedJobFound:
                return localizeFor("top_recommended_jobs")
            case .noAppliedJobFound:
                return localizeFor("top_recommended_jobs")
            default:
                return localizeFor("retry")
            }
        }
        
        var getBottomButtonTextColor: UIColor {
            switch self {
            default:
                return UIColor.white
            }
        }
    }
    public var sayNoSection: SayNoSection = .none {
        didSet {
            switch sayNoSection {
            case .noSchedulerListFound:
                setSearchSectionSuggestionsSayNo(true, topGap: 20)
            case .noRuleListFound:
                setSearchSectionSuggestionsSayNo(true, topGap: 20)
            case .noSceneListFound,.noSearchResultFound,.noPrivilegeFound, .noFavoriteFound, .noRecievedInvitations,.genericNoResultsFound,.noDeviceListFound, .noUsersToInviteFound, .noUsersFound, .noEnterpriseUsersFound, .noGroupsListFound:
                setSearchSectionSuggestionsSayNo(true, topGap: 0)
            case .noInternetConnectionFound:
                setSearchSectionSuggestionsSayNo(true, topGap: 20)
            case .noSavedJobFound,.noAppliedJobFound:
                setSearchSectionSuggestionsSayNo(true, topGap: 20)
            default:
                break
            }
        }
    }
    var continueShowingSection: Bool = false {
        didSet {
            if signInOutletStackView != nil{
                self.signInOutletStackView?.isHidden = !self.continueShowingSection
            }
        }
    }
    
    func setDetailLabelWhenProviderNotAvailable(detailText:String){
        if !detailText.isEmpty{
            noResultsDetailFoundLabel.text = detailText
        }else{
            noResultsFoundLabel.text = sayNoSection.getTitle
        }
    }
    
    
    func setNoResultLabelWhen(title:String){
        if !title.isEmpty{
            noResultsFoundLabel.text = title
        }else{
            noResultsFoundLabel.text = sayNoSection.getTitle
        }
    }
    
    func changeIconAndTitleAndSubtitle(title:String, detailStr:String, icon:String){
        noResultsFoundLabel.text = title
        noResultsDetailFoundLabel.text = detailStr
        imageview.image = UIImage.init(named: icon)
    }

    
    private let sayNoView: UIView = UIView.init(frame: .zero)
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(frame: .zero)
    var isRefreshing: Bool = false {
        didSet {
            self.isAnimating = self.isRefreshing
            if self.isRefreshing {
                self.signInOutletStackView?.isHidden = true
            }else{
                self.signInOutletStackView?.isHidden = false
            }
        }
    }
    var isAnimating: Bool = false  // just a clone of isRefreshing
    
    public func startAnimating() {
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        self.bringSubviewToFront(activityIndicator)
        
        // hide all cells while indicator working
        for cell in visibleCells {
            cell.isHidden = true
        }
    }
    public func stopAnimating() {
        activityIndicator.stopAnimating()
        // show all cells while indicator working
        for cell in visibleCells {
            cell.isHidden = false
        }
    }
    
    // Added activity indicator, not related to no results kinda.....
    var topConstraintOfActivityIndicator: NSLayoutConstraint? = nil
    private func addActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        self.topConstraintOfActivityIndicator = activityIndicator.addTop(isSuperView: self, constant: 16)
        activityIndicator.addCenterX(inSuperView: self)
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    func setAcitivityTopConstraint(_ constant: CGFloat) {
        self.topConstraintOfActivityIndicator?.constant = constant
    }
    func setTopGapOfPlaceholder(topGapSpace:CGFloat){
        topConstraintOfPlaceHolderView?.constant = topGapSpace
    }
    
    // specific
    var topConstraintOfPlaceHolderView: NSLayoutConstraint? = nil
    let imageview: UIImageView = UIImageView.init(frame: .zero)
    let noResultsFoundLabel: UILabel = UILabel.init(frame: .zero)
    let noResultsDetailFoundLabel: UILabel = UILabel.init(frame: .zero)
    let buttonOfRetry: UIButton = UIButton.init(frame: .zero)
    var signInOutletStackView: UIStackView? = nil
    let bottomButtonMore: UIButton = UIButton.init(frame: .zero)
    private func setSearchSectionSuggestionsSayNo(_ isCenter: Bool = false, topGap: CGFloat = 50.0) {
        
        sayNoView.removeFromSuperview()
        sayNoView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sayNoView)
        sayNoView.addLeft(isSuperView: self, constant: 0)
        sayNoView.addRight(isSuperView: self, constant: 0)
        sayNoView.addBottom(isSuperView: self, constant: 0)
        topConstraintOfPlaceHolderView = sayNoView.addTop(isSuperView: self, constant: 0)
//        sayNoView.addSurroundingZero(isSuperView: self)
        sayNoView.isHidden = true
//        sayNoView.isUserInteractionEnabled = false
        
        signInOutletStackView?.removeFromSuperview()
        signInOutletStackView = UIStackView.init(frame: .zero)
        signInOutletStackView!.translatesAutoresizingMaskIntoConstraints = false
        sayNoView.addSubview(signInOutletStackView!)
        
        signInOutletStackView!.addLeft(isSuperView: self, constant: 30.0)
        signInOutletStackView!.addRight(isSuperView: self, constant: -30.0)
        if isCenter {
            signInOutletStackView!.addCenterY(inSuperView: self, multiplier: 0.9)
        }else{
            signInOutletStackView!.addTop(isSuperView: self, constant: Float(topGap))
        }
        signInOutletStackView!.spacing = 20
        signInOutletStackView!.axis = .vertical
        
        imageview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageview)
        imageview.image = self.sayNoSection.getPlaceHolderImage//cueImage.SearchSection.sayno_suggestions_search
        imageview.contentMode = .center
        signInOutletStackView!.addArrangedSubview(imageview)
        
        let innerStackView = UIStackView.init(frame: .zero)
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.spacing = 8
        innerStackView.axis = .vertical
        signInOutletStackView!.addArrangedSubview(innerStackView)
        
        noResultsFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.addArrangedSubview(noResultsFoundLabel)
        noResultsFoundLabel.text = self.sayNoSection.getTitle//cuePlaceholder.noResults.title
        noResultsFoundLabel.textAlignment = .center
        noResultsFoundLabel.font = UIFont.Poppins.semiBold(12.7)
        noResultsFoundLabel.textColor = UIColor.black
        
        noResultsDetailFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.addArrangedSubview(noResultsDetailFoundLabel)
        noResultsDetailFoundLabel.text = self.sayNoSection.getDetail
        noResultsDetailFoundLabel.font = UIFont.Poppins.medium(13.3)
        noResultsDetailFoundLabel.textColor = UIColor.blueHeadingAlpha30
        noResultsDetailFoundLabel.numberOfLines = 3
        noResultsDetailFoundLabel.lineBreakMode = .byWordWrapping
        noResultsDetailFoundLabel.textAlignment = .center
        
        
        switch self.sayNoSection {
        case .noAppliedJobFound, .noSavedJobFound:
            sayNoView.addSubview(self.bottomButtonMore)
            self.bottomButtonMore.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 16, right: 0)
            self.bottomButtonMore.translatesAutoresizingMaskIntoConstraints = false
            
            let attrs:[NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font : UIFont.Poppins.medium(10.0),
                NSAttributedString.Key.foregroundColor : UIColor.blueHeading,
                NSAttributedString.Key.underlineStyle : 1]

            let buttonTitleStr = NSMutableAttributedString(string:self.sayNoSection.getButtonTitle, attributes:attrs)
            bottomButtonMore.setAttributedTitle(buttonTitleStr, for: .normal)
            
            self.bottomButtonMore.addCenterX(inSuperView: sayNoView)
            self.bottomButtonMore.addTop(isRelateTo: innerStackView, isSuperView: sayNoView, constant: 0)
            self.bottomButtonMore.addHeight(constant: 44)
            self.bottomButtonMore.addTarget(self, action: #selector(self.otherButtonActionListener(sender:)), for: .touchUpInside)
            self.bottomButtonMore.backgroundColor = self.sayNoSection.getBottomButtonTextColor
        default:
            sayNoView.addSubview(self.buttonOfRetry)
            self.buttonOfRetry.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 36, bottom: 0, right: 36)
            self.buttonOfRetry.translatesAutoresizingMaskIntoConstraints = false
            self.buttonOfRetry.isHidden = true
            self.buttonOfRetry.layer.cornerRadius = 44/2
            self.buttonOfRetry.clipsToBounds = true
            self.buttonOfRetry.titleLabel?.font = UIFont.Poppins.medium(10)
            self.buttonOfRetry.setTitleColor(.white, for: .normal)
            self.buttonOfRetry.setTitle(self.sayNoSection.getButtonTitle, for: .normal)
            self.buttonOfRetry.addCenterX(inSuperView: sayNoView)
            self.buttonOfRetry.addTop(isRelateTo: innerStackView, isSuperView: sayNoView, constant: 20)
            self.buttonOfRetry.addHeight(constant: 44)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.buttonOfRetry.backgroundColor = UIColor.blueHeading
            }
            self.buttonOfRetry.addTarget(self, action: #selector(self.retryActionListener(sender:)), for: .touchUpInside)
        }

    }
    
    var buttonClosure: (()->())? = nil
    var isShowingNoResults: Bool = false
    public func showNoResults(retryClosure: (()->())? = nil) {
        self.sayNoView.isHidden = false
        self.signInOutletStackView?.isHidden = false
        self.isShowingNoResults = true
        UIView.animate(withDuration: 0.2) {
            self.sayNoView.alpha = 1.0
            self.layoutIfNeeded()
        }
        
        if retryClosure != nil {
            self.buttonOfRetry.isHidden = false
            self.buttonClosure = retryClosure
        }else{
            self.buttonOfRetry.isHidden = true
            self.buttonClosure?()
        }
    }
    
    @objc func retryActionListener(sender: UIButton) {
        self.buttonClosure?()
    }
    
    var otherButtonClosure: (()->())? = nil
    @objc func otherButtonActionListener(sender: UIButton) {
        self.otherButtonClosure?()
    }
    
    public func dontShowNoResults() {
        self.sayNoView.isHidden = true
        self.signInOutletStackView?.isHidden = true
        self.isShowingNoResults = false
        UIView.animate(withDuration: 0.2) {
            self.sayNoView.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
    public func figureOutAndShowNoResults() {
        if self.visibleCells.count == 0 {
            self.showNoResults()
        }else{
            self.dontShowNoResults()
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


class SayNoForDataCollectionView: PaginationCollectionView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addActivityIndicator()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame,collectionViewLayout:layout)
        self.addActivityIndicator()
    }
    public enum SayNoSection {
        case noExpertFound(String)
        case none
        
        var getTitle: String {
            switch self {
            case .noExpertFound(let title):
                return title
            default:
                return ""
            }
        }
        
        var getDetail: String {
            switch self {
            case .noExpertFound:
                return localizeFor("try_searching_for_something_else")
            default:
                return ""
            }
        }
        
        var getPlaceHolderImage: UIImage {
            switch self {
            case .noExpertFound:
                return UIImage.init(named: "noresultfound_search_icon")!
            default:
                return UIImage()
            }
        }
        
        var getTitleTextColor: UIColor {
            switch self {
            case  .noExpertFound:
                return UIColor.lightGray
            default:
                return UIColor.black
            }
        }
    }
    public var sayNoSection: SayNoSection = .none {
        didSet {
            switch sayNoSection {
            case .noExpertFound:
                setSearchSectionSuggestionsSayNo(topGap: 16.0)
            default:
                break
            }
        }
    }
    
    var continueShowingSection: Bool = false {
        didSet {
            if signInOutletStackView != nil{
                self.signInOutletStackView?.isHidden = !self.continueShowingSection
            }
        }
    }
    
    private let sayNoView: UIView = UIView.init(frame: .zero)
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(frame: .zero)
    var isRefreshing: Bool = false {
        didSet {
            self.isAnimating = self.isRefreshing
            if self.isRefreshing {
                self.signInOutletStackView?.isHidden = true
            }else{
                self.signInOutletStackView?.isHidden = false
            }
        }
    }
    var isAnimating: Bool = false  // just a clone of isRefreshing
    
    public func startAnimating() {
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        self.bringSubviewToFront(activityIndicator)
        
        // hide all cells while indicator working
        for cell in visibleCells {
            cell.isHidden = true
        }
    }
    public func stopAnimating() {
        activityIndicator.stopAnimating()
        // show all cells while indicator working
        for cell in visibleCells {
            cell.isHidden = false
        }
    }
    
    // Added activity indicator, not related to no results kinda.....
    var topConstraintOfActivityIndicator: NSLayoutConstraint? = nil
    private func addActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        self.topConstraintOfActivityIndicator = activityIndicator.addTop(isSuperView: self, constant: 16)
        activityIndicator.addCenterX(inSuperView: self)
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    func setAcitivityTopConstraint(_ constant: CGFloat) {
        self.topConstraintOfActivityIndicator?.constant = constant
    }
    
    // specific
    let imageview: UIImageView = UIImageView.init(frame: .zero)
    let noResultsFoundLabel: UILabel = UILabel.init(frame: .zero)
    let noResultsDetailFoundLabel: UILabel = UILabel.init(frame: .zero)
    var signInOutletStackView: UIStackView? = nil
    private func setSearchSectionSuggestionsSayNo(_ isCenter: Bool = false, topGap: CGFloat = 50.0) {
        
        sayNoView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sayNoView)
        sayNoView.addSurroundingZero(isSuperView: self)
        sayNoView.isHidden = true
        // sayNoView.isUserInteractionEnabled = false
        
        signInOutletStackView?.removeFromSuperview()
        signInOutletStackView = UIStackView.init(frame: .zero)
        signInOutletStackView!.translatesAutoresizingMaskIntoConstraints = false
        sayNoView.addSubview(signInOutletStackView!)
        
        signInOutletStackView!.addLeft(isSuperView: self, constant: 30.0)
        signInOutletStackView!.addRight(isSuperView: self, constant: -30.0)
        if isCenter {
            signInOutletStackView!.addCenterY(inSuperView: self, multiplier: 0.8)
        }else{
            signInOutletStackView!.addTop(isSuperView: self, constant: Float(topGap))
        }
        signInOutletStackView!.spacing = 20
        signInOutletStackView!.axis = .vertical
        
        imageview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageview)
        imageview.image = self.sayNoSection.getPlaceHolderImage//cueImage.SearchSection.sayno_suggestions_search
        imageview.contentMode = .center
        signInOutletStackView!.addArrangedSubview(imageview)
        
        let innerStackView = UIStackView.init(frame: .zero)
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.spacing = 8
        innerStackView.axis = .vertical
        signInOutletStackView!.addArrangedSubview(innerStackView)
        
        noResultsFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.addArrangedSubview(noResultsFoundLabel)
        noResultsFoundLabel.text = self.sayNoSection.getTitle//cuePlaceholder.noResults.title
        noResultsFoundLabel.textAlignment = .center
        noResultsFoundLabel.font = UIFont.Poppins.semiBold(12.7)
        noResultsFoundLabel.textColor = UIColor.blueHeading
        
        noResultsDetailFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.addArrangedSubview(noResultsDetailFoundLabel)
        noResultsDetailFoundLabel.text = self.sayNoSection.getDetail
        noResultsDetailFoundLabel.font = UIFont.Poppins.medium(13.3)
        noResultsDetailFoundLabel.textColor = UIColor.blueHeadingAlpha30
        noResultsDetailFoundLabel.numberOfLines = 3
        noResultsDetailFoundLabel.lineBreakMode = .byWordWrapping
        noResultsDetailFoundLabel.textAlignment = .center
        
        
    }
    
    func setDetailLabelWhenProviderNotAvailable(detailText:String){
        if !detailText.isEmpty{
            noResultsDetailFoundLabel.text = detailText
        }else{
            noResultsFoundLabel.text = sayNoSection.getTitle
        }
    }
    
    func showNoResults() {
        sayNoView.isHidden = false
        signInOutletStackView?.isHidden = false
    }
    func dontShowNoResults() {
        sayNoView.isHidden = true
        signInOutletStackView?.isHidden = true
    }
    
    
    func figureOutAndShowNoResults() {
        if self.visibleCells.count == 0 {
            sayNoView.isHidden = false
            signInOutletStackView?.isHidden = false
            //self.isScrollEnabled = false
        }else{
            sayNoView.isHidden = true
            signInOutletStackView?.isHidden = true
            //self.isScrollEnabled = true
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
