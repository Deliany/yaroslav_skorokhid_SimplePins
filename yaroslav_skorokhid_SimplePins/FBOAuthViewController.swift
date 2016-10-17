//
//  FBOAuthViewController.swift
//  yaroslav_skorokhid_SimplePins
//
//  Created by Yaroslav Skorokhid on 10/15/16.
//  Copyright © 2016 CollateralBeauty. All rights reserved.
//

import UIKit

class FBOAuthViewController: UIViewController {

    @IBOutlet private weak var webView: UIWebView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var cancelClosure: ((controller: FBOAuthViewController) -> Void)?
    var completionClosure: ((credentials: OAuthCredentials?, errorString: String?, controller: FBOAuthViewController) -> Void)?
    
    private var socialOAuth: OAuthSocial!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.socialOAuth = FacebookOAuth()
        let url = self.socialOAuth.OAuthURL()
        self.socialOAuth.authorizeHandler = { [weak self] in
            self?.webView.loadRequest(NSURLRequest(URL: url))
        }
        self.socialOAuth.authorizeCompletionClosure = { [weak self] (credentials: OAuthCredentials?, errorString: String?) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.completionClosure?(credentials: credentials, errorString:errorString, controller: strongSelf)
        }
        self.activityIndicator.startAnimating()
        self.socialOAuth.authorize()
    }
    
    @objc
    @IBAction private func cancelButtonPressed(sender: AnyObject) {
        self.cancelClosure?(controller: self)
    }
}

extension FBOAuthViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var shouldStart = false
        if let URL = request.URL where URL.host == self.socialOAuth.redirectURI.host ||
            URL.absoluteString.rangeOfString("access_token=") != nil ||
            URL.absoluteString.rangeOfString("error=") != nil {
            self.socialOAuth.handleRedirectURL(URL)
        }
        else {
            shouldStart = true
        }
        return shouldStart
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.activityIndicator.stopAnimating()
    }
}
