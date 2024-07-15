//
//  PhoneBook+CoreDataProperties.swift
//  phoneBook
//
//  Created by 백시훈 on 7/15/24.
//
//

import Foundation
import CoreData


extension PhoneBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhoneBook> {
        return NSFetchRequest<PhoneBook>(entityName: "PhoneBook")
    }

    @NSManaged public var imageUrl: URL?
    @NSManaged public var name: String?
    @NSManaged public var number: String?

}

extension PhoneBook : Identifiable {

}
