//
//  PinsService.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/17/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation
import MapKit
import MagicalRecord

class PinsService {
    static let sharedInstance = PinsService()
    
    private(set) var pins: [Pin]
    
    private init() {
        self.pins = Pin.MR_findAll() as? [Pin] ?? []
    }
    
    private func updatePins() {
        self.pins = Pin.MR_findAll() as? [Pin] ?? []
    }
    
    func addPinWithTitle(title: String, formattedAddress: String, coordinate: CLLocationCoordinate2D) {
        MagicalRecord.saveWithBlockAndWait { localContext in
            if let pin = Pin.MR_createEntityInContext(localContext) {
                pin.title = title
                pin.formattedAddress = formattedAddress
                pin.latitude = coordinate.latitude
                pin.longitude = coordinate.longitude
            }
        }
        self.updatePins()
    }
    func removePin(pin: Pin) {
        MagicalRecord.saveWithBlockAndWait { localContext in
            pin.MR_deleteEntityInContext(localContext)
        }
        self.updatePins()
    }
}
