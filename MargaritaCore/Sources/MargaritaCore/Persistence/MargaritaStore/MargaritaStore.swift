//
//  MargaritaStore.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import CoreData

public class MargaritaStore: Store<Margarita> {

    public func update(with cocktails: [Cocktail]) throws {
        let fetchRequest = try makeFetchRequest()
        var margaritas = try executeFetchRequest(fetchRequest)
            .reduce(into: [String: Margarita]()) { result, margarita in
                result[margarita.id] = margarita
            }

        // Update existing margaritas or add new ones.
        for cocktail in cocktails {
            let margarita = margaritas[cocktail.id] ?? addObject()
            margarita.set(from: cocktail)
            margaritas.removeValue(forKey: cocktail.id)
        }

        // Delete non existent margaritas.
        for margarita in margaritas.values {
            deleteObject(margarita)
        }

        try save()
    }

    public func allMargaritas() throws -> [MargaritaData] {
        let fetchRequest = try makeFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Margarita.name, ascending: true)]
        return try executeFetchRequest(fetchRequest)
            .map {
                MargaritaData(margarita: $0)
            }
    }

    public func margarita(with id: Identifier) throws -> MargaritaData {
        let fetchRequest = try makeFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        if let margarita = try executeFetchRequest(fetchRequest).first {
            return MargaritaData(margarita: margarita)
        } else {
            throw StoreError.objectNotFound
        }
    }
}
