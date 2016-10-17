//
//  File.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/16/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    
    var id: String
    var name: String
    var avatarURL: NSURL?
    
    init(id: String, name: String, avatarURL: NSURL?) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
    }
    
    // MARK: - NSCoding
    
    @objc convenience required init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObjectForKey("id") as! String
        let name = aDecoder.decodeObjectForKey("name") as! String
        var avatarURL: NSURL?
        if let avatarURLString = aDecoder.decodeObjectForKey("avatarURLString") as? String {
            avatarURL = NSURL(string: avatarURLString)
        }
        self.init(id: id, name: name, avatarURL: avatarURL)
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.avatarURL?.absoluteString, forKey: "avatarURLString")
    }
}