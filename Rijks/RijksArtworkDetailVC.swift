//
//  RijksArtworkDetailVC.swift
//  Rijks
//
//  Created by Twelker on Sep/26/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit

class RijksArtworkDetailVC: UIViewController {
    
    // Input parameters.
    var fileName    : String!
    var artistName  : String!
    var artworkName : String!
    
    @IBOutlet weak var imageView    : UIImageView!
    @IBOutlet weak var artist       : UITextView!
    @IBOutlet weak var artworkTitle : UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Copy the first 30 characters of artist's name as view's title
        let substrLength = min(30, artistName.characters.count)
        self.title = artistName.substringWithRange(Range<String.Index>(start: artistName.startIndex, end: artistName.startIndex.advancedBy(substrLength)))
        
        artist.editable = false                               // Do not allow editing of the artist name field
        artist.scrollRangeToVisible(NSMakeRange(0,0))         // Let beginning of text start at upper left corner of text view
        artworkTitle.editable = false                         // Do not allow editing of the artist name field
        artworkTitle.scrollRangeToVisible(NSMakeRange(0,0))   // Let beginning of text start at upper left corner of text view
        
        // Add photo image & photo description to the view and display the view
        let img = Rijks.sharedInstance.readImage(fileName)
        if img != nil {
            imageView.image = UIImage(data: img!)
        } else {
            imageView.image = UIImage()
        }
        
        artist.text = "" // Initialize
        if artistName != "" {
            artist.text = artistName
        }
        
        artworkTitle.text = "" // Initialize
        if artworkName != "" {
            artworkTitle.text = artworkName
        }

    } // End of viewDidLoad
    
}