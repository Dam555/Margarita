//
//  Margarita.swift
//  Margarita
//
//  Created by Damjan on 18.05.2022.
//
//

import Foundation
import CoreData

@objc(Margarita)
public class Margarita: NSManagedObject {

    @NSManaged public var glass: String
    @NSManaged public var id: String
    @NSManaged public var imageUrl: URL
    @NSManaged public var instructions: String
    @NSManaged public var name: String
}

extension Margarita {

    func set(from cocktail: Cocktail) {
        id = cocktail.id
        name = cocktail.name
        glass = cocktail.glass
        instructions = cocktail.instructions
        imageUrl = cocktail.imageUrl
    }
}
