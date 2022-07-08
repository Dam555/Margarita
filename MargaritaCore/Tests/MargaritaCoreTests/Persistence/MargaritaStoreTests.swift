//
//  MargaritaStoreTests.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

@testable import MargaritaCore
import TestsCore
import XCTest

class MargaritaStoreTests: BaseTestCase {

    func testUpdate() throws {
        let margaritaStore = MargaritaStore(objectContext: makeObjectContext())

        let cocktail1 = Cocktail(id: "1", name: "Name 1", glass: "Glass 1", instructions: "Instructions 1", imageUrl: URL(string: "https://domain.com/image1.jpg")!)
        let cocktail2 = Cocktail(id: "2", name: "Name 2", glass: "Glass 2", instructions: "Instructions 2", imageUrl: URL(string: "https://domain.com/image2.jpg")!)

        try margaritaStore.update(with: [cocktail1, cocktail2])

        let allMargaritas = try margaritaStore.allMargaritas()

        XCTAssertEqual(allMargaritas.count, 2)
        XCTAssertEqual(allMargaritas[0].id, "1")
        XCTAssertEqual(allMargaritas[0].name, "Name 1")
        XCTAssertEqual(allMargaritas[0].glass, "Glass 1")
        XCTAssertEqual(allMargaritas[0].instructions, "Instructions 1")
        XCTAssertEqual(allMargaritas[0].imageUrl, URL(string: "https://domain.com/image1.jpg")!)
        XCTAssertEqual(allMargaritas[1].id, "2")

        let cocktail1New = Cocktail(id: "1", name: "Name 1 New", glass: "Glass 1 New", instructions: "Instructions 1 New", imageUrl: URL(string: "https://domain.com/image1New.jpg")!)

        try margaritaStore.update(with: [cocktail1New])

        let allMargaritas2 = try margaritaStore.allMargaritas()

        XCTAssertEqual(allMargaritas2.count, 1)
        XCTAssertEqual(allMargaritas2[0].id, "1")
        XCTAssertEqual(allMargaritas2[0].name, "Name 1 New")
        XCTAssertEqual(allMargaritas2[0].glass, "Glass 1 New")
        XCTAssertEqual(allMargaritas2[0].instructions, "Instructions 1 New")
        XCTAssertEqual(allMargaritas2[0].imageUrl, URL(string: "https://domain.com/image1New.jpg")!)
    }

    func testMargaritaWithId() throws {
        let margaritaStore = MargaritaStore(objectContext: makeObjectContext())

        XCTAssertThrowsError(try margaritaStore.margarita(with: "1"))

        let margarita = margaritaStore.addObject()
        margarita.id = "1"
        margarita.imageUrl = URL.empty
        margarita.name = "Margarita name"
        margarita.glass = "Margarita glass"
        margarita.instructions = "Margarita instructions some very long instructions for two lines."
        try margaritaStore.save()

        XCTAssertNoThrow(try margaritaStore.margarita(with: "1"))
    }
}
