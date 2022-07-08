//
//  MargaritaApp.swift
//  Margarita
//
//  Created by Damjan on 17.05.2022.
//

import MargaritaCore
import SwiftUI

@main
struct MargaritaApp: App {

    var body: some Scene {
        WindowGroup {
            Group {
                if UIApplication.isRunningUnitTests {
                    EmptyView()
                } else {
                    makeMargaritasView()
                        .flow()
                }
            }
        }
    }
}

private extension MargaritaApp {

    func makeMargaritasView() -> MargaritasView {
        let margaritaStore = MargaritaStore()
        let model = MargaritasModel(isIPad: UIDevice.current.userInterfaceIdiom == .pad,
                                    margaritasFromApi: Api().getMargaritaCocktails,
                                    saveMargaritas: margaritaStore.update(with:),
                                    margaritasFromStore: margaritaStore.allMargaritas,
                                    margaritaFromStore: margaritaStore.margarita(with:),
                                    purgeImages: ImageStore().purge(keepUrls:),
                                    downloadImage: ImageDownloader().image(from:size:))
        return MargaritasView(model: model)
    }
}
