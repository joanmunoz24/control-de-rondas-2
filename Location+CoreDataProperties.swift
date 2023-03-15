//
//  Location+CoreDataProperties.swift
//  CurrentLocation
//
//  Created by Joan Muñoz on 05-05-23.
//
//

import Foundation
import CoreData


extension Location1 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longuitude: Double

}

extension Location1 : Identifiable {

}
