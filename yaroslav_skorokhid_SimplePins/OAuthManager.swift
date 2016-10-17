//
//  OAuthManager.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation

class OAuthManager {
    
    typealias Completion = ((response: [String: AnyObject]?, errorString: String?) -> Void)
    
    class func requestWithHTTPMethod(method: String, URL: NSURL) -> NSURLRequest {
        let mutableRequest = NSMutableURLRequest(URL: URL)
        mutableRequest.HTTPMethod = method
        return mutableRequest
    }
    
    class func authenticateWithSocialOAuth(socialOAuth: OAuthSocial, code: String, completion: Completion) {
        let request = self.requestWithHTTPMethod("POST", URL: socialOAuth.OAuthAccessTokenByCode(code))
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let data = data where error == nil {
                let deserializedResponse = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as? [String: AnyObject]
                completion(response: deserializedResponse ?? [:], errorString: nil)
            }
            else {
                completion(response: nil, errorString: error?.localizedDescription)
            }
        }
        task.resume()
    }
    
    class func credentialsByResponse(response: [String: AnyObject]) -> OAuthCredentials {
        guard let accessToken = response["access_token"] as? String else {
            assert(false, "no access token in response")
        }
        let tokenType = response["token_type"] as? String
        let refreshToken = response["refresh_token"] as? String
        
        let credentials = OAuthCredentials(token: accessToken, tokenType: tokenType)
        credentials.refreshToken = refreshToken
        if let expiresIn = response["expires_in"] as? Double {
            credentials.expirationDate = NSDate().dateByAddingTimeInterval(expiresIn)
        }
        return credentials
    }
}