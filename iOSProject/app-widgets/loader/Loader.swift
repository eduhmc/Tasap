//
//  LoadViewController.swift
//  iOSProject
//
//  Created by Eduardo Huerta-Mercado on 4/26/20.
//  Copyright © 2020 Eduardo Huerta-Mercado. All rights reserved.
//

import UIKit

class Loader: UIView {

var view: UIView!
@IBOutlet fileprivate weak var blurView: UIVisualEffectView!
@IBOutlet fileprivate weak var loader: UIActivityIndicatorView!

var targetView: UIView?

required init(forView view: UIView) {
    super.init(frame: view.bounds)
    targetView = view
    self._setup()
    targetView?.addSubview(self)
}
override init(frame: CGRect) {
    super.init(frame: frame)
    _setup()
}

required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self._setup()
}

private func _setup() {
    view = _loadViewFromNib()
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.translatesAutoresizingMaskIntoConstraints = true

    addSubview(view)
}

private func _loadViewFromNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView

    return nibView
}

func showLoading(withCompletion completion: (() -> Swift.Void)? = nil) {
    UIView.animate(withDuration: 0.5, animations: {
    }) { _ in
        completion?()
    }
}

func hideLoading() {
    UIView.animate(withDuration: 0.5, animations: {
    }) { _ in
        self.removeFromSuperview()
    }
}
}
