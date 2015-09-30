//
//  RijksArtistPickerVC.swift
//  Rijks
//
//  Created by Twelker on Sep/23/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit

protocol RijksArtistPickerVCDelegate {
    func artistPicker(artistPicker: RijksArtistPickerVC, didPickArtist artist: String?)
}

class RijksArtistPickerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView     : UITableView!
    @IBOutlet weak var searchBar     : UISearchBar!
    @IBOutlet weak var actInd        : UIActivityIndicatorView!
    @IBOutlet weak var messageField  : UITextView!

    
//    private var artists         = [Artist]()
    private var foundArtistsArray = [NSString]()
    
    // The delegate will typically be a view controller, waiting for the Artist Picker
    // to return an artist
    var delegate: RijksArtistPickerVCDelegate?
    
    // The most recent data download task. We keep a reference to it so that it can
    // be canceled every time the search text changes
    var searchTask: NSURLSessionDataTask?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        messageField.editable     = false                           // Do not allow editing of the message field
        messageField.scrollRangeToVisible(NSMakeRange(0,0))         // Let beginning of text start at upper left corner of text view
        messageField.alpha        = 0.0                             // Do not display it initially
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.delegate   = self
        tableView.dataSource = self
        searchBar.delegate   = self
        
        self.searchBar.becomeFirstResponder() // Move cursor to searchBar and pop up the keyboard
    }
    
    @IBAction func cancel (sender: UIBarButtonItem) {
        
        // Return to favorite artists view controller
        self.navigationController!.popViewControllerAnimated(false)
    }
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        // Start animation of the activity indicator
        actInd.startAnimating()
        
        // Initiate found artists array each time the searchbar text has changed
        foundArtistsArray = []
        
        // Start a new download
        searchTask = RijksDBClient().getListOfArtists (searchText) { result, error in
            
            // Handle the error case
            if let error = error {
                if error.localizedDescription != "cancelled" { // We cancel a task on purpose
                    self.throwMessage("Error searching for artists: \(error.localizedDescription)", color: UIColor.redColor())
                    return
                }
            } else {
                
                self.searchTask = nil // Reset searchtask
                
                // Copy result for processing in the tableView methods
                self.foundArtistsArray = result as! [NSString]
                
                // Reload the table on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView!.reloadData()
                }
                
                if self.foundArtistsArray.count == 0 { // No artists found
                    self.throwMessage(Rijks.Constants.msgNoArtistsFound, color: UIColor.redColor())
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder() // Remove the keyboard
        
    }
    
    // MARK: - Table View Delegate and Data Source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        actInd.stopAnimating()
        let CellReuseId = "ArtistSearchCell"
        let artist = foundArtistsArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as UITableViewCell!
        
        cell.textLabel!.text = artist as String
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundArtistsArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let artist = foundArtistsArray[indexPath.row]
        
        // Alert the delegate
        delegate?.artistPicker(self, didPickArtist: artist as String)
        
        // Return to favorite artists view controller
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func throwMessage (message: String, color: UIColor) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.searchBar.resignFirstResponder() // Remove the keyboard
            self.view.endEditing(true)  // Always end editing first
            self.messageField.backgroundColor = color
            self.messageField.alpha           = 1.0
            self.messageField.text            = message
            self.actInd.stopAnimating()
        })
    }

    
}