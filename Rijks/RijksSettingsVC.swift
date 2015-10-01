//
//  RijksSettingsVC.swift
//  Rijks
//
//  Created by Twelker on Oct/1/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit

class RijksSettingsVC: UIViewController {
    

    @IBOutlet weak var atworkImageScrollableSwitch : UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View's title
        self.title = "Settings"
        
        
        // Get image scrollable parameter from "disk" and set the switch accordingly
        if Rijks.sharedInstance.imageScrollable() {
            atworkImageScrollableSwitch.setOn(true, animated: true)
        } else {
            atworkImageScrollableSwitch.setOn(false, animated: true)
        }
        
    } // End of viewDidLoad
    
    @IBAction func atworkImageScrollable (sender: AnyObject) {
        
        let imageScrollable: Bool = atworkImageScrollableSwitch.on ? true : false
        
        Rijks.sharedInstance.setImageScrollable(imageScrollable)
    }
    
}
