//
//  MoreViewController.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.avatarImageView.image = nil
        self.nameLabel.text = nil
        
        self.updateUserDetailsUI()
        FacebookGraphAPI.getProfileDetails { (user, errorString) in
            if let user = user {
                SettingsService.currentUser = user
                self.updateUserDetailsUI()
            }
        }
    }

    func updateUserDetailsUI() {
        if let user = SettingsService.currentUser {
            self.nameLabel.text = user.name
            
            // load image in old-ish way without caching
            // just to not include SDWebImage
            if let avatarURL = user.avatarURL {
                NSURLSession.sharedSession().dataTaskWithURL(avatarURL, completionHandler: { (data, response, error) in
                    if let data = data {
                        let image = UIImage(data: data)
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.avatarImageView.image = image
                        })
                    }
                }).resume()
            }
        }
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        SettingsService.removeSessionData()
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }

}

