//
//  Pin.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/17/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

}
