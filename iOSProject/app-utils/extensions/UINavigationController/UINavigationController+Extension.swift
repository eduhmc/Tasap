//
//  UINavigationController+Extension.swift
//  iOSProject
//
//  Created by Roger Arroyo on 8/27/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }

    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
