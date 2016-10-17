//
//  FirstViewController.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkTokenExpiration()
    }

    func checkTokenExpiration() {
        if let fbCredentials = SettingsService.facebookCredentials {
            if fbCredentials.isExpired() {
                SettingsService.facebookCredentials = nil
                NSURLSession.sharedSession().resetWithCompletionHandler({})
                self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

