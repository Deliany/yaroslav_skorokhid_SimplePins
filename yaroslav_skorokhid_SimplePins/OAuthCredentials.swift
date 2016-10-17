//
//  OAuthCredentials.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation

class OAuthCredentials: NSObject, NSCoding {
    var accessToken: String
    var tokenType: String?
    var refreshToken: String?
    var expirationDate: NSDate?
    
    required init(token: String, tokenType: String?) {
        self.accessToken = token
        self.tokenType = tokenType
    }
    
    func isExpired() -> Bool {
        guard let expirationDate = self.expirationDate else {
            return false
        }
        return expirationDate.compare(NSDate()) == .OrderedAscending
    }
    
    // MARK: - NSCoding
    
    @objc convenience required init?(coder aDecoder: NSCoder) {
        let accessToken = aDecoder.decodeObjectForKey("accessToken") as! String
        let tokenType = aDecoder.decodeObjectForKey("tokenType") as? String
        let refreshToken = aDecoder.decodeObjectForKey("refreshToken") as? String
        let expirationDate = aDecoder.decodeObjectForKey("expirationDate") as? NSDate
        self.init(token: accessToken, tokenType: tokenType)
        self.refreshToken = refreshToken
        self.expirationDate = expirationDate
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.accessToken, forKey: "accessToken")
        aCoder.encodeObject(self.tokenType, forKey: "tokenType")
        aCoder.encodeObject(self.refreshToken, forKey: "refreshToken")
        aCoder.encodeObject(self.expirationDate, forKey: "expirationDate")
    }
}
