//
//  UIViewController+alert.swift
//  Combinestagram
//
//  Created by ST21235 on 2018/02/15.
//  Copyright © 2018 Underplot ltd. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UIViewController {
    func alert(title: String, message: String?) -> Completable {
        return Completable.create(subscribe: { [weak self] completable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in completable(.completed)}))
            self?.present(alert, animated: true, completion: nil)

            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        })
    }
}
