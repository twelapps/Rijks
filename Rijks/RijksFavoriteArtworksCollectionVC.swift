//
//  RijksFavoriteArtworksCollectionVC.swift
//  Rijks
//
//  Created by Twelker on Sep/25/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import UIKit
import CoreData

class RijksFavoriteArtworksCollectionVC: UIViewController, UICollectionViewDataSource, UITextViewDelegate { //, NSFetchedResultsControllerDelegate {

    // Input
    var artists: [Artist]!
    
    private var navigationTitle = "" // Init
    
    private struct localFavoriteArtwork {
        var title       : String = ""
        var longTitle   : String = ""
        var typeArt     : String = "Painting"
        var imageUrl    : String = ""
        var fileName    : String = ""
        var favorite    : String = Rijks.Constants.Favorite
        var artist      : String = ""
    }
    private var localFavoriteArtworks = [localFavoriteArtwork]()
    
    @IBOutlet weak var CollectionView           : UICollectionView!
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    // Collection view cell reuse identifier
    private let reuseIdentifier = "RijksFavoriteArtworkCollViewCell"
    
    // Position of collectionview cells
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    private var deviceOrientation = ""
    
    var currentDevice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Favorite Artworks"
        
        navigationTitle = navigationItem.title! // Save the title
        
        // Determine device orientation (for defining the collection view number of cells on a row)
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            deviceOrientation = Rijks.Constants.landscape
        } else {
            deviceOrientation = Rijks.Constants.portrait
        }
        
        currentDevice = Rijks.sharedInstance.typeOfDevice()
        
        // Get list of favorite artworks
        if artists.count > 0 {
            for index in 0...artists.count-1 {
                if artists[index].artworks.count > 0 {
                    for index2 in 0...artists[index].artworks.count-1 {
                        if artists[index].artworks[index2].favorite == Rijks.Constants.Favorite {
                            localFavoriteArtworks.append(
                                localFavoriteArtwork.init(title    : artists[index].artworks[index2].title,
                                                          longTitle: artists[index].artworks[index2].longTitle,
                                                          typeArt  : artists[index].artworks[index2].typeArt,
                                                          imageUrl : artists[index].artworks[index2].imageUrl,
                                                          fileName : artists[index].artworks[index2].fileName,
                                                          favorite : artists[index].artworks[index2].favorite,
                                                          artist   : artists[index].name)
                            )
                        }
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
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return localFavoriteArtworks.count
    } // ========== End of "collectionView.numberOfItemsInSection" ============================================================================
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? RijksFavoriteArtworkCollViewCell
        
        if cell != nil {
            
            // Init cell
            cell!.artworkArtist.text    = localFavoriteArtworks[indexPath.row].artist

            if localFavoriteArtworks[indexPath.row].fileName != "" {
                
                // Retrieve the image from local disk
                let tempImage = Rijks.sharedInstance.readImage(localFavoriteArtworks[indexPath.row].fileName)
                if tempImage != nil {
                    cell!.artworkImageView?.image = UIImage(data: tempImage!)
                }
            }
        } // End of "if cell != nil {"
        
        return cell!
        
    } // ========== End of "collectionView.cellForItemAtIndexPath" ===============================================================================
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Navigate to the RijksArtworkDetail view controller, fixed or scrollable image, depending on Settings parameter
        navigationItem.title = "" // This ensures that the title of the back button of the next VC is "<" !! Otherwise it is too long.
        // Get it back in "viewWillAppear" when returning.
        
        let storyboard = self.storyboard
        if Rijks.sharedInstance.imageScrollable() {
            let nextVC = storyboard!.instantiateViewControllerWithIdentifier(Rijks.Constants.detailScrollImageVC) as! RijksArtworkDetailScrollVC
            nextVC.fileName    = localFavoriteArtworks[indexPath.row].fileName
            nextVC.artistName  = localFavoriteArtworks[indexPath.row].artist
            nextVC.artworkName = localFavoriteArtworks[indexPath.row].title
            self.navigationController!.pushViewController(nextVC, animated: false)
        } else {
            let nextVC = storyboard!.instantiateViewControllerWithIdentifier(Rijks.Constants.detailFixedImageVC) as! RijksArtworkDetailVC
            nextVC.fileName    = localFavoriteArtworks[indexPath.row].fileName
            nextVC.artistName  = localFavoriteArtworks[indexPath.row].artist
            nextVC.artworkName = localFavoriteArtworks[indexPath.row].title
            self.navigationController!.pushViewController(nextVC, animated: false)
        }
        
    } // ========== End of "collectionView.didSelectItemAtIndexPath" ===============================================================================
    
}

extension RijksFavoriteArtworksCollectionVC : UICollectionViewDelegateFlowLayout {
    
    // Layout the collection view
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            // Determine cell size
            let navBarHeight       = navigationController!.navigationBar.frame.size.height
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
