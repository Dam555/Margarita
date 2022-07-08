//
//  URL+Empty.swift
//  
//
//  Created by Damjan on 03.07.2022.
//

import Foundation

extension URL {

    public static var empty: URL {
        URL(string: "about:blank")!
    }
}
