//
//  MargaritaData.swift
//  
//
//  Created by Damjan on 27.06.2022.
//

import Foundation

public struct MargaritaData: Identifiable {

    public var id: String
    public var name: String
    public var glass: String
    public var instructions: String
    public var imageUrl: URL

    public init(margarita: Margarita) {
        self.id = margarita.id
        self.name = margarita.name
        self.glass = margarita.glass
        self.instructions = margarita.instructions
        self.imageUrl = margarita.imageUrl
    }

    public init(id: String, name: String, glass: String, instructions: String, imageUrl: URL) {
        self.id = id
        self.name = name
        self.glass = glass
        self.instructions = instructions
        self.imageUrl = imageUrl
    }
}
