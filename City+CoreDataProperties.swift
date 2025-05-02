//
//  City+CoreDataProperties.swift
//  zeliz22-FinalProject
//
//  Created by zaza elizbarashvili on 18/11/1403 AP.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var name: String?

}

extension City : Identifiable {

}
