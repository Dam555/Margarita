//
//  View+Snapshot.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

import SwiftUI

extension View {

    public func snapshotUIView(size: CGSize? = nil) -> UIView {
        let viewController = UIHostingController(rootView: self)

        let view = viewController.view!
        view.layoutMargins = .zero
        view.invalidateIntrinsicContentSize()

        let intrinsicContentSize = view.intrinsicContentSize

        let window = UIWindow(frame: CGRect(origin: .zero, size: intrinsicContentSize))
        window.rootViewController = viewController
        window.isHidden = false

        // Origin needs to be like this to prevent additional weird safe area top margin (20 pt).
        view.frame.origin = CGPoint(x: 10000, y: 10000)
        view.frame.size = size ?? intrinsicContentSize

        DispatchQueue.main.async {
            window.isHidden = true
            window.windowScene = nil
        }

        return view
    }
}
