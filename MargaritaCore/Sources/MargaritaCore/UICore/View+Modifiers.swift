//
//  View+Modifiers.swift
//  
//
//  Created by Damjan on 26.05.2022.
//

import SwiftUI

extension View {

    public func flow() -> NavigationView<Self> {
        NavigationView {
            self
        }
    }
}
