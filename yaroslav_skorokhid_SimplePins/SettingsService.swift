//
//  SettingsService.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation

class SettingsService {
    private static let fbCredentialsKey = "fbCredentials"
    class var facebookCredentials: OAuthCredentials? {
        get {
            if let data = NSUserDefaults.standardUserDefaults().valueForKey(fbCredentialsKey) as? NSData {
                let credentials = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? OAuthCredentials
                return credentials
            }
            return nil
            
        }
        set {
            if let credentials = newValue {
                let data = NSKeyedArchiver.archivedDataWithRootObject(credentials)
                NSUserDefaults.standardUserDefaults().setValue(data, forKey: fbCredentialsKey)
            }
            else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(fbCredentialsKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    private static let userKey = "user"
    class var currentUser: User? {
        get {
            if let data = NSUserDefaults.standardUserDefaults().valueForKey(userKey) as? NSData {
                let user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? User
                return user
            }
            return nil
        }
        set {
            if let user = newValue {
                let data = NSKeyedArchiver.archivedDataWithRootObject(user)
                NSUserDefaults.standardUserDefaults().setValue(data, forKey: userKey)
            }
            else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(userKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
//    private static let storedPinsKey = "storedPins"
//    class var storedPins: [Pin] {
//        get {
//            if let data = NSUserDefaults.standardUserDefaults().valueForKey(storedPinsKey) as? NSData {
//                if let pins = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Pin] {
//                    return pins
//                }
//            }
//            return []
//        }
//        set {
//            let data = NSKeyedArchiver.archivedDataWithRootObject(newValue)
//            NSUserDefaults.standardUserDefaults().setValue(data, forKey: storedPinsKey)
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }
//    }
    
    private static let addPinHelpSeenKey = "addPinHelpSeen"
    class var addPinHelpSeen: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(addPinHelpSeenKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: addPinHelpSeenKey)
        }
    }
    
    class func removeSessionData() {
        self.facebookCredentials = nil
        self.currentUser = nil
        self.addPinHelpSeen = false
//        self.storedPins = []
        NSURLSession.sharedSession().resetWithCompletionHandler({})
    }
}