//
//  FacebookOAuth.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation

class FacebookOAuth: OAuthSocial {
    init() {
        let clientID = NSBundle.mainBundle().infoDictionary!["FacebookAppID"] as! String
        let redirectURI = NSURL(string: "http://localhost/")!
        super.init(baseURL: "https://www.facebook.com/", authPath: "dialog/oauth", clientID: clientID, clientSecret: nil, responseType: "token", redirectURI: redirectURI, scope: "email")
    }
    
    override func OAuthURLAdditionalParameters() -> [String : AnyObject] {
        return ["display": "popup"]
    }
}