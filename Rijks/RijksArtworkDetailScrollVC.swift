//
//  RijksArtworkDetailScrollVC.swift
//  Rijks
//
//  Created by Twelker on Oct/1/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit

class RijksArtworkDetailScrollVC: UIViewController, UIScrollViewDelegate {
    
    // Input parameters.
    var fileName    : String!
    var artistName  : String!
    var artworkName : String!
    
    @IBOutlet weak var imageScrollView    : UIScrollView!
    @IBOutlet weak var artist             : UITextView!
    @IBOutlet weak var artworkTitle       : UITextView!
    
    var myUIImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Copy the first 30 characters of artist's name as view's title
        let substrLength = min(30, artistName.characters.count)
        self.title = artistName.substringWithRange(Range<String.Index>(start: artistName.startIndex, end: artistName.startIndex.advancedBy(substrLength)))
        
        artist.editable = false                               // Do not allow editing of the artist name field
        artist.scrollRangeToVisible(NSMakeRange(0,0))         // Let beginning of text start at upper left corner of text view
        artworkTitle.editable = false                         // Do not allow editing of the artist name field
        artworkTitle.scrollRangeToVisible(NSMakeRange(0,0))   // Let beginning of text start at upper left corner of text view
        
        // Add artwork image & description to the view and display the view
        let img = Rijks.sharedInstance.readImage(fileName)
        if img != nil {
            myUIImageView = UIImageView(image: UIImage(data: img!))
        } else {
            myUIImageView = UIImageView(image: UIImage())
        }
        
        self.imageScrollView.maximumZoomScale = 1.0    // Determines how far you can zoom in
        // These images are high resolution so too much zooming in is not needed
        self.imageScrollView.minimumZoomScale = 0.1    // Determines how far you can zoom out
        self.imageScrollView.delegate = self
        
        self.imageScrollView.addSubview(myUIImageView)
        
        artist.text = "" // Initialize
        if artistName != "" {
            artist.text = artistName
        }
        
        artworkTitle.text = "" // Initialize
        if artworkName != "" {
            artworkTitle.text = artworkName
        }
        
    } // End of viewDidLoad
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return myUIImageView
    }
    
}
