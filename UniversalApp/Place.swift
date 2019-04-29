//
//  Place.swift
//  UniversalApp
//
//  Created by Kate Chen on 9/4/19.
//  Copyright © 2019 Kate Chen. All rights reserved.
//

import Foundation
import CoreLocation

/// Place class, which contains place name, address, latitude and longitude
class Place {
    var placeName: String
    var placeAddress: String
    var placeLatitude: Double
    var placeLongitude: Double
    init(placeName: String, placeAddress: String, placeLatitude: Double, placeLongitude: Double) {
        self.placeName = placeName
        self.placeAddress = placeAddress
        self.placeLatitude = placeLatitude
        self.placeLongitude = placeLongitude
    }
}
