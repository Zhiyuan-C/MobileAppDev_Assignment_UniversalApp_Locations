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
    var placeLatitude: CLLocationCoordinate2D
    var placeLongitude: CLLocationCoordinate2D
    init(placeName: String, placeAddress: String, placeLatitude: CLLocationCoordinate2D, placeLongitude: CLLocationCoordinate2D) {
        self.placeName = placeName
        self.placeAddress = placeAddress
        self.placeLatitude = placeLatitude
        self.placeLongitude = placeLongitude
    }
}
