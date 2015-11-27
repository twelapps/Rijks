//
//  Rijks.swift
//  Rijks
//
//  Created by Twelker on Sep/21/15.
//  Copyright © 2015 Twelker. All rights reserved.
//

import Foundation
import UIKit

class Rijks: NSObject {
    
    // Define as singleton so that the class remains in memory; it is used very often and this improves performance
    static let sharedInstance = Rijks()
    private override init() {}
    
    // MARK: - Files Support
    let fileManager  = NSFileManager.defaultManager()
    let dirPaths     = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    
    private var session: NSURLSession = NSURLSession()
    
    typealias CompletionHandlerOneImage  = (success: Bool, error: String?) -> Void
    typealias CompletionHandlerHotMsg    = (success: Bool, hotMessageReturned: String, error: String?) -> Void
    
    private var filePathImageScrollable: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
        return url.URLByAppendingPathComponent(Rijks.Constants.imageScrollableArch).path!
    }
    
    func imageScrollable () -> Bool {
        
        if let imageScrollable = NSKeyedUnarchiver.unarchiveObjectWithFile(filePathImageScrollable) as? Bool {
            return imageScrollable
        } else {
            return Rijks.Constants.imageScrollableDefault
        }
    }
    
    func setImageScrollable (imageScrollable: Bool) {
        NSKeyedArchiver.archiveRootObject(imageScrollable, toFile: filePathImageScrollable)
    }
    
    func processOneImage (artwork: Artwork?, completionHandler: CompletionHandlerOneImage) {
        
        /* Initialize session and url */
        let session                = NSURLSession.sharedSession()
        let url                    = NSURL(string: artwork!.imageUrl)
        let request                = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {imageData, response, downloadError in
            if downloadError != nil { // Handle error...
                completionHandler(success: false, error: Rijks.Constants.msgImageNotDownloaded)
                return
            } else {
                
                // Save image to local "disk"
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // The artwork may have been removed while waiting for the image download
                    if artwork != nil {
                        
                        let imageFileName = self.fileNameFromFullImagePath(artwork!.imageUrl)
                        
                        self.addImage(imageFileName, fileContents: imageData!)
                        
                        artwork!.fileName = imageFileName
                        
                        // Save the artwork to core. Fetch controller will be woken up, core is changed.
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                })
                // Return result
                completionHandler(success: true, error: "")
            }
        } // End of NSURLConnection.sendAsynchronousRequest
        task.resume()
    } // ========== End of "processOneImage" ============================================================================
    
    func fileNameFromFullImagePath (imagePath: String) -> String {
        
        // First build an array of characters out of the input string
        var fullImagePath = [Character]()
        for ind in 0...imagePath.characters.count-1 { // Length of the input string
            fullImagePath.append(imagePath[imagePath.startIndex.advancedBy(ind)])
        }
    
        var fileName = ""
        var stopSearchingForwardSlash = false
        for var index = (fullImagePath.count - 1); index >= 0; index-- {
            if fullImagePath[index] == "/" {
                if stopSearchingForwardSlash {
                    // Do nothing
                } else {
                    stopSearchingForwardSlash = true
                    for index2 in (index+1)...(fullImagePath.count-1) {
                        fileName.append(fullImagePath[index2])
                    }
                }
            }
        }
        
        return fileName
    } // End of func fileName
    
    func createDir () {
        
        var documentsdir = dirPaths[0] // The Documents Directory where to store our files
        documentsdir += Rijks.Constants.directoryExtension
        
        // Create Rijks-images directory to contain our downloaded images. Ignore error since it will only tell you
        // that directory already exists or a severe error occurred from which we cannot recover anyway
        do
        {
            try fileManager.createDirectoryAtPath(documentsdir, withIntermediateDirectories: false, attributes: nil)
            
        } catch _ as NSError { }
    }
    
    func addImage (fileName: String, fileContents: NSData) {
        
        var documentsdir = dirPaths[0] // The Documents Directory where to store our files
        documentsdir += Rijks.Constants.directoryExtension
        
        // Add the imagefile
        let filePath = documentsdir + "/" + fileName
        fileManager.createFileAtPath(filePath, contents: fileContents, attributes: nil)
    }
    
    func readImage (fileName: String) -> NSData? {
        
        var documentsdir = dirPaths[0] // The Documents Directory where to store our files
        documentsdir += Rijks.Constants.directoryExtension
        
        // Read the imagefile
        let filePath = documentsdir + "/" + fileName
        
        return fileManager.contentsAtPath(filePath) // Returns nil in case of error (refer to class reference)
    }
    
    func removeAllImagesForArtist (artist: Artist) {
        if artist.artworks.count > 0 {
            for index in 0...artist.artworks.count-1 {
                if artist.artworks[index].fileName != "" {
                    removeImage(artist.artworks[index].fileName)
                }
            }
        }
    }
    
    func removeImage (fileName: String) {
        
        var documentsdir = dirPaths[0] // The Documents Directory where to store our files
        documentsdir += Rijks.Constants.directoryExtension
        
        // Remove the imagefile
        let filePath = documentsdir + "/" + fileName
        
        do
        {
            try fileManager.removeItemAtPath(filePath)
            
        } catch _ as NSError { }
        
    }
    
    func hotMessage (completionHandler: CompletionHandlerHotMsg) {
        
        /* Initialize session and url */
        let session                = NSURLSession.sharedSession()
        let url                    = NSURL(string: Rijks.Constants.hotMsgSourceUrlString)
        let request                = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {msg, response, downloadError in
            if downloadError != nil { // Handle error...
                completionHandler(success: false, hotMessageReturned: "", error: Rijks.Constants.msgImageNotDownloaded)
                return
            } else {
                
                // Return result
                let resultHotMsg = NSString(data: msg!, encoding: NSUTF8StringEncoding) as! String
                completionHandler(success: true, hotMessageReturned: resultHotMsg, error: "")
            }
        } // End of NSURLConnection.sendAsynchronousRequest
        task.resume()
    } // ========== End of "hotMessage" ============================================================================
    
    func typeOfDevice () -> String {
        
        var typeOfDevice = ""
        
        // Find out iPhone or iPad
        enum UIUserInterfaceIdiom : Int {
            case Unspecified
            
            case Phone // iPhone and iPod touch style UI
            case Pad // iPad style UI
        }
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:       typeOfDevice = Rijks.Constants.iPhone
        case .Pad:         typeOfDevice = Rijks.Constants.iPad
        case .Unspecified: typeOfDevice = ""
        default:           typeOfDevice = ""
        }
        
        return typeOfDevice
    }
    
    func collectionViewCellSize (currentDevice: String, deviceOrientation: String, navBarHeight: CGFloat) -> (cellHeight: CGFloat, cellWidth: CGFloat) {
        
        // Determine screensize
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth        = screenSize.width
        let screenHeight       = screenSize.height
        let statBarHeight      = UIApplication.sharedApplication().statusBarFrame.size.height
        var imagesInARow       = CGFloat()
        var imagesInACol       = CGFloat()
        
        if (currentDevice == Rijks.Constants.iPhone) && (deviceOrientation == Rijks.Constants.portrait) {
            imagesInARow = Rijks.Constants.iPhonePortraitImagesRow
            imagesInACol = Rijks.Constants.iPhonePortraitImagesCol
        } else {
            if (currentDevice == Rijks.Constants.iPhone) && (deviceOrientation == Rijks.Constants.landscape) {
                imagesInARow = Rijks.Constants.iPhoneLandscapeImagesRow
                imagesInACol = Rijks.Constants.iPhoneLandscapeImagesCol
            } else {
                if (currentDevice == Rijks.Constants.iPad) && (deviceOrientation == Rijks.Constants.portrait) {
                    imagesInARow = Rijks.Constants.iPadPortraitImagesRow
                    imagesInACol = Rijks.Constants.iPadPortraitImagesCol
                } else {
                    if (currentDevice == Rijks.Constants.iPad) && (deviceOrientation == Rijks.Constants.landscape) {
                        imagesInARow = Rijks.Constants.iPadLandscapeImagesRow
                        imagesInACol = Rijks.Constants.iPadLandscapeImagesCol
                    }
                }
            }
        }
        
        var cellWidth = (screenWidth-(imagesInARow+1)*10)/imagesInARow
        if cellWidth < 80 { cellWidth = 80 }
        var cellHeight = (screenHeight-(imagesInACol+1)*10-navBarHeight-statBarHeight)/imagesInACol
        if cellHeight < 80 { cellHeight = 80 }
        
        return (cellHeight, cellWidth)
    }
    
    func numFavoriteArtworks (artists: [Artist]) -> Int {
        var nrFavArtwork = 0 // Initiate
        
        if artists.count > 0 {
            for index in 0...artists.count-1 {
                if artists[index].artworks.count > 0 {
                    for index2 in 0...artists[index].artworks.count-1 {
                        if artists[index].artworks[index2].favorite == Rijks.Constants.Favorite {
                            nrFavArtwork += 1
                        }
                    }
                }
            }
        }
        
        return nrFavArtwork
    }

}