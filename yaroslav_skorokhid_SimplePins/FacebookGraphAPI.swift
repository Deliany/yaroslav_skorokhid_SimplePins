//
//  FacebookGraphAPI.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/16/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation

class FacebookGraphAPI {
    typealias Completion = ((user: User?, errorString: String?) -> Void)
    
    class func requestWithHTTPMethod(method: String, URL: NSURL) -> NSURLRequest {
        let mutableRequest = NSMutableURLRequest(URL: URL)
        mutableRequest.HTTPMethod = method
        return mutableRequest
    }
    
    class func getProfileDetails(completion: Completion) {
        guard let credentials = SettingsService.facebookCredentials where !credentials.isExpired() else {
            completion(user: nil, errorString: NSLocalizedString("Credentials not found or expired", comment: ""))
            return
        }
        let url = NSURL(string: "https://graph.facebook.com/me?access_token=\(credentials.accessToken)&fields=id,name,picture.height(200)")!
        let request = self.requestWithHTTPMethod("GET", URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let data = data where error == nil {
                var user: User?
                if let deserializedResponse = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves) as? [String: AnyObject],
                        id = deserializedResponse?["id"] as? String,
                        name = deserializedResponse?["name"] as? String {
                        var avatarURL: NSURL?
                        if let pictureInfo = deserializedResponse?["picture"] as? [String: AnyObject], data = pictureInfo["data"] as? [String: AnyObject], url = data["url"] as? String {
                            avatarURL = NSURL(string: url)
                        }
                        user = User(id: id, name: name, avatarURL: avatarURL)
                }
                completion(user: user, errorString: nil)
            }
            else {
                completion(user: nil, errorString: error?.localizedDescription)
            }
        }
        task.resume()
    }
}