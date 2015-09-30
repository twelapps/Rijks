//
//  RijksDBClient.swift
//  Rijks
//
//  Created by Twelker on Sep/23/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import Foundation
import CoreData

class RijksDBClient : NSObject {
    
    typealias CompletionHandlerArtists  = (result: AnyObject!, error: NSError?) -> Void
    typealias CompletionHandlerArtworks = (success: Bool, error: NSError?) -> Void
    
    private var session: NSURLSession = NSURLSession()
    
    // MARK: - Core Data Convenience
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    func getListOfArtists (ArtistSearchString: String, completionHandler: CompletionHandlerArtists) -> NSURLSessionDataTask {
        
        
        // Initiate output
        var foundArtistsArray = [NSString]()
        
        // Add "*" at both ends of the search argument
        let newArtistSearchString = "*" + ArtistSearchString + "*"
        
        let urlString = Rijks.Constants.BaseUrlSSL
            + "?key=\(Rijks.Constants.ApiKey)"             /* API key */
            + "&format=json"                               /* JSON */
            + "&q=\(newArtistSearchString)"                /* Search string */
            + "&type=painting"                             /* Paintings only */
            + "&imgonly=True"                              /* Only search result if there is an image of the artwork */
            + "&toppieces=True"                            /* Top pieces only */
            + "&ps=100"                                    /* Nr artworks/page */
            + "&s=relevance"                               /* Sort on relevance */
        
        // Replace blanks etc
        let escapedUrlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        /* Initialize session and url */
        let session                = NSURLSession.sharedSession()
        let url                    = NSURL(string: escapedUrlString!)
        let request                = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if downloadError != nil { // Handle error...
                completionHandler(result: nil, error: downloadError)
                return
            } else {
        
                let dataReturned = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if dataReturned != "" {
                    
                    /* Success! Parse the data */
                    
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.AllowFragments]) as? NSDictionary {
                            
                            if let artObjectsArray = jsonResult["artObjects"] as? [NSDictionary] {
                                
                                if artObjectsArray.count > 0 {
                                    
                                    for index in 0...artObjectsArray.count-1 {
                                        let artObjectDict = artObjectsArray[index]
                                        if let artist = artObjectDict["principalOrFirstMaker"] as? NSString {
                                            
                                            // See if artist already in the found artists array; if not, add it
                                            var artistAlreadyFound = false
                                            for artistArrayMember in foundArtistsArray {
                                                if artistArrayMember == artist {
                                                    artistAlreadyFound = true
                                                }
                                            }
                                            if !artistAlreadyFound {
                                                foundArtistsArray.append(artist)
                                            }
                                        }
                                    }
                                }
                                completionHandler(result: foundArtistsArray, error: nil)
                            }
                        }
                    } catch let error as NSError {
                        completionHandler(result: nil, error: error)
                    }
                } else {
                    completionHandler(result: nil, error: nil) // NOT CORRECT!!
                }
            }
        }
        task.resume()
    return task
    } // End of func "getListOfArtists"
    
    func getListOfArtworks (artist: Artist, completionHandler: CompletionHandlerArtworks) -> Void {
        
        let urlString = Rijks.Constants.BaseUrlSSL
            + "?key=\(Rijks.Constants.ApiKey)"             /* API key */
            + "&format=json"                               /* JSON */
            + "&maker=\(artist.name)"                      /* all artworks by input artist name */
            + "&type=painting"                             /* Paintings only */
            + "&imgonly=True"                              /* Only search result if there is an image of the artwork */
            + "&toppieces=True"                            /* Top pieces only */
            + "&ps=100"                                    /* Nr artworks/page */
            + "&s=relevance"                               /* Sort on relevance */
        
        // Replace blanks etc
        let escapedUrlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        /* Initialize session and url */
        let session                = NSURLSession.sharedSession()
        let url                    = NSURL(string: escapedUrlString!)
        let request                = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if downloadError != nil { // Handle error...
                completionHandler(success: false, error: downloadError)
                return
            } else {
        
                let dataReturned = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if dataReturned != "" {
                    
                    /* Success! Parse the data */
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: [NSJSONReadingOptions.AllowFragments]) as? NSDictionary {
                            
                            if let artObjectsArray = jsonResult["artObjects"] as? [NSDictionary] {
                                
                                if artObjectsArray.count > 0 {
                                    
                                    // Update UI on the main thread!!
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                    
                                        for index in 0...artObjectsArray.count-1 {
                                            
                                            var title     = NSString()
                                            var longTitle = NSString()
                                            var imageUrl  = NSString()

                                            let artObjectDict = artObjectsArray[index]
                                            if let a = artObjectDict["title"] as? NSString {
                                                title = a
                                            }
                                            if let b = artObjectDict["longTitle"] as? NSString {
                                                longTitle = b
                                            }
                                            if let webDict = artObjectDict["webImage"] as? NSDictionary {
                                                if let c = webDict["url"] as? NSString {
                                                    imageUrl = c
                                                }
                                            }
                                            
                                            // New empty artwork
                                            let dictionary: [String : AnyObject] = [
                                                Artwork.Keys.Title          : title,
                                                Artwork.Keys.LongTitle      : longTitle,
                                                Artwork.Keys.TypeArt        : "Painting",
                                                Artwork.Keys.ImageUrl       : imageUrl,
                                                Artwork.Keys.FileName       : "",
                                                Artwork.Keys.Favorite       : Rijks.Constants.Unfavorite,
                                                Artwork.Keys.ArtworkCounter : String(1000 + artist.artworks.count + 1)
                                            ]
                                            
                                            // Now we create a new Artwork, using the shared Context
                                            let newArtwork = Artwork(dictionary: dictionary, context: self.sharedContext)
                                            
                                            // Through the relationship between Artist and Artwork the following statement
                                            // will automatically add Artwork to Artist's Artworks array as well!
                                            newArtwork.artist = artist
                                            
                                            // Due to these changes the NSFetchedResultsController will take care of calling the necessary functions
                                            // to display the empty cells with activity indicator
                                            
                                            // Save the shared context, using the convenience method in the CoreDataStackManager
                                                CoreDataStackManager.sharedInstance().saveContext()
                                        } // End of for loop
                                        
                                    } // End of dispatch
                                    
                                } // End of "if artObjectsArray.count > 0 {"
                                
                                completionHandler(success: true, error: nil)
                                
                            }
                        }
                    } catch let error as NSError {
                        completionHandler(success: false, error: error)
                    }
                } else {
                    completionHandler(success: false, error: nil)
                }
            }
        }
        task.resume()
    } // End of func "getListOfArtworks"
    
}
