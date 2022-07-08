//
//  UIImage+Images.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

import UIKit

extension UIImage {

    public static var margaritaSmall: UIImage {
        image(named: "margarita-small", ofType: "jpeg")
    }

    public static var margaritaLarge: UIImage {
        image(named: "margarita-large", ofType: "jpeg")
    }

    public static func image(named name: String, ofType type: String) -> UIImage {
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else { return UIImage() }
        return image
    }
}
