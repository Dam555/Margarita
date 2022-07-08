//
//  MargaritaDetailView.swift
//  Margarita
//
//  Created by Damjan on 17.05.2022.
//

import Combine
import MargaritaCore
import SwiftUI

struct MargaritaDetailView: View {

    @StateObject var model: MargaritaDetailModel

    private let layout = Layout()

    var body: some View {
        Group {
            if model.margaritaExists {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            Text(model.name)
                                .font(layout.nameFont)
                                .frame(width: geometry.size.width * layout.textWidthPerentage)
                                .padding([.top, .bottom], layout.verticalSpacing)

                            LoadingImage(url: $model.imageUrl, size: .constant(.large), downloadImage: model.downloadImage)
                                .frame(width: layout.imageWidth)
                                .padding(.bottom, layout.verticalSpacing)

                            Text(model.glass)
                                .font(layout.glassFont)
                                .frame(width: geometry.size.width * layout.textWidthPerentage)
                                .padding(.bottom, layout.verticalSpacing)

                            Text(model.instructions)
                                .font(layout.instructionsFont)
                                .lineSpacing(layout.instructionsLineSpacing)
                                .frame(width: geometry.size.width * layout.textWidthPerentage)
                                .padding(.bottom, layout.verticalSpacing)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    Text(Localized.noMargarita)
                        .font(layout.noMargaritaFont)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension MargaritaDetailView {

    struct Layout {
        let nameFont = Font.system(size: 20)
        let glassFont = Font.system(size: 16)
        let instructionsFont = Font.system(size: 16)
        let instructionsLineSpacing: CGFloat = 1.6
        let textWidthPerentage: CGFloat = 0.8
        let verticalSpacing: CGFloat = 20
        let imageWidth = UIScreen.main.bounds.size.width * 0.6
        let noMargaritaFont = Font.system(size: 17)
    }
}

#if !TESTING
struct MargaritaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MargaritaDetailModel(
            margaritaId: "1",
            margaritaFromStore: { _ in
                MargaritaData(id: "1",
                              name: "Name",
                              glass: "Glass",
                              instructions: "Instructions",
                              imageUrl: URL.empty)
            },
            downloadImage: { _, _ in
                Just(UIImage.add)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            }
        )
        return MargaritaDetailView(model: model)
    }
}
#endif
