//
//  OnboardingVCTests.swift
//  DooTests
//
//  Created by Kiran Jasvanee on 20/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import XCTest
@testable import Doo

class OnboardingVCTests: AutoCountrySelectionTests {
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssertNotEqual(COUNTRY_SELECTION_VIEWMODEL.allCountries.count, 0)
        
        #if targetEnvironment(simulator)
        // your simulator code
        #else
        // running on deivce
        XCTAssertNotNil(COUNTRY_SELECTION_VIEWMODEL.selectedCountry)
        #endif
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
