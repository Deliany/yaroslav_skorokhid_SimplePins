//
//  SecondViewController.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FacebookGraphAPI.getProfileDetails { (response, errorString) in
            print(response)
        }
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        SettingsService.facebookCredentials = nil
        NSURLSession.sharedSession().resetWithCompletionHandler({})
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }

}

