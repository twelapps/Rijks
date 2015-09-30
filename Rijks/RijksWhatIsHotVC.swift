//
//  RijksWhatIsHotVC.swift
//  Rijks
//
//  Created by Twelker on Sep/30/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit

class RijksWhatIsHotVC: UIViewController {
    
    @IBOutlet weak var hotMessage   : UITextView!
    @IBOutlet weak var errorMessage : UITextView!
    @IBOutlet weak var actInd       : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hotMessage.editable = false                           // Do not allow editing of the artist name field
        hotMessage.scrollRangeToVisible(NSMakeRange(0,0))     // Let beginning of text start at upper left corner of text view
        hotMessage.text = ""                                  // Initiate
        errorMessage.editable = false                         // Do not allow editing of the artist name field
        errorMessage.scrollRangeToVisible(NSMakeRange(0,0))   // Let beginning of text start at upper left corner of text view
        errorMessage.alpha = 0                                // Not visible initially
        
        self.actInd.startAnimating()
        
        // Retrieve hot message here
        
        Rijks.sharedInstance.hotMessage() { (success, hotMessageReturned, errorString) in
            if success {
                
                // Display the hot message text returned
                dispatch_async(dispatch_get_main_queue(), {
                    self.actInd.stopAnimating()
                    self.hotMessage.text = hotMessageReturned
                })
            } else {
                self.throwMessage(Rijks.Constants.msgNoHotMessage)
            }
        }
        
    } // End of viewDidLoad
    
    func throwMessage (message: String) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.actInd.stopAnimating()
            self.errorMessage.alpha           = 1.0
            self.errorMessage.text            = message
        })
    }

    
}
