//
//  CountrySelectionViewModel.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

class CountrySelectionViewModel {
    struct CountryDataModel {
        var id = ""
        var countryName = ""
        var dialCode = ""
        var code = ""
        var region = ""
        var continent = ""
        
        init(id: String, countryName: String, dialCode: String) {
            self.id = id
            self.countryName = countryName
            self.dialCode = dialCode
        }
        
        init(dict: JSON){
            id = dict["id"].stringValue
            countryName = dict["countryName"].stringValue
            dialCode = dict["dialCode"].stringValue
            code = dict["code"].stringValue
            region = dict["region"].stringValue
            continent = dict["continent"].stringValue
        }
    }
    
    struct Section {
        let letter : String
        var countries : [CountryDataModel]
    }
    
    var sections = [Section]()
    var sectionsAll = [Section]()
    var selectedCountry: CountryDataModel?
    var allCountries: [CountryDataModel] = []
    
    func callCountrySelectionAPI(param: [String: Any],
                                 success: @escaping ()->(),
                                 failure: (()->())? = nil,
                                 internetFailure: (()->())? = nil) {
        API_LOADER.delegate = self
        API_SERVICES.callAPI(param, path: .countrySelection, method: .get) { (parsingResponse) in
            API_LOADER.dismiss(animated: true)
            // debugPrint("parsingResponse: \(parsingResponse)")
            
            if self.parseCountries(parsingResponse) {
                success()
            }else{
                NetworkingManager.shared.showSomethingWentWrong()
            }
        } failure: { _ in
            failure?()
        } internetFailure: {
            internetFailure?()
        }
    }
    
    // Parsing data
    func parseCountries(_ response: [String : JSON]?) -> Bool {
        guard let countryJsonArray = response?["payload"]?.arrayValue else { return false }
        
        // Get default selected country
        var countryName: String? = nil
        if let countryCodeLocale = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCodeLocale) {
                countryName = name
            }
        }
        
        self.allCountries.removeAll()
        for countryDictJson in countryJsonArray {
            let country = CountryDataModel(dict: countryDictJson)
            if let strongCountryName = countryName, strongCountryName == country.countryName{
                self.selectedCountry = country
            }
            self.allCountries.append(country)
        }
        
        COUNTRY_SELECTION_VIEWMODEL.selectedCountry =  selectedCountry == nil ? self.allCountries.first : selectedCountry
        sectionsAll = filterInSections(countries: self.allCountries)
        sections = sectionsAll
        return true
    }

    private func filterInSections(countries: [CountryDataModel]) -> [Section] {
        let groupedDictionary = Dictionary(grouping: countries, by: { String($0.countryName.prefix(1)) })
        let keys = groupedDictionary.keys.sorted()
        // map the sorted keys to a struct
        let sectionArray = keys.map {
            Section(letter: $0,
                    countries: groupedDictionary[$0]!.sorted(by: { $0.countryName < $1.countryName }))
        }
        return sectionArray
    }
    
    private func getCountryDummyArray() -> [CountryDataModel] {
        var countries: [CountryDataModel] = []
        var countryId = 1
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(CountryDataModel(id: "\(countryId)", countryName: name, dialCode: "+\(countryId)"))
            countryId += 1
        }
        return countries
    }

}


extension CountrySelectionViewModel: GenericLoaderViewDelegate {
    func apiCancellationRequested() {
        API_SERVICES.cancelAllRequests() // cancel api requests...
    }
}
