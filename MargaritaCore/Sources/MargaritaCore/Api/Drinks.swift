//
//  Drinks.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import Foundation

struct Drinks: Decodable {

    let drinks: [Cocktail]
}

public struct Cocktail: Decodable, Equatable {

    public let id: String
    public let name: String
    public let glass: String
    public let instructions: String
    public let imageUrl: URL

    public init(id: String, name: String, glass: String, instructions: String, imageUrl: URL) {
        self.id = id
        self.name = name
        self.glass = glass
        self.instructions = instructions
        self.imageUrl = imageUrl
    }

    enum CodingKeys: String, CodingKey {
        case id = "idDrink"
        case name = "strDrink"
        case glass = "strGlass"
        case instructions = "strInstructions"
        case imageUrl = "strDrinkThumb"
    }
}
