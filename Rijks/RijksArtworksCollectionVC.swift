//
//  RijksArtworksCollectionVC.swift
//  Rijks
//
//  Created by Twelker on Sep/24/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit
import CoreData

class RijksArtworksCollectionVC: UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate { //, UITextViewDelegate,  {
    
    // Input parameter.
    var artists: [Artist]!
    var artist : Artist!
    
    private var navigationTitle = "" // Init
    
    var currentDevice = ""
    
    @IBOutlet weak var CollectionView  : UICollectionView!
    @IBOutlet weak var messageField    : UITextView!
    
    // Collection view cell reuse identifier
    private let reuseIdentifier = "RijksArtworkCollViewCell"
    
    // Position of collectionview cells
    private let sectionInsets = UIEdgeInsets(top: /*-20.0*/ 20.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    // Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    private var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    } // ========== End of "private var sharedContext" ===============================================================
    
    // Mark: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Artwork")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Artwork.Keys.ArtworkCounter, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "artist == %@", self.artist); // MIND this one!!! "artist" must be in artwork as Artist!!!
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        }()
    
    // Define 3 arrays for holding inserted, changed and deleted indexPaths
    private var insertIndexPaths  = [NSIndexPath]()
    private var changedIndexPaths = [NSIndexPath]()
    private var deletedIndexPaths = [NSIndexPath]()

    private var deviceOrientation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Copy the first 30 characters of artist's name as view's title
        let substrLength = min(30, artist.name.characters.count)
        self.title = artist.name.substringWithRange(Range<String.Index>(start: artist.name.startIndex, end: artist.name.startIndex.advancedBy(substrLength)))
        
        navigationTitle = navigationItem.title! // Save the title
        
        messageField.editable     = false                           // Do not allow editing of the message field
        messageField.scrollRangeToVisible(NSMakeRange(0,0))         // Let beginning of text start at upper left corner of text view
        messageField.alpha        = 0.0                             // Do not display it initially
        
        currentDevice = Rijks.sharedInstance.typeOfDevice()

        // Start the fetched results controller
        do
        {
            try fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            // Report any error we got.
            throwMessage("Error starting fetchedResultsController: \(error)", color: UIColor.redColor())
        }
        
        
        // Set the delegate to this view controller
        fetchedResultsController.delegate = self
        
        // Determine device orientation (for defining the collection view number of cells on a row)
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            deviceOrientation = Rijks.Constants.landscape
        } else {
            deviceOrientation = Rijks.Constants.portrait
        }

        
        // Get list of artworks for input artist
        if artist.artworks.count == 0 {
            RijksDBClient().getListOfArtworks (artist) { success, error in
                
                // Handle the error case
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.throwMessage("Error searching for artworks: \(error.localizedDescription)", color: UIColor.redColor())
                    }
                    return
                } else {
                    // Reload the table on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.CollectionView!.reloadData()
                    
                        // Retrieve the images
                        if self.artist.artworks.count > 0 {
                            
                            for index in 0...self.artist.artworks.count-1 {

                                Rijks.sharedInstance.processOneImage(self.artist.artworks[index]) { success, error in
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        if !success {
                                            self.throwMessage(Rijks.Constants.msgImageNotDownloaded, color: UIColor.redColor())
                                        } else {
                                            self.CollectionView!.reloadData()
                                        }
                                    } // End of dispatch
                                }
                            }
                        }
                    } // End of dispatch
                }
            }
        } else {
            // It could be that there are artworks WITHOUT image yet
            for index in 0...artist.artworks.count-1 {
                if artist.artworks[index].fileName == "" {
                    // No image yet
                    Rijks.sharedInstance.processOneImage(self.artist.artworks[index]) { success, error in
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if !success {
                                self.throwMessage(Rijks.Constants.msgImageNotDownloaded, color: UIColor.redColor())
                            } else {
                                self.CollectionView!.reloadData()
                            }
                        } // End of dispatch
                    }
                    
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = navigationTitle // Restore the title
        
        // Determine device orientation (for defining the collection view number of cells on a row)
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            deviceOrientation = Rijks.Constants.landscape
        } else {
            deviceOrientation = Rijks.Constants.portrait
        }
        
        // Reset error message
        self.messageField.alpha           = 0.0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section] 
        
        return sectionInfo.numberOfObjects
        
    } // ========== End of "collectionView.numberOfItemsInSection" ============================================================================
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // Artist associated artworks array now managed by NSFetchedResultsController
        let artwork = fetchedResultsController.objectAtIndexPath(indexPath) as! Artwork
        
        // Reset error message
        self.messageField.alpha           = 0.0
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? RijksArtworkCollViewCell
        
        if cell != nil {
            
            // Init cell
            cell!.artworkTitle.text = artwork.title
            
            if artwork.favorite == Rijks.Constants.Favorite {
                cell!.artworkFavorize.setImage(UIImage(named: "Favorite.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
            } else {
                cell!.artworkFavorize.setImage(UIImage(named: "Unfavorite-Blue.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
            }

            if artwork.fileName == "" {
                cell!.activityIndicatorView.startAnimating()
            } else {
                // Retrieve the image from local disk and stop animation of activity indicator
                let tempImage = Rijks.sharedInstance.readImage(artwork.fileName)
                if tempImage != nil {
                    cell!.artworkImageView?.image = UIImage(data: tempImage!)
                    cell!.activityIndicatorView.stopAnimating()
                }
            }
            
            //Layer property in Objective C => "http://iostutorialstack.blogspot.in/2014/04/how-to-assign-custom-tag-or-value-to.html"
            cell!.artworkFavorize.layer.setValue(indexPath.row, forKey: "index")
            
            cell!.artworkFavorize.addTarget(self, action: "favUnFav:", forControlEvents: UIControlEvents.TouchUpInside)
            
        } // End of "if cell != nil {"
        
        return cell!
        
    } // ========== End of "collectionView.cellForItemAtIndexPath" ===============================================================================
    
    func favUnFav(sender:UIButton) {
        let i : Int = (sender.layer.valueForKey("index")) as! Int
        
        if self.artist.artworks[i].favorite == Rijks.Constants.Favorite {
            self.artist.artworks[i].favorite = Rijks.Constants.Unfavorite
        } else {
            // Check if <= 20 favorite artworks, otherwise throw message
            if Rijks.sharedInstance.numFavoriteArtworks(artists) < Rijks.Constants.maxNrFavs {
                self.artist.artworks[i].favorite = Rijks.Constants.Favorite
            } else {
                throwMessage(Rijks.Constants.msgMaxNrFavsReached, color: UIColor.redColor())
            }
        }
        // Save to core
        // Save the shared context, using the convenience method in the CoreDataStackManager
        CoreDataStackManager.sharedInstance().saveContext() // Should already be on the main thread
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Navigate to the RijksArtworkDetail view controller
        let storyboard = self.storyboard
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("RijksArtworkDetailVC") as! RijksArtworkDetailVC
        nextVC.fileName    = artist.artworks[indexPath.row].fileName
        nextVC.artistName  = artist.name
        nextVC.artworkName = artist.artworks[indexPath.row].title
        
        navigationItem.title = "" // This ensures that the title of the back button of the next VC is "<" !! Otherwise it is too long.
        // Get it back in "viewWillAppear" when returning.
        
        self.navigationController!.pushViewController(nextVC, animated: false)
        
    } // ========== End of "collectionView.didSelectItemAtIndexPath" ===============================================================================
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        // Initialize the arrays that will be used to store new, deleted and changed artworks represented by their respective indexPath's
        insertIndexPaths  = [NSIndexPath]()
        changedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        
    } // ========== End of "controllerWillChangeContent" ===============================================================================
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert: insertIndexPaths.append(newIndexPath!)

            case .Delete: deletedIndexPaths.append(indexPath!)

            case .Update: changedIndexPaths.append(indexPath!)

            case .Move:

                deletedIndexPaths.append(indexPath!)
                insertIndexPaths.append(newIndexPath!)

            }
    } // ========== End of "controller.didChangeObject" ===============================================================================
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        // Perform updates in batchmode
        self.CollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertIndexPaths {
                self.CollectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.CollectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            // Reload cells in order to get activity indicator or image displayed
            self.CollectionView.reloadItemsAtIndexPaths(self.changedIndexPaths)
            
            }, completion: nil)
        
    } // ========== End of "controller.didChangeContent" ===============================================================================

    func throwMessage (message: String, color: UIColor) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.messageField.backgroundColor = color
            self.messageField.alpha           = 1.0
            self.messageField.text            = message
        })
    }
}

extension RijksArtworksCollectionVC : UICollectionViewDelegateFlowLayout {
    
    // Layout the collection view
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            // Determine cell size
            var navBarHeight: CGFloat = 0
            if let _ = navigationController as UINavigationController? {
                navBarHeight = navigationController!.navigationBar.frame.size.height
            }
            let cellSize           = Rijks.sharedInstance.collectionViewCellSize(currentDevice, deviceOrientation: deviceOrientation, navBarHeight: navBarHeight)
            
            return CGSize(width: cellSize.cellWidth, height: cellSize.cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            deviceOrientation = Rijks.Constants.landscape
        } else {
            deviceOrientation = Rijks.Constants.portrait
        }
        
        // And reload the data
        CollectionView.reloadData()
    }
    
}
