//
//  Api+Init.swift
//  
//
//  Created by Damjan on 28.06.2022.
//

import Foundation

public extension Api {

    convenience init() {
        let apiClient = ApiClient()
        self.init(dataFromUrl: apiClient.data(from:))
    }
}
