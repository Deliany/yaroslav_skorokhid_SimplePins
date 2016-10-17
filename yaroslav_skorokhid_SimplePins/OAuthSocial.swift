//
//  OAuthSocial.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import Foundation

class OAuthSocial {
    var baseURL: String
    var authPath: String
    var clientID: String
    var clientSecret: String?
    var responseType: String
    var redirectURI: NSURL
    var scope: String?
    
    private let OAuthControllerAccessTokenKey = "access_token"
    private let OAuthControllerErrorKey = "error"
    private let OAuthControllerAccessDeniedKey = "access_denied"
    private let OAuthControllerCodeKey = "code"
    
    var authorizeHandler: (() -> Void)?
    var authorizeCompletionClosure: ((credentials: OAuthCredentials?, errorString: String?) -> Void)?
    
    init(baseURL: String, authPath: String, clientID: String, clientSecret: String?, responseType: String, redirectURI: NSURL, scope: String?) {
        self.baseURL = baseURL
        self.authPath = authPath
        self.clientID = clientID
        self.responseType = responseType
        self.redirectURI = redirectURI
        self.scope = scope
    }
    
    func authorize() {
        self.authorizeHandler?()
    }
    
    func handleRedirectURL(url: NSURL) {
        let response = OAuthResponseParser.parseURL(url)
        self.processResponse(response)
    }
    
    private func processResponse(response: [String: AnyObject]) {
        if let error = response[OAuthControllerErrorKey] as? String {
            self.authorizeCompletionClosure?(credentials: nil, errorString: error)
        }
        else if let _ = response[OAuthControllerAccessTokenKey] as? String {
            self.authorizeCompletionClosure?(credentials: OAuthManager.credentialsByResponse(response), errorString: nil)
        }
        else if let accessCode = response[OAuthControllerCodeKey] as? String {
            self.authorizeWithAccessCode(accessCode)
        }
        else {
            self.authorizeCompletionClosure?(credentials: nil, errorString: NSLocalizedString("Error while processing response", comment: ""))
        }
    }
    
    private func authorizeWithAccessCode(accessCode: String) {
        OAuthManager.authenticateWithSocialOAuth(self, code: accessCode) { [weak self] (response, errorString) in
            if let response = response {
                self?.processResponse(response)
            }
            else if let error = errorString {
                self?.authorizeCompletionClosure?(credentials: nil, errorString: error)
            }
        }
    }
    
    func OAuthURL() -> NSURL {
        var stringURL = self.defaultOAuthStringURL()
        stringURL += "&response_type=\(self.responseType)"
        if let scope = self.scope {
            stringURL += "&scope=\(scope)"
        }
        let additionalParameters = self.OAuthURLAdditionalParameters()
        for (key, value) in additionalParameters {
            stringURL += "&\(key)=\(value)"
        }
        stringURL += "&grant_type=password"
        let OAuthURL = NSURL(string: stringURL)!
        return OAuthURL
    }
    
    func OAuthAccessTokenByCode(code: String) -> NSURL {
        var stringURL = self.defaultOAuthStringURL()
        stringURL += "&code=\(code)&clientSecret=\(self.clientSecret)&grant_type=authorization_code"
        let OAuthURL = NSURL(string: stringURL)!
        return OAuthURL
    }
    
    func OAuthURLAdditionalParameters() -> [String: AnyObject] {
        return [:]
    }
    
    private func defaultOAuthStringURL() -> String {
        return "\(self.baseURL)\(self.authPath)?client_id=\(self.clientID)&redirect_uri=\(self.redirectURI)"
    }
}