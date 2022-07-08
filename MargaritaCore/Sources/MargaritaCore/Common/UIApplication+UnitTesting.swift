//
//  UIApplication+UnitTesting.swift
//  
//
//  Created by Damjan on 27.06.2022.
//

import UIKit

extension UIApplication {

    public static var isRunningUnitTests: Bool {
        NSClassFromString("XCTest") != nil
    }
}
