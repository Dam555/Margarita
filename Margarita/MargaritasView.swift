//
//  MargaritasView.swift
//  Margarita
//
//  Created by Damjan on 17.05.2022.
//

import Combine
import MargaritaCore
import SwiftUI

struct MargaritasView: View {

    @StateObject var model: MargaritasModel
    let isNavigationEnabled: Bool

    private let layout = Layout()

    init(model: MargaritasModel, isNavigationEnabled: Bool = true) {
        self._model = StateObject(wrappedValue: model)
        self.isNavigationEnabled = isNavigationEnabled
    }

    var isAlertPresented: Binding<Bool> {
        Binding<Bool>(get: {
            model.presentedAlert != .none
        }, set: {
            guard !$0 else { return }
            model.presentedAlert = .none
        })
    }

    var body: some View {
        VStack {
            if model.isLoading {
                makeFullScreenLoadingView()
            } else {
                if model.margaritas.isEmpty {
                    makeFullScreenNoMargaritasView()
                } else {
                    List {
                        ForEach($model.margaritas) { margarita in
                            NavigationLink {
                                if isNavigationEnabled {
                                    makeMargaritaDetailView(id: margarita.id, isSubview: false)
                                } else {
                                    EmptyView()
                                }
                            } label: {
                                ImageTwoTextsGrid(imageUrl: margarita.imageUrl, topText: margarita.name, bottomText: margarita.glass, downloadImage: model.downloadImage)
                            }
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: layout.animationDuration), value: model.isLoading)
        .navigationTitle(Localized.margaritasTitle)
        .alert(isPresented: isAlertPresented) {
            switch model.presentedAlert {
            case .noInternet:
                return Alert(title: Text(Localized.errorTitle),
                             message: Text(Localized.errorNoInternet),
                             dismissButton: .cancel(Text(Localized.ok), action: { }))
            case .apiError:
                return Alert(title: Text(Localized.errorTitle),
                             message: Text(Localized.errorNewMargaritasNotAvailable),
                             dismissButton: .cancel(Text(Localized.ok), action: { }))
            case .unknownError:
                return Alert(title: Text(Localized.errorTitle),
                             message: Text(Localized.errorGeneral),
                             dismissButton: .cancel(Text(Localized.ok), action: { }))
            case .none:
                return Alert(title: Text(""))
            }
        }

        // iPad only - initial screen
        if model.isIPad {
            if model.isLoading {
                makeFullScreenLoadingView()
            } else {
                if let margarita = $model.margaritas.first {
                    makeMargaritaDetailView(id: margarita.id, isSubview: true)
                } else {
                    makeFullScreenNoMargaritasView()
                }
            }
        }
    }
}

private extension MargaritasView {

    func makeFullScreenLoadingView() -> some View {
        VStack {
            Spacer()
            LoadingProgressView()
            Spacer()
        }
        .ignoresSafeArea()
    }

    func makeFullScreenNoMargaritasView() -> some View {
        VStack {
            Spacer()
            Text(Localized.noMargaritas)
                .font(layout.noMargaritasFont)
                .foregroundColor(.gray)
            Spacer()
        }
        .ignoresSafeArea()
    }

    func makeMargaritaDetailView(id: Identifier, isSubview: Bool) -> MargaritaDetailView {
        let detailModel = MargaritaDetailModel(margaritaId: id,
                                               margaritaFromStore: isSubview ? model.margaritaFromStore : MargaritaStore().margarita(with:),
                                               downloadImage: isSubview ? model.downloadImage : ImageDownloader().image(from:size:))
        return MargaritaDetailView(model: detailModel)
    }
}

private extension MargaritasView {

    struct Layout {
        let noMargaritasFont = Font.system(size: 17)
        let animationDuration: TimeInterval = 0.25
    }
}

#if !TESTING
struct MargaritasView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MargaritasModel(
            isIPad: false,
            margaritasFromApi: {
                Just([])
                    .setFailureType(to: ApiError.self)
                    .eraseToAnyPublisher()
            }, saveMargaritas: { _ in
            }, margaritasFromStore: {
                [
                    MargaritaData(id: "1",
                                  name: "Name",
                                  glass: "Glass",
                                  instructions: "Instructions",
                                  imageUrl: URL.empty)
                ]
            }, margaritaFromStore: { _ in
                MargaritaData(id: "", name: "", glass: "", instructions: "", imageUrl: URL.empty)
            }, purgeImages: { _ in
            }, downloadImage: { _, _ in
                Just(UIImage.add)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            }
        )
        return MargaritasView(model: model)
    }
}
#endif
