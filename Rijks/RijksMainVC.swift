//
//  RijksMainVC.swift
//  Rijks
//
//  Created by Twelker on Jun/13/15.
//  Copyright (c) 2015 Twelker. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RijksMainVC: UIViewController {
    
    private var artists = [Artist]()
    
    private var favoriteArtworkImageFileNames = [String]()

    @IBOutlet weak var imageViewArray         : UIImageView!
    @IBOutlet weak var bottomToolbar          : UIToolbar!
    @IBOutlet weak var RijksWebSiteSafariImage: UIBarButtonItem!
    @IBOutlet weak var Favorites              : UIBarButtonItem!
    @IBOutlet weak var FavoriteArtworks       : UIBarButtonItem!
    @IBOutlet weak var HotNews                : UIBarButtonItem!
    @IBOutlet weak var Directions             : UIBarButtonItem!
    @IBOutlet weak var messageField  : UITextView!
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    /**
    * This is the convenience method for fetching all persistent artists.
    * Core Data will only store the artists that the users chooses.
    *
    * The method creates a "Fetch Request" and then executes the request on
    * the shared context.
    */
    
    func fetchAllArtists() -> [Artist] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Artist")
        
        // Execute the Fetch Request
        var results = [Artist]()
        
        do
        {
            try results = sharedContext.executeFetchRequest(fetchRequest) as! [Artist]
            
        } catch let error as NSError {
            // Report any error we got.
            print("Error in fectchAllArtists(): \(error)")
        }
        
        // Return the results, cast to an array of Artist objects
        return results
    }

    var coords: CLLocationCoordinate2D?
    
    // The view title is manipulated in order to get just "<" to return to the higher level view in the view hierarchy
    private var navigationTitle = "" // Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color of the entire view to light grey, '999999' (built in)
        view.backgroundColor                                    = UIColor.lightGrayColor()
        
        // In order to get white symbols in the status (!) bar:
        // Open your info.plist and insert a new key named "View controller-based status bar appearance" to NO
        // And add the following line here:
        UIApplication.sharedApplication().statusBarStyle        = .LightContent
        
        // Black navigation bar background and white navigation items and title letters
        navigationController!.navigationBar.barTintColor        = UIColor.blackColor()
        navigationController!.navigationBar.tintColor           = UIColor.whiteColor() // E.g. back button is white now
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        // Remove separator lines between bars and main view
        bottomToolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.Any)

        // Tabbar, navigation buttons: set rendering mode to "always original",
        // the default is that the image is just used as a template and (in this case) is colored blue
        RijksWebSiteSafariImage.image    = UIImage(named: "Safari.png")!.imageWithRenderingMode(.AlwaysOriginal)
        Favorites.image                  = UIImage(named: "Favorites Artists.png")!.imageWithRenderingMode(.AlwaysOriginal)
        HotNews.image                    = UIImage(named: "HotNews.png")!.imageWithRenderingMode(.AlwaysOriginal)
        Directions.image                 = UIImage(named: "Directions.png")!.imageWithRenderingMode(.AlwaysOriginal)
        
        navigationTitle = navigationItem.title! // Save the title
        
        // Create a directory to store the image files. No problem if it already exists.
        Rijks.sharedInstance.createDir()
        
        messageField.editable     = false                           // Do not allow editing of the message field
        messageField.scrollRangeToVisible(NSMakeRange(0,0))         // Let beginning of text start at upper left corner of text view
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        messageField.alpha        = 0.0                             // Do not display it initially
        
        navigationItem.title = navigationTitle // Restore the title
        
        // Obtain data stored as Core Data; do it each time this VC is being displayed since data may have been changed.
        artists = fetchAllArtists()
        
        // Create an array of favorite artworks
        favoriteArtworkImageFileNames = [String]() // Initiate
        if artists.count > 0 {
            for index in 0...artists.count-1 {
                if artists[index].artworks.count > 0 {
                    for index2 in 0...artists[index].artworks.count-1 {
                        if artists[index].artworks[index2].favorite == Rijks.Constants.Favorite {
                            favoriteArtworkImageFileNames.append(artists[index].artworks[index2].fileName)
                        }
                    }
                }
            }
        }
        
        // Manipulation of the Select Favorite Artworks toolbar button
        if favoriteArtworkImageFileNames.count == 0 {
            // De-activate favorite artworks button
            FavoriteArtworks.enabled = false
            FavoriteArtworks.image   = UIImage()
        } else {
            // Activate favorite artworks button
            FavoriteArtworks.enabled = true
            FavoriteArtworks.image   = UIImage(named: "Favorites Artworks.png")!.imageWithRenderingMode(.AlwaysOriginal)
        }
        
        /*************************************************************
        * Animation of an array of favorite images on the main page  *
        *************************************************************/
        var imgListArray = [UIImage]()
        
        // First image is image of the Rijksmuseum building
        let strImageName = "RijksmuseumBuilding.jpeg"
        var image  = UIImage(named:strImageName)
        imgListArray.append(image!)
        
        // Append either favorite images (if they are there) or else a predefined set of 4 painting artwork images
        if favoriteArtworkImageFileNames.count > 0 {
            for countValue in 0...favoriteArtworkImageFileNames.count-1 {
                // Read the image from local disk
                let img = Rijks.sharedInstance.readImage(favoriteArtworkImageFileNames[countValue])
                if img != nil {
                    image = UIImage(data: img!)
                    imgListArray.append(image!)
                }
            }
        } else {
            for countValue in 2...5
            {
                let strImageName = "\(String(countValue)).jpeg"
                let image  = UIImage(named:strImageName)
                imgListArray.append(image!)
            }
        }
        
        // And start the animation
        imageViewArray.animationImages   = imgListArray
        
        // <image_array>.animationDuration: the amount of time it takes to go through one cycle of the images.
        // In this case I would like to have 1 second per image
        imageViewArray.animationDuration = Double(imgListArray.count)
        
        imageViewArray.startAnimating()
    }
    
    @IBAction func RijksWebSite (sender: UIBarButtonItem) {
        
        navigationItem.title = "" // This ensures that the title of the back button of the next VC is "<" !! Otherwise it is too long.
        // Get it back in "viewWillAppear" when returning.
        
        // Navigate to the RijksWebSite view controller
        let storyboard = self.storyboard
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("RijksWebsite")
        self.navigationController!.pushViewController(nextVC, animated: false)
    }

    
    @IBAction func Favorites(sender: UIBarButtonItem) {
        
        navigationItem.title = "" // This ensures that the title of the back button of the next VC is "<" !! Otherwise it is too long.
        // Get it back in "viewWillAppear" when returning.
        
        // Navigate to the RijksFavoriteArtists view controller
        let storyboard = self.storyboard
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("RijksFavoriteArtistsVC") as! RijksFavoriteArtistsVC
        nextVC.artists = artists
        self.navigationController!.pushViewController(nextVC, animated: false)
    }
    
    @IBAction func FavoriteArtworks(sender: UIBarButtonItem) {
        
        navigationItem.title = "" // This ensures that the title of the back button of the next VC is "<" !! Otherwise it is too long.
        // Get it back in "viewWillAppear" when returning.
        
        // Navigate to the RijksFavoriteArtworksCollection view controller
        let storyboard = self.storyboard
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("RijksFavoriteArtworksCollectionVC") as! RijksFavoriteArtworksCollectionVC
        nextVC.artists = artists
        self.navigationController!.pushViewController(nextVC, animated: false)
    }
    
    @IBAction func HotNews (sender: UIBarButtonItem) {
        
        navigationItem.title = "" // This ensures that the title of the back button of the next VC is "<" !! Otherwise it is too long.
        // Get it back in "viewWillAppear" when returning.
        
        // Navigate to the RijksWebSite view controller
        let storyboard = self.storyboard
        let nextVC = storyboard!.instantiateViewControllerWithIdentifier("RijksWhatIsHotVC")
        self.navigationController!.pushViewController(nextVC, animated: false)
        
    }
    
    @IBAction func GetDirections(sender: UIBarButtonItem) {
        
        getDirection()
    }
    
}

