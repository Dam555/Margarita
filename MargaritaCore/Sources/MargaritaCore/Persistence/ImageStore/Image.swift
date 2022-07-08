//
//  Image+CoreDataClass.swift
//  Margarita
//
//  Created by Damjan on 18.05.2022.
//
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {

    @NSManaged public var largeFileName: String
    @NSManaged public var smallFileName: String
    @NSManaged public var url: URL
}
