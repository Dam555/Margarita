//
//  NWPath+Availability.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import Network

extension NWPath {

    var isAvailable: Bool {
        status == .satisfied
    }
}
