//
//  Pin+CoreDataProperties.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/17/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var title: String
    @NSManaged var formattedAddress: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double

}
