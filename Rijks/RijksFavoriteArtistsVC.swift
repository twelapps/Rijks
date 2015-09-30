//
//  RijksFavoriteArtistsVC.swift
//  Rijks
//
//  Created by Twelker on Sep/21/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit
import CoreData

class RijksFavoriteArtistsVC: UITableViewController, RijksArtistPickerVCDelegate {
    
    // Input
    var artists: [Artist]!
    
    private var navigationTitle = "" // Init
    
    @IBOutlet var myTableView: UITableView!
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    var currentDevice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use this routine to add TWO bar button items at the right hand side of the top navigation bar
        // (cannot be done in NIB)
        var addFavoriteBarButtonItem: UIBarButtonItem {
            return UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addFavoriteBarButtonItemClicked")
        }
        
        let toolbarButtonItems = [addFavoriteBarButtonItem, self.editButtonItem()]
        
        self.navigationItem.setRightBarButtonItems(toolbarButtonItems, animated: true)
        
        navigationTitle = navigationItem.title! // Save the title
        
        currentDevice = Rijks.sharedInstance.typeOfDevice()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = navigationTitle // Restore the title
    }
    
    func addFavoriteBarButtonItemClicked () {
        
        // Navigate to the GetDirectionsViewController
        let storyboard = self.storyboard
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("RijksArtistPickerVC") as! RijksArtistPickerVC
        nextVC.delegate = self // For returning output result
        
        navigationItem.title = "" // This ensures that the title of the back button of the next VC is "<" !! Otherwise it is too long.
        // Get it back in "viewWillAppear" when returning.
        
        self.navigationController!.pushViewController(nextVC, animated: false)
    }
    
    func artistPicker(artistPicker: RijksArtistPickerVC, didPickArtist artist: String?) {
        
        if let newArtist = artist {
            
            // Check to see if we already have this artist. If so, return.
            for a in artists {
                if a.name == newArtist {
                    return
                }
            }
            
            // The artist that was picked is from a different managed object context.
            // We need to make a new artist. The easiest way to do that is to make a dictionary.
            
            let dictionary: [String : AnyObject] = [
                Artist.Keys.Name      : newArtist
            ]
            
            // Now we create a new artist, using the shared Context
            let artistToBeAdded = Artist(dictionary: dictionary, context: sharedContext)
            
            // And add append the artist to the array as well
            artists.append(artistToBeAdded)
            
            // Finally we save the shared context, using the convenience method in
            // The CoreDataStackManager
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
        // Reload the table
        tableView!.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let artist = artists[indexPath.row]
        let CellIdentifier = "ArtistCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as UITableViewCell!
        cell.textLabel!.text = artist.name
        cell.textLabel!.backgroundColor = UIColor.lightGrayColor()
        if currentDevice == Rijks.Constants.iPhone {
            cell.textLabel!.textColor = UIColor.whiteColor() // White text on light grey background
        } else {
            if currentDevice == Rijks.Constants.iPad {
                cell.textLabel!.textColor = UIColor.blackColor() // Black text on white background, probably Apple bug that background goes white in stead of gray
            }
        }

        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("RijksArtworksCollectionVC") as! RijksArtworksCollectionVC
        
        nextVC.artist  = artists[indexPath.row]
        nextVC.artists = artists
        
        navigationItem.title = "" // This ensures that the title of the back button of the next VC is "<" !! Otherwise it is too long.
        // Get it back in "viewWillAppear" when returning.
        
        self.navigationController!.pushViewController(nextVC, animated: true)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let artist = artists[indexPath.row]
            
            // First check if all artist related artworks are already downloaded
            // Check if all photos are there
            if artist.artworks.count > 0 {
                var allArtworksPresent = true
                for ind in 0...artist.artworks.count-1 {
                    if artist.artworks[ind].fileName == "" {
                        allArtworksPresent = false
                    }
                }
                if allArtworksPresent {
                    deleteArtist(artist, index: indexPath)
                } else { // Not all artworks present yet, disallow removing artist and show alert
                    
                    let alert = UIAlertController(title: "Oops!", message:"Shouldn't remove artist until all artworks are downloaded", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default) { _ in
                        // Put here any code that you would like to execute when
                        // the user taps that OK button (may be empty in your case if that's just
                        // an informative alert)
                    }
                    let action2 = UIAlertAction(title: "Still delete", style: .Default) { _ in
                        // Put here any code that you would like to execute when
                        // the user taps that "Still delete" button
                        self.deleteArtist(artist, index: indexPath)
                    }
                    alert.addAction(action)
                    alert.addAction(action2)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else { // Should not happen. But when it happens:
                deleteArtist(artist, index: indexPath)
            }
            
        default:
            break
        }
    }
    
    func deleteArtist (artistToBeRemoved: Artist, index: NSIndexPath) {
        // Delete all image files from disk
        Rijks.sharedInstance.removeAllImagesForArtist(artistToBeRemoved)
        
        // Remove the artist from the array
        artists.removeAtIndex(index.row)
        
        // Remove the row from the table
        tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Fade)
        
        // Remove the artist from the context
        sharedContext.deleteObject(artistToBeRemoved)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
}