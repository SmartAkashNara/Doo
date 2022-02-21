//
//  CountrySelectionViewController.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class CountrySelectionViewController: KeyboardNotifBaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var textFieldSearchBar: RightIconTextField!
    @IBOutlet weak var tableViewCountryList: SayNoForDataTableView!
    @IBOutlet weak var bottomConstraintTableView: NSLayoutConstraint!
    
    var selectCountryClouser:((CountrySelectionViewModel.CountryDataModel)->())?

    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setDefaults()
        
        // In case country selection not called.
        if COUNTRY_SELECTION_VIEWMODEL.allCountries.count == 0 || COUNTRY_SELECTION_VIEWMODEL.selectedCountry == nil {
            self.callGetCountryListApi()
        }
    }
    
    override func keyboardShown(keyboardHeight: CGFloat, duration: Double) {
        keyboardOpenClose(keyboardHeight - cueSize.bottomHeightOfSafeArea, duration)
    }

    override func keyboardDismissed(keyboardHeight: CGFloat, duration: Double) {
        keyboardOpenClose(0, duration)
    }

    func keyboardOpenClose(_ keyboardHeight: CGFloat, _ duration: Double) {
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.bottomConstraintTableView.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    func callGetCountryListApi() {
        API_LOADER.show(animated: true)
        COUNTRY_SELECTION_VIEWMODEL.callCountrySelectionAPI(param: [:]) {
            self.tableViewCountryList.reloadData()
        } failure: {
            API_LOADER.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
        } internetFailure: {
            API_LOADER.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Action listeners
extension CountrySelectionViewController {
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - User defined methods
extension CountrySelectionViewController {
    func configureTableView() {
        tableViewCountryList.dataSource = self
        tableViewCountryList.delegate = self
        tableViewCountryList.registerCellNib(identifier: DooTitle_1TVCell.identifier, commonSetting: true)
        tableViewCountryList.registerCellNib(identifier: DooTitleDownHeaderTVCell_1.identifier)
        tableViewCountryList.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableViewCountryList.sectionHeaderHeight = 0
        tableViewCountryList.backgroundColor = UIColor.clear
        tableViewCountryList.sectionIndexColor = UIColor.blueHeadingAlpha50
        tableViewCountryList.sectionIndexBackgroundColor = UIColor.blackAlpha3
        tableViewCountryList.sayNoSection = .noSearchResultFound("Search")
    }
    
    func setDefaults() {
        // swipe to back work
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        view.backgroundColor = UIColor.white
        viewStatusBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.backgroundColor = UIColor.grayCountryHeader
        viewNavigationBar.selectedCorners(radius: 16, [.bottomLeft, .bottomRight])
        
        textFieldSearchBar.leadingGap = 0
        textFieldSearchBar.borderStyle = .none
        textFieldSearchBar.attributedPlaceholder = NSAttributedString(string: localizeFor("search_country_placeholder"),
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.blueHeadingAlpha20])
        textFieldSearchBar.tintColor = UIColor.blueSwitch
        textFieldSearchBar.font = UIFont.Poppins.medium(14)
        textFieldSearchBar.textColor = UIColor.blueHeading
        textFieldSearchBar.backgroundColor = UIColor.clear
        textFieldSearchBar.returnKeyType = .search
        textFieldSearchBar.delegate = self
    }
}

// MARK: - UITableViewDataSource
extension CountrySelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        COUNTRY_SELECTION_VIEWMODEL.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return COUNTRY_SELECTION_VIEWMODEL.sections[section].countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DooTitle_1TVCell.identifier, for: indexPath) as! DooTitle_1TVCell
        cell.countryCellConfig(data: COUNTRY_SELECTION_VIEWMODEL.sections[indexPath.section].countries[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if COUNTRY_SELECTION_VIEWMODEL.sections[section].letter.isEmpty {
            return 0.01
        }
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UITableViewDelegate
extension CountrySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if COUNTRY_SELECTION_VIEWMODEL.sections[section].letter.isEmpty {
            return nil
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: DooTitleDownHeaderTVCell_1.identifier) as! DooTitleDownHeaderTVCell_1
        cell.countryHeaderConfig(data: COUNTRY_SELECTION_VIEWMODEL.sections[section].letter)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return COUNTRY_SELECTION_VIEWMODEL.sections.map{( $0.letter )}
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        print("title \(title), index \(index)")
        return index
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectCountryClouser == nil{
            COUNTRY_SELECTION_VIEWMODEL.selectedCountry = COUNTRY_SELECTION_VIEWMODEL.sections[indexPath.section].countries[indexPath.row]
            performSegue(withIdentifier: "unwindSegueFromCountrySelectionToLogin", sender: nil)
        }else{
            selectCountryClouser?(COUNTRY_SELECTION_VIEWMODEL.sections[indexPath.section].countries[indexPath.row])
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension CountrySelectionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.getSearchText(range: range, replacementString: string)
        if searchText.isEmpty{
            COUNTRY_SELECTION_VIEWMODEL.sections = COUNTRY_SELECTION_VIEWMODEL.sectionsAll
            removeCrossGreyIconAsSearchBarIsAlreadyEmpty() // remove grey icon when search bar is empty
        } else {
            setCrossGrayIcon() // show grey icon at right
            COUNTRY_SELECTION_VIEWMODEL.sections.removeAll()
            COUNTRY_SELECTION_VIEWMODEL.sectionsAll.forEach { (section) in
                let matchedCountries = section.countries.filter { (country) -> Bool in
                    return country.countryName.toNSString.localizedStandardContains(searchText)
                }
                if !matchedCountries.count.isZero() {
                    let filteredSection = CountrySelectionViewModel.Section(letter: section.letter, countries: matchedCountries)
                    COUNTRY_SELECTION_VIEWMODEL.sections.append(filteredSection)
                }
            }
        }
        debugPrint("sections count: \(COUNTRY_SELECTION_VIEWMODEL.sections)")
        self.tableViewCountryList.reloadData()
        self.tableViewCountryList.figureOutAndShowNoResults() // this is going to show or remove no results found stuff
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CountrySelectionViewController: RightIconTextFieldDelegate {
    func rightIconTapped(textfield: RightIconTextField) {
        textfield.text = ""
        COUNTRY_SELECTION_VIEWMODEL.sections = COUNTRY_SELECTION_VIEWMODEL.sectionsAll
        self.tableViewCountryList.reloadData()
        self.tableViewCountryList.figureOutAndShowNoResults() // this is going to show or remove no results found stuff
        removeCrossGreyIconAsSearchBarIsAlreadyEmpty()
    }
    
    // Searchbar helper functions.
    func setCrossGrayIcon() {
        if let rightIcon = UIImage(named: "imgCrossGray") {
            textFieldSearchBar.rightIcon = rightIcon
            textFieldSearchBar.rightIconButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
            textFieldSearchBar.delegateOfRightIconTextField = self
            textFieldSearchBar.setRightIconUserInteraction(to: true)
            textFieldSearchBar.rightIconButton.isHidden = false
        }
    }
    func removeCrossGreyIconAsSearchBarIsAlreadyEmpty() {
        textFieldSearchBar.delegateOfRightIconTextField = nil
        textFieldSearchBar.setRightIconUserInteraction(to: false)
        textFieldSearchBar.rightIconButton.isHidden = true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CountrySelectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
