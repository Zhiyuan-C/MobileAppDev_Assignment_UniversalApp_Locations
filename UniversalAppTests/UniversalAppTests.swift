//
//  UniversalAppTests.swift
//  UniversalAppTests
//
//  Created by Kate Chen on 9/4/19.
//  Copyright © 2019 Kate Chen. All rights reserved.
//

import XCTest
@testable import UniversalApp

class UniversalAppTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    /// test case on Place class
    func testPlace(){
        // initialise
        let placeName = "Brisbane CBD"
        let placeAddress = "Brisbane"
        let placeLatitude = 12.5
        let placeLongitude = -25.25
        let place = Place(placeName: placeName, placeAddress: placeAddress, placeLatitude: placeLatitude, placeLongitude: placeLongitude)
        // Perform Test
        XCTAssertEqual(place.placeName, placeName)
        XCTAssertEqual(place.placeAddress, placeAddress)
        XCTAssertEqual(place.placeLatitude, placeLatitude)
        XCTAssertEqual(place.placeLongitude, placeLongitude)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
