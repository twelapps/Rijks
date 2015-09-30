//
//  RijksWebsite.swift
//  Rijks
//
//  Created by Twelker on Sep/21/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit

class RijksWebsite: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView       : UIWebView!
    @IBOutlet weak var actInd        : UIActivityIndicatorView!
    @IBOutlet weak var messageField  : UITextView!
    
    override func viewDidLoad () {
        super.viewDidLoad ()
        
        messageField.editable     = false                           // Do not allow editing of the message field
        messageField.scrollRangeToVisible(NSMakeRange(0,0))         // Let beginning of text start at upper left corner of text view
        messageField.alpha        = 0.0                             // Do not display it initially
        
        actInd.startAnimating()
        
        webView.delegate          = self
        
        // Construct object to be requested from the Web
        let RijksWebsiteUrl       = NSURL(string: Rijks.Constants.RijksWebsiteUrlString)
        let RijksWebsiteUrlReqObj = NSURLRequest(URL: RijksWebsiteUrl!)
        
        webView.scalesPageToFit   = true // Scales web page until it fits the window
        
        webView.loadRequest(RijksWebsiteUrlReqObj)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        throwMessage(Rijks.Constants.msgNoWebsite, color: UIColor.redColor())
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        actInd.stopAnimating()
    }
    
    func throwMessage (message: String, color: UIColor) {
        self.view.endEditing(true)  // Always end editing first
            messageField.backgroundColor = color
            messageField.alpha           = 1.0
            messageField.text            = message
            actInd.stopAnimating()
    }
    
} // End of class RijksWebsite
