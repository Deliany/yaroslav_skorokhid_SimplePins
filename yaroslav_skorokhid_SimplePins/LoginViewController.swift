//
//  LoginViewController.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let fbOAuthSegueIdentifier = "FBOAuthSegue"
    let homeSegueIdentifier = "HomeSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.checkSession()
    }
    
    func checkSession() {
        if let fbCredentials = SettingsService.facebookCredentials where !fbCredentials.isExpired() {
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.performSegueWithIdentifier(self.homeSegueIdentifier, sender: nil)
            })
        }
    }
    
    func showErorAlertWithText(text: String) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: text, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.fbOAuthSegueIdentifier, let navigationController = segue.destinationViewController as? UINavigationController, authController = navigationController.topViewController as? FBOAuthViewController {
            authController.cancelClosure = {
                $0.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
            authController.completionClosure = { (credentials: OAuthCredentials?, errorString: String?, controller: FBOAuthViewController) -> Void in
                
                if let credentials = credentials {
                    // do something with credentials
                    SettingsService.facebookCredentials = credentials
                    controller.navigationController?.dismissViewControllerAnimated(true, completion: {
                        self.checkSession()
                    })
                }
                else if let error = errorString {
                    controller.navigationController?.dismissViewControllerAnimated(true, completion: {
                        self.showErorAlertWithText(error)
                    })
                }
            }
        }
    }

}
