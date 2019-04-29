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
class Place: Codable {
    var placeName: String
    var placeAddress: String
    var placeLatitude: CLLocationDegrees
    var placeLongitude: CLLocationDegrees
    init(placeName: String, placeAddress: String, placeLatitude: CLLocationDegrees, placeLongitude: CLLocationDegrees) {
        self.placeName = placeName
        self.placeAddress = placeAddress
        self.placeLatitude = placeLatitude
        self.placeLongitude = placeLongitude
    }
}
