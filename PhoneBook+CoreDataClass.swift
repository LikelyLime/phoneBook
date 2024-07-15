//
//  PhoneBook+CoreDataClass.swift
//  phoneBook
//
//  Created by 백시훈 on 7/15/24.
//
//

import Foundation
import CoreData

@objc(PhoneBook)
public class PhoneBook: NSManagedObject {
    public static let className = "PhoneBook"
    public enum Key{
        static let name = "name"
        static let number = "number"
        static let imageUrl = "imageUrl"
    }
}
