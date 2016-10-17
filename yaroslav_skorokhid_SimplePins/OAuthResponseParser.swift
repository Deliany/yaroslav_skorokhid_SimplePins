//
//  OAuthResponseParser.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation

class OAuthResponseParser {
    class func parseURL(url: NSURL) -> [String: AnyObject] {
        let stringResponseURL = url.absoluteString
        var separatedRange = stringResponseURL.rangeOfString("#")
        if separatedRange == nil {
            separatedRange = stringResponseURL.rangeOfString("?")
        }
        
        var responseParams: [String: AnyObject] = [:]
        if let separatedRange = separatedRange {
            let stringResponse = stringResponseURL.substringFromIndex(separatedRange.endIndex)
            let separatedResponse = stringResponse.componentsSeparatedByString("&")
            for value in separatedResponse {
                if let _ = value.rangeOfString("=") {
                    let separatedValue = value.componentsSeparatedByString("=")
                    if separatedValue.count == 2 {
                        responseParams[separatedValue[0]] = separatedValue[1]
                    }
                    
                }
            }
        }
        return responseParams
    }
}